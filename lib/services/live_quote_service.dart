import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class LiveQuote {
  const LiveQuote({
    required this.symbol,
    required this.price,
    required this.bid,
    required this.ask,
    required this.open,
    required this.high,
    required this.low,
    required this.sourceTime,
  });

  final String symbol;
  final double? price;
  final double? bid;
  final double? ask;
  final double? open;
  final double? high;
  final double? low;
  final DateTime? sourceTime;

  factory LiveQuote.fromJson(String symbol, Map<String, dynamic> json) {
    double? numberOf(dynamic value) {
      if (value == null) return null;
      return double.tryParse(value.toString());
    }

    DateTime? parseSourceTime(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString().replaceFirst(' ', 'T'));
    }

    return LiveQuote(
      symbol: symbol,
      price: numberOf(json['price']),
      bid: numberOf(json['buy']),
      ask: numberOf(json['sell']),
      open: numberOf(json['oprice']),
      high: numberOf(json['hprice']),
      low: numberOf(json['lprice']),
      sourceTime: parseSourceTime(json['date_time']),
    );
  }
}

class LiveQuoteService extends ChangeNotifier {
  static final Uri _url = Uri.parse('wss://wsprc.royalassetindo.co.id');

  final Map<String, LiveQuote> quotes = {};
  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  Timer? _statusTimer;

  bool isConnecting = false;
  bool isConnected = false;
  String? errorMessage;
  DateTime? lastMessageAt;
  bool _disposed = false;

  bool get hasFreshGoldPrice => _isFresh(quotes['XUL10']);

  bool get hasFreshHkkPrice => _isFresh(quotes['HKK50_BBJ']);

  bool _isFresh(LiveQuote? quote) {
    final sourceTime = quote?.sourceTime;
    if (sourceTime == null) return false;

    final age = DateTime.now().difference(sourceTime);
    return !age.isNegative && age <= const Duration(minutes: 5);
  }

  void reconnect() {
    if (_disposed) return;
    _reconnectTimer?.cancel();

    final oldChannel = _channel;
    _channel = null;
    isConnected = false;
    isConnecting = false;
    _notify();

    oldChannel?.sink.close();
    _connect();
  }

  void start() {
    _statusTimer ??= Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_disposed) notifyListeners();
    });
    _connect();
  }

  Future<void> _connect() async {
    if (_disposed || isConnecting || isConnected) return;

    isConnecting = true;
    errorMessage = null;
    _notify();

    try {
      final channel = WebSocketChannel.connect(_url);
      _channel = channel;

      await channel.ready.timeout(const Duration(seconds: 12));
      if (_disposed) {
        await channel.sink.close();
        return;
      }

      isConnecting = false;
      isConnected = true;
      _notify();

      channel.stream.listen(
        _handleMessage,
        onError: (Object error) {
          _handleDisconnect('Koneksi live quote mengalami gangguan.');
        },
        onDone: () {
          _handleDisconnect('Koneksi live quote terputus.');
        },
        cancelOnError: true,
      );
    } catch (_) {
      _handleDisconnect('Tidak dapat terhubung ke sumber live quote.');
    }
  }

  void _handleMessage(dynamic message) {
    if (_disposed) return;

    lastMessageAt = DateTime.now();

    try {
      final decoded = jsonDecode(message.toString());
      if (decoded is! Map) {
        _notify();
        return;
      }

      // Sumber mengirim kumpulan simbol dalam satu objek JSON.
      for (final entry in decoded.entries) {
        final symbol = entry.key.toString().toUpperCase();
        if (symbol != 'XUL10' && symbol != 'HKK50_BBJ') continue;
        if (entry.value is! Map) continue;

        final data = Map<String, dynamic>.from(entry.value as Map);
        final quote = LiveQuote.fromJson(symbol, data);

        // Jangan mengganti harga valid dengan paket yang tidak memiliki harga.
        if (quote.price != null) {
          quotes[symbol] = quote;
        }
      }
    } catch (_) {
      // Pesan sambutan/login server bukan data harga.
    }

    _notify();
  }

  void _handleDisconnect(String message) {
    if (_disposed) return;

    isConnecting = false;
    isConnected = false;
    errorMessage = message;
    _channel = null;
    _notify();

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 10), () {
      _connect();
    });
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _statusTimer?.cancel();
    _channel?.sink.close();
    super.dispose();
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/gold_price.dart';
import '../models/pivot_point.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static Future<List<GoldPrice>> getGoldPrices() async {
    final response = await http.get(Uri.parse('$baseUrl/gold-prices'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> data = json['data'] ?? [];

      return data
          .map((item) => GoldPrice.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Gagal mengambil data harga emas: ${response.statusCode}');
  }

  static Future<GoldPrice> getLatestGoldPrice() async {
    final response = await http.get(Uri.parse('$baseUrl/gold-prices/latest'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      return GoldPrice.fromJson(json['data'] as Map<String, dynamic>);
    }

    throw Exception(
      'Gagal mengambil harga emas terbaru: ${response.statusCode}',
    );
  }

  static Future<GoldPrice?> getGoldPriceByCommodity(String commodity) async {
    final prices = await getGoldPrices();

    for (final price in prices) {
      if (price.commodity.toUpperCase() == commodity.toUpperCase()) {
        return price;
      }
    }

    return null;
  }

  static Future<PivotPoint> getPivotPoint(String commodity) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/pivot-point?commodity=${Uri.encodeQueryComponent(commodity)}',
      ),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      return PivotPoint.fromJson(json['data'] as Map<String, dynamic>);
    }

    throw Exception('Gagal mengambil data pivot point: ${response.statusCode}');
  }
}

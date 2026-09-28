import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/pivot_point.dart';
import '../services/api_service.dart';

class PivotPointPage extends StatefulWidget {
  const PivotPointPage({super.key});

  @override
  State<PivotPointPage> createState() => _PivotPointPageState();
}

class _PivotPointPageState extends State<PivotPointPage> {
  PivotPoint? _pivotData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPivotPoint();
  }

  // ============================================================
  // ASSET
  // ============================================================

  // ============================================================
  // ASSET
  // ============================================================

  String _currentAsset = 'LGD';

  // ============================================================
  // INPUT OHLC
  // ============================================================

  final TextEditingController _openController = TextEditingController(
    text: '0.00',
  );

  final TextEditingController _highController = TextEditingController(
    text: '0.00',
  );

  final TextEditingController _lowController = TextEditingController(
    text: '0.00',
  );

  final TextEditingController _closeController = TextEditingController(
    text: '0.00',
  );

  final TextEditingController _decimalController = TextEditingController(
    text: '2',
  );

  // ============================================================
  // FORMAT
  // ============================================================

  String _formatType = 'Decimal';

  // ============================================================
  // PIVOT VALUES
  // ============================================================

  double _range = 0.00;
  double _pp = 0.00;

  double _r1 = 0.00;
  double _r2 = 0.00;
  double _r3 = 0.00;
  double _r4 = 0.00;

  double _s1 = 0.00;
  double _s2 = 0.00;
  double _s3 = 0.00;
  double _s4 = 0.00;

  double _m7 = 0.00;
  double _m6 = 0.00;
  double _m5 = 0.00;
  double _m4 = 0.00;
  double _m3 = 0.00;
  double _m2 = 0.00;
  double _m1 = 0.00;
  double _m0 = 0.00;

  // ============================================================
  // SIGNAL
  // ============================================================

  String _signal = 'BUY';

  String _signalLogic = 'Open (2382.40) < PP (2388.83)';

  String _ruleExplanation =
      'LGD Bullion Rule: Open below Pivot suggests discount accumulation toward R1 resistance.';

  bool _nestBuy = true;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _openController.dispose();
    _highController.dispose();
    _lowController.dispose();
    _closeController.dispose();
    _decimalController.dispose();
    super.dispose();
  }

  // ============================================================
  // HELPERS
  // ============================================================

  double _parseController(TextEditingController controller) {
    return double.tryParse(controller.text) ?? 0;
  }

  int get _decimalPlaces {
    final value = int.tryParse(_decimalController.text);

    if (value == null) return 2;

    return value.clamp(0, 6);
  }

  String _format(double value) {
    return value.toStringAsFixed(_decimalPlaces);
  }

  // ============================================================
  // CALCULATE PIVOT
  // ============================================================

  Future<void> _loadPivotPoint() async {
    try {
      final data = await ApiService.getPivotPoint();

      if (!mounted) return;

      final open = data.open;
      final high = data.high;
      final low = data.low;
      final close = data.close;

      // Masukkan data API ke input field.
      _openController.text = _format(open);
      _highController.text = _format(high);
      _lowController.text = _format(low);
      _closeController.text = _format(close);

      // Gunakan nilai Pivot dari API.
      // Hitung Pivot Point berdasarkan OHLC dari API.
      final range = high - low;
      final pp = (high + low + close) / 3;

      // Resistance
      final r1 = (2 * pp) - low;
      final r2 = pp + range;
      final r3 = pp + (range * 2);
      final r4 = pp + (range * 3);

      // Support
      final s1 = (2 * pp) - high;
      final s2 = pp - range;
      final s3 = pp - (range * 2);
      final s4 = pp - (range * 3);

      // Midpoints tetap mengikuti struktur
      // Pivot Point yang sudah ada di halaman.
      final m7 = (r4 + r3) / 2;
      final m6 = (r3 + r2) / 2;
      final m5 = (r2 + r1) / 2;
      final m4 = (r1 + pp) / 2;
      final m3 = (pp + s1) / 2;
      final m2 = (s1 + s2) / 2;
      final m1 = (s2 + s3) / 2;
      final m0 = (s3 + s4) / 2;

      String signal;
      String signalLogic;
      String ruleExplanation;

      if (_currentAsset == 'LGD') {
        // LGD:
        // Open < PP = BUY
        // Open > PP = SELL
        if (open < pp) {
          signal = 'BUY';
          signalLogic = 'Open (${_format(open)}) < PP (${_format(pp)})';
          ruleExplanation =
              'LGD Bullion Rule: Open below Pivot suggests discount accumulation toward R1 resistance.';
        } else {
          signal = 'SELL';
          signalLogic = 'Open (${_format(open)}) > PP (${_format(pp)})';
          ruleExplanation =
              'LGD Bullion Rule: Open above Pivot suggests premium liquidation target toward S1 support.';
        }

        _nestBuy = close > open;
      } else {
        // HSI:
        // Open > PP = BUY
        // Open < PP = SELL
        if (open > pp) {
          signal = 'BUY';
          signalLogic = 'Open (${_format(open)}) > PP (${_format(pp)})';
          ruleExplanation =
              'HSI Momentum Rule: Index Open higher than PP confirms buyers holding immediate daily initiative.';
        } else {
          signal = 'SELL';
          signalLogic = 'Open (${_format(open)}) < PP (${_format(pp)})';
          ruleExplanation =
              'HSI Momentum Rule: Index Open lower than PP highlights bearish pressure beneath the daily central line.';
        }
      }

      setState(() {
        _pivotData = data;
        _isLoading = false;
        _errorMessage = null;

        _range = range;
        _pp = pp;

        _r1 = r1;
        _r2 = r2;
        _r3 = r3;
        _r4 = r4;

        _s1 = s1;
        _s2 = s2;
        _s3 = s3;
        _s4 = s4;

        _m7 = m7;
        _m6 = m6;
        _m5 = m5;
        _m4 = m4;
        _m3 = m3;
        _m2 = m2;
        _m1 = m1;
        _m0 = m0;

        _signal = signal;
        _signalLogic = signalLogic;
        _ruleExplanation = ruleExplanation;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal mengambil data pivot point.';
      });
    }
  }

  void _calculatePivot() {
    final open = _parseController(_openController);
    final high = _parseController(_highController);
    final low = _parseController(_lowController);
    final close = _parseController(_closeController);

    final range = high - low;
    final pp = (high + low + close) / 3;

    // Resistance
    final r1 = (2 * pp) - low;
    final r2 = pp + range;
    final r3 = pp + (range * 2);
    final r4 = pp + (range * 3);

    // Support
    final s1 = (2 * pp) - high;
    final s2 = pp - range;
    final s3 = pp - (range * 2);
    final s4 = pp - (range * 3);

    // Midpoints
    final m7 = (r4 + r3) / 2;
    final m6 = (r3 + r2) / 2;
    final m5 = (r2 + r1) / 2;
    final m4 = (r1 + pp) / 2;
    final m3 = (pp + s1) / 2;
    final m2 = (s1 + s2) / 2;
    final m1 = (s2 + s3) / 2;
    final m0 = (s3 + s4) / 2;

    String signal;
    String signalLogic;
    String ruleExplanation;

    if (_currentAsset == 'LGD') {
      if (open < pp) {
        signal = 'BUY';
        signalLogic = 'Open (${_format(open)}) < PP (${_format(pp)})';
        ruleExplanation =
            'LGD Bullion Rule: Open below Pivot suggests discount accumulation toward R1 resistance.';
      } else {
        signal = 'SELL';
        signalLogic = 'Open (${_format(open)}) > PP (${_format(pp)})';
        ruleExplanation =
            'LGD Bullion Rule: Open above Pivot suggests premium liquidation target toward S1 support.';
      }

      _nestBuy = close > open;
    } else {
      if (open > pp) {
        signal = 'BUY';
        signalLogic = 'Open (${_format(open)}) > PP (${_format(pp)})';
        ruleExplanation =
            'HSI Momentum Rule: Index Open higher than PP confirms buyers holding immediate daily initiative.';
      } else {
        signal = 'SELL';
        signalLogic = 'Open (${_format(open)}) < PP (${_format(pp)})';
        ruleExplanation =
            'HSI Momentum Rule: Index Open lower than PP highlights bearish pressure beneath the daily central line.';
      }
    }

    setState(() {
      _range = range;
      _pp = pp;

      _r1 = r1;
      _r2 = r2;
      _r3 = r3;
      _r4 = r4;

      _s1 = s1;
      _s2 = s2;
      _s3 = s3;
      _s4 = s4;

      _m7 = m7;
      _m6 = m6;
      _m5 = m5;
      _m4 = m4;
      _m3 = m3;
      _m2 = m2;
      _m1 = m1;
      _m0 = m0;

      _signal = signal;
      _signalLogic = signalLogic;
      _ruleExplanation = ruleExplanation;
    });
  }

  // ============================================================
  // SWITCH ASSET
  // ============================================================

  void _switchAsset(String asset) {
    setState(() {
      _currentAsset = asset;

      if (asset == 'LGD') {
        _openController.text = '2382.40';
        _highController.text = '2398.60';
        _lowController.text = '2375.10';
        _closeController.text = '2392.80';
        _decimalController.text = '2';
      } else {
        _openController.text = '16720.00';
        _highController.text = '16890.00';
        _lowController.text = '16640.00';
        _closeController.text = '16810.00';
        _decimalController.text = '0';
      }
    });

    _calculatePivot();
  }

  // ============================================================
  // RESET
  // ============================================================

  void _resetValues() {
    _switchAsset(_currentAsset);
  }

  // ============================================================
  // COPY PP
  // ============================================================

  void _copyPivot() {
    Clipboard.setData(ClipboardData(text: 'PP: ${_format(_pp)}'));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hasil PP berhasil disalin'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  children: [
                    _buildAssetBar(),
                    const SizedBox(height: 16),

                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_errorMessage != null)
                      _buildErrorState(_errorMessage!)
                    else if (_pivotData != null)
                      _buildWorkspace()
                    else
                      _buildErrorState('Data pivot point belum tersedia.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 34,
            color: Color(0xFF785600),
          ),
          const SizedBox(height: 10),
          const Text(
            'Data Pivot Point',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: _loadPivotPoint,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFD3C4AF).withValues(alpha: 0.35),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // BACK BUTTON
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
            color: const Color(0xFF0B1C30),
            tooltip: 'Kembali ke Dashboard',
          ),

          const SizedBox(width: 2),

          // LOGO
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF785600),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.show_chart, color: Colors.white, size: 22),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'EQUITY PULSE',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0B1C30),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00855B).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 6,
                            height: 6,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Color(0xFF00855B),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Open',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF006947),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'PT EQUITYWORLD FUTURES',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF785600),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              size: 22,
              color: Color(0xFF4F4535),
            ),
          ),

          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFFDEA6),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF785600).withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: const Icon(Icons.person, size: 17, color: Color(0xFF785600)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ASSET BAR
  // ============================================================

  Widget _buildAssetBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _assetButton(
                  label: 'LGD (Loco London Gold)',
                  asset: 'LGD',
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _assetButton(
                  label: 'HSI (Hang Seng Index)',
                  asset: 'HSI',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FORMULA PROFILE',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF817563),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Institutional Classic',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF785600),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00855B).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      size: 15,
                      color: Color(0xFF006947),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'CALCULATED LIVE',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF006947),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _assetButton({required String label, required String asset}) {
    final active = _currentAsset == asset;

    return GestureDetector(
      onTap: () => _switchAsset(asset),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFF8F9FF) : const Color(0xFFEFF4FF),
          borderRadius: BorderRadius.circular(9),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF785600)
                    : const Color(0xFFD3C4AF),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: active
                      ? const Color(0xFF785600)
                      : const Color(0xFF4F4535),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // WORKSPACE
  // ============================================================

  Widget _buildWorkspace() {
    return Column(
      children: [
        _buildParameterCard(),
        const SizedBox(height: 16),
        _buildSignalCard(),
        const SizedBox(height: 16),
        _buildPivotLadder(),
      ],
    );
  }

  // ============================================================
  // PARAMETER CARD
  // ============================================================

  Widget _buildParameterCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.tune_rounded,
                color: Color(0xFF785600),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'OHLC Parameters',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B1C30),
                  ),
                ),
              ),
              _smallBadge('Session Daily'),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _inputField(label: 'OPEN', controller: _openController),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _inputField(label: 'HIGH', controller: _highController),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _inputField(label: 'LOW', controller: _lowController),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _inputField(
                  label: 'CLOSE',
                  controller: _closeController,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildFormatSection(),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _calculatePivot,
                  icon: const Icon(Icons.calculate_outlined, size: 18),
                  label: const Text('Hitung Pivot'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF785600),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _resetValues,
                  icon: const Icon(Icons.restart_alt, size: 18),
                  label: const Text('Reset Form'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0B1C30),
                    side: const BorderSide(color: Color(0xFFD3E4FE)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4F4535),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF4FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Text(
                'USD',
                style: TextStyle(fontSize: 9, color: Color(0xFF817563)),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B1C30),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: (_) => _calculatePivot(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FORMAT SECTION
  // ============================================================

  Widget _buildFormatSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'INPUT FORMATS',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Color(0xFF817563),
              letterSpacing: 0.8,
            ),
          ),

          const SizedBox(height: 9),

          Wrap(
            spacing: 10,
            runSpacing: 7,
            children: [
              _radioOption('Decimal'),
              _radioOption('64ths'),
              _radioOption('32nds'),
              _radioOption('32nds + halves'),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DECIMAL PLACES',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF817563),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: TextField(
                        controller: _decimalController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FORMULA SET',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF817563),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Classic',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0B1C30),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 18,
                            color: Color(0xFF4F4535),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _radioOption(String value) {
    final selected = _formatType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _formatType = value;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 17,
            height: 17,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? const Color(0xFF785600)
                    : const Color(0xFF9CA3AF),
                width: 1.5,
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF785600),
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              color: selected
                  ? const Color(0xFF0B1C30)
                  : const Color(0xFF4F4535),
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SIGNAL CARD
  // ============================================================

  Widget _buildSignalCard() {
    final isBuy = _signal == 'BUY';

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.radar, color: Color(0xFF006947), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _currentAsset == 'LGD'
                      ? 'LGD Market Signals'
                      : 'HSI Index Signals',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B1C30),
                  ),
                ),
              ),
              _smallBadge('Range: ${_format(_range)}'),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PIVOT DIRECTION SIGNAL',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF817563),
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _signalLogic,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF0B1C30),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: isBuy
                        ? const Color(0xFF00855B)
                        : const Color(0xFFBA1A1A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _signal,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_currentAsset == 'LGD') ...[
            const SizedBox(height: 10),
            _buildNestCard(),
          ],

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FF).withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Color(0xFF785600),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    _ruleExplanation,
                    style: const TextStyle(
                      fontSize: 10,
                      height: 1.4,
                      color: Color(0xFF4F4535),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NEST
  // ============================================================

  Widget _buildNestCard() {
    final open = _parseController(_openController);
    final close = _parseController(_closeController);

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'NEST Rule Matrix',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0B1C30),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF785600,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'LGD Specific',
                            style: TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF785600),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Close (${_format(close)}) '
                      '${close > open ? '>' : '<'} '
                      'Open (${_format(open)})',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF4F4535),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _nestBuy
                      ? const Color(0xFF00855B)
                      : const Color(0xFFFFDAD6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'NEST: ${_nestBuy ? 'BUY' : 'SELL'}',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: _nestBuy ? Colors.white : const Color(0xFF93000A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          const Text(
            'Institutional confirmation: Close above Open reinforces directional momentum before entering session pivot extension.',
            style: TextStyle(
              fontSize: 9,
              height: 1.4,
              color: Color(0xFF4F4535),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PIVOT LADDER
  // ============================================================

  Widget _buildPivotLadder() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calculated Pivot Ladder',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B1C30),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Strict 17-Level Institutional Structure',
                      style: TextStyle(fontSize: 9, color: Color(0xFF817563)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _legend('Resistance', const Color(0xFFBA1A1A)),
                  const SizedBox(height: 4),
                  _legend('Central PP', const Color(0xFF785600)),
                  const SizedBox(height: 4),
                  _legend('Support', const Color(0xFF006947)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          _ladderRow(
            label: 'R4',
            formula: 'PP + RANGE × 3',
            value: _r4,
            type: LadderType.resistance,
          ),

          _midRow(formula: '(R4 + R3) / 2', value: _m7),

          _ladderRow(
            label: 'R3',
            formula: 'PP + RANGE × 2',
            value: _r3,
            type: LadderType.resistance,
          ),

          _midRow(formula: '(R3 + R2) / 2', value: _m6),

          _ladderRow(
            label: 'R2',
            formula: 'PP + RANGE',
            value: _r2,
            type: LadderType.resistance,
          ),

          _midRow(formula: '(R2 + R1) / 2', value: _m5),

          _ladderRow(
            label: 'R1',
            formula: '2 × PP - L',
            value: _r1,
            type: LadderType.resistance,
          ),

          _midRow(formula: '(R1 + PP) / 2', value: _m4),

          _pivotRow(),

          _midRow(formula: '(PP + S1) / 2', value: _m3),

          _ladderRow(
            label: 'S1',
            formula: '2 × PP - H',
            value: _s1,
            type: LadderType.support,
          ),

          _midRow(formula: '(S1 + S2) / 2', value: _m2),

          _ladderRow(
            label: 'S2',
            formula: 'PP - RANGE',
            value: _s2,
            type: LadderType.support,
          ),

          _midRow(formula: '(S2 + S3) / 2', value: _m1),

          _ladderRow(
            label: 'S3',
            formula: 'PP - RANGE × 2',
            value: _s3,
            type: LadderType.support,
          ),

          _midRow(formula: '(S3 + S4) / 2', value: _m0),

          _ladderRow(
            label: 'S4',
            formula: 'PP - RANGE × 3',
            value: _s4,
            type: LadderType.support,
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Base: Institutional Standard (H+L+C)/3',
                  style: TextStyle(fontSize: 9, color: Color(0xFF817563)),
                ),
              ),
              TextButton.icon(
                onPressed: _copyPivot,
                icon: const Icon(Icons.content_copy, size: 15),
                label: const Text('Salin Hasil PP'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF785600),
                  padding: EdgeInsets.zero,
                  textStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LADDER ROW
  // ============================================================

  Widget _ladderRow({
    required String label,
    required String formula,
    required double value,
    required LadderType type,
  }) {
    final isResistance = type == LadderType.resistance;

    final background = isResistance
        ? const Color(0xFFFFDAD6).withValues(alpha: 0.35)
        : const Color(0xFFDAE2FD).withValues(alpha: 0.4);

    final textColor = isResistance
        ? const Color(0xFFBA1A1A)
        : const Color(0xFF006947);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 38,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              formula,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9, color: Color(0xFF4F4535)),
            ),
          ),
          Text(
            _format(value),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MID ROW
  // ============================================================

  Widget _midRow({required String formula, required double value}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 38,
            child: Text(
              'Mid',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Color(0xFF565E74),
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              formula,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9, color: Color(0xFF4F4535)),
            ),
          ),
          Text(
            _format(value),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0B1C30),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PP ROW
  // ============================================================

  Widget _pivotRow() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFF785600).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 5),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 38,
            child: Text(
              'PP',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF785600),
              ),
            ),
          ),
          const Expanded(
            child: Row(
              children: [
                Text(
                  '(H + L + C) / 3',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF785600),
                  ),
                ),
                SizedBox(width: 7),
                Text(
                  'AXIS',
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    backgroundColor: Color(0xFF785600),
                  ),
                ),
              ],
            ),
          ),
          Text(
            _format(_pp),
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Color(0xFF785600),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: child,
    );
  }

  // ============================================================
  // SMALL BADGE
  // ============================================================

  Widget _smallBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4F4535),
        ),
      ),
    );
  }

  // ============================================================
  // LEGEND
  // ============================================================

  Widget _legend(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigation() {
    final items = [
      const _BottomItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Dashboard',
      ),
      const _BottomItem(
        icon: Icons.newspaper_outlined,
        activeIcon: Icons.newspaper,
        label: 'Berita',
      ),
      const _BottomItem(
        icon: Icons.show_chart,
        activeIcon: Icons.show_chart,
        label: 'Harga',
      ),
      const _BottomItem(
        icon: Icons.table_chart_outlined,
        activeIcon: Icons.table_chart,
        label: 'Pivot',
      ),
      const _BottomItem(
        icon: Icons.calculate_outlined,
        activeIcon: Icons.calculate,
        label: 'Kalkulator',
      ),
      const _BottomItem(
        icon: Icons.history_outlined,
        activeIcon: Icons.history,
        label: 'Histori',
      ),
      const _BottomItem(
        icon: Icons.apartment_outlined,
        activeIcon: Icons.apartment,
        label: 'Profil PT',
      ),
    ];

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        border: const Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(items.length, (index) {
              final active = index == 3;

              return SizedBox(
                width: 82,
                child: InkWell(
                  onTap: () {
                    // Navigasi antar halaman akan
                    // dihubungkan setelah seluruh UI selesai.
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        active ? items[index].activeIcon : items[index].icon,
                        size: 20,
                        color: active
                            ? const Color(0xFF785600)
                            : const Color(0xFF817563),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[index].label,
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: active
                              ? const Color(0xFF785600)
                              : const Color(0xFF817563),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// ENUM
// ================================================================

enum LadderType { resistance, support }

// ================================================================
// BOTTOM NAV MODEL
// ================================================================

class _BottomItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _BottomItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

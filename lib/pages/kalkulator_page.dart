import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class KalkulatorPage extends StatefulWidget {
  const KalkulatorPage({super.key});

  @override
  State<KalkulatorPage> createState() => _KalkulatorPageState();
}

class _KalkulatorPageState extends State<KalkulatorPage> {
  // ============================================================
  // CONSTANT
  // ============================================================

  static const double tozFixed = 31.10;

  // ============================================================
  // TAB
  // ============================================================

  int selectedTab = 0;

  // Histori sementara di sisi frontend (selama halaman masih aktif).
  bool _showHistory = false;
  final List<Map<String, dynamic>> _calculationHistory = [];

  // ============================================================
  // DIGITAL
  // ============================================================

  final TextEditingController digitalBeliController =
      TextEditingController(text: '1450000');

  final TextEditingController digitalJualController =
      TextEditingController(text: '1465000');

  final TextEditingController digitalLotController =
      TextEditingController(text: '5');

  double digitalSelisih = 0;
  double digitalKotor = 0;
  double digitalFee = 0;
  double digitalPajak = 0;
  double digitalNet = 0;
  double digitalNetPercentage = 0;

  // ============================================================
  // FISIK
  // ============================================================

  final TextEditingController fisikKursController =
      TextEditingController(text: '16250');

  final TextEditingController fisikModalController =
      TextEditingController(text: '100000000');

  final TextEditingController fisikBeliController =
      TextEditingController(text: '2380');

  final TextEditingController fisikJualController =
      TextEditingController(text: '2410');

  double fisikBeliPerGram = 0;
  double fisikJualPerGram = 0;
  double fisikSelisihPerGram = 0;
  double fisikJumlahGram = 0;
  double fisikCuan = 0;
  double fisikTotalNilai = 0;
  double fisikRoi = 0;

  @override
  void initState() {
    super.initState();

    calculateDigital();
    calculateFisik();

    digitalBeliController.addListener(calculateDigital);
    digitalJualController.addListener(calculateDigital);
    digitalLotController.addListener(calculateDigital);

    fisikKursController.addListener(calculateFisik);
    fisikModalController.addListener(calculateFisik);
    fisikBeliController.addListener(calculateFisik);
    fisikJualController.addListener(calculateFisik);
  }

  @override
  void dispose() {
    digitalBeliController.dispose();
    digitalJualController.dispose();
    digitalLotController.dispose();

    fisikKursController.dispose();
    fisikModalController.dispose();
    fisikBeliController.dispose();
    fisikJualController.dispose();

    super.dispose();
  }

  // ============================================================
  // PARSE NUMBER
  // ============================================================

  double parseNumber(String value) {
    return double.tryParse(value.replaceAll('.', '').replaceAll(',', '')) ?? 0;
  }

  // ============================================================
  // FORMAT RUPIAH
  // ============================================================

  String formatRupiah(double value) {
    final rounded = value.round();
    final negative = rounded < 0;
    final number = rounded.abs().toString();

    final buffer = StringBuffer();

    for (int i = 0; i < number.length; i++) {
      if (i > 0 && (number.length - i) % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(number[i]);
    }

    return 'Rp ${negative ? '-' : ''}${buffer.toString()}';
  }

  String formatNumber(double value) {
    final rounded = value.round();
    final number = rounded.toString();

    final buffer = StringBuffer();

    for (int i = 0; i < number.length; i++) {
      if (i > 0 && (number.length - i) % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(number[i]);
    }

    return buffer.toString();
  }

  // ============================================================
  // DIGITAL CALCULATION
  // ============================================================

  void calculateDigital() {
    final beli = parseNumber(digitalBeliController.text);
    final jual = parseNumber(digitalJualController.text);
    final lot = parseNumber(digitalLotController.text);

    final selisih = jual - beli;

    // Sesuai formula Stitch:
    // Lot × Selisih × Rp 1.000.000
    final kotor = lot * selisih * 1000000;

    // Rp 300.000 / Lot
    final fee = 300000 * lot;

    // PPN 11% × Fee
    final pajak = 0.11 * fee;

    final net = kotor - fee - pajak;

    double percentage = 0;

    if (kotor > 0) {
      percentage = (net / kotor) * 100;
    }

    if (!mounted) return;

    setState(() {
      digitalSelisih = selisih;
      digitalKotor = kotor;
      digitalFee = fee;
      digitalPajak = pajak;
      digitalNet = net;
      digitalNetPercentage = percentage;
    });
  }

  // ============================================================
  // FISIK CALCULATION
  // ============================================================

  void calculateFisik() {
    final kurs = parseNumber(fisikKursController.text);
    final modal = parseNumber(fisikModalController.text);
    final beliUsd = parseNumber(fisikBeliController.text);
    final jualUsd = parseNumber(fisikJualController.text);

    // (USD × Kurs) / 31.10
    final beliPerGram = (beliUsd * kurs) / tozFixed;
    final jualPerGram = (jualUsd * kurs) / tozFixed;

    final selisihGram = jualPerGram - beliPerGram;

    double jumlahGram = 0;

    if (beliPerGram > 0) {
      jumlahGram = modal / beliPerGram;
    }

    final cuan = selisihGram * jumlahGram;

    final totalNilaiJual = modal + cuan;

    double roi = 0;

    if (modal > 0) {
      roi = (cuan / modal) * 100;
    }

    if (!mounted) return;

    setState(() {
      fisikBeliPerGram = beliPerGram;
      fisikJualPerGram = jualPerGram;
      fisikSelisihPerGram = selisihGram;
      fisikJumlahGram = jumlahGram;
      fisikCuan = cuan;
      fisikTotalNilai = totalNilaiJual;
      fisikRoi = roi;
    });
  }

  // ============================================================
  // RESET
  // ============================================================

  void resetCalculator() {
    digitalBeliController.text = '1450000';
    digitalJualController.text = '1465000';
    digitalLotController.text = '5';

    fisikKursController.text = '16250';
    fisikModalController.text = '100000000';
    fisikBeliController.text = '2380';
    fisikJualController.text = '2410';

    calculateDigital();
    calculateFisik();
  }

  // ============================================================
  // SET LOT
  // ============================================================

  void setDigitalLot(int value) {
    digitalLotController.text = value.toString();
  }

  // ============================================================
  // MAIN BUILD
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
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                child: Column(
                  children: [
                    _buildTopUtility(),
                    const SizedBox(height: 12),
                    _buildTabs(),
                    const SizedBox(height: 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: selectedTab == 0
                          ? _buildDigitalSection()
                          : _buildFisikSection(),
                    ),
                    const SizedBox(height: 16),
                    _buildHistorySection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FRONTEND CALCULATION HISTORY
  // ============================================================

  void _saveCalculationToHistory() {
    final now = DateTime.now();
    final Map<String, dynamic> item;

    if (selectedTab == 0) {
      item = {
        'type': 'Emas Digital',
        'date': now,
        'details': 'Beli ${formatRupiah(parseNumber(digitalBeliController.text))} • '
            'Jual ${formatRupiah(parseNumber(digitalJualController.text))} • '
            'Lot ${digitalLotController.text}',
        'result': formatRupiah(digitalNet),
        'positive': digitalNet >= 0,
      };
    } else {
      item = {
        'type': 'Emas Fisik',
        'date': now,
        'details': 'Modal ${formatRupiah(parseNumber(fisikModalController.text))} • '
            'Kurs ${formatNumber(parseNumber(fisikKursController.text))} • '
            'ROI ${fisikRoi.toStringAsFixed(2)}%',
        'result': formatRupiah(fisikCuan),
        'positive': fisikCuan >= 0,
      };
    }

    setState(() {
      _calculationHistory.insert(0, item);
      _showHistory = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perhitungan ditambahkan ke histori sesi ini.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildHistorySection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EAF2)),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _showHistory = !_showHistory),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7BD48).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.history_rounded,
                        color: Color(0xFF785600)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Histori Perhitungan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0B1C30),
                            )),
                        const SizedBox(height: 3),
                        Text('${_calculationHistory.length} perhitungan di sesi ini',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: const Color(0xFF718096),
                            )),
                      ],
                    ),
                  ),
                  Icon(_showHistory ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: const Color(0xFF64748B)),
                ],
              ),
            ),
          ),
          if (_showHistory) ...[
            const Divider(height: 1, color: Color(0xFFE5EAF2)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveCalculationToHistory,
                      icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                      label: const Text('Simpan Perhitungan Saat Ini'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF213145),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_calculationHistory.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 22),
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 34, color: Colors.blueGrey.shade200),
                          const SizedBox(height: 8),
                          Text('Belum ada histori perhitungan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: const Color(0xFF718096),
                              )),
                          const SizedBox(height: 4),
                          Text('Tekan tombol di atas untuk menyimpan hasil.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: const Color(0xFF94A3B8),
                              )),
                        ],
                      ),
                    )
                  else
                    ..._calculationHistory.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final date = item['date'] as DateTime;
                      final dateText = '${date.day.toString().padLeft(2, '0')}/'
                          '${date.month.toString().padLeft(2, '0')}/${date.year} '
                          '${date.hour.toString().padLeft(2, '0')}:'
                          '${date.minute.toString().padLeft(2, '0')}';
                      final isPositive = item['positive'] as bool;
                      return Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEDF0F5)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7BD48).withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                item['type'] == 'Emas Digital'
                                    ? Icons.show_chart_rounded
                                    : Icons.savings_outlined,
                                color: const Color(0xFF785600), size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['type'] as String,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF213145),
                                      )),
                                  const SizedBox(height: 3),
                                  Text(dateText,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        color: const Color(0xFF94A3B8),
                                      )),
                                  const SizedBox(height: 5),
                                  Text(item['details'] as String,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        color: const Color(0xFF64748B),
                                      )),
                                  const SizedBox(height: 5),
                                  Text(item['result'] as String,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isPositive
                                            ? const Color(0xFF087443)
                                            : const Color(0xFFB42318),
                                      )),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Hapus histori',
                              visualDensity: VisualDensity.compact,
                              onPressed: () => setState(() => _calculationHistory.removeAt(index)),
                              icon: const Icon(Icons.close_rounded, size: 18),
                              color: const Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                      );
                    }),
                  if (_calculationHistory.isNotEmpty)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => setState(() => _calculationHistory.clear()),
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('Hapus semua'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFB42318),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF).withValues(alpha: 0.95),
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
         IconButton(
  onPressed: () {
    Navigator.pop(context);
  },
  icon: const Icon(
    Icons.arrow_back_ios_new_rounded,
    size: 20,
    color: Color(0xFF111827),
  ),
  tooltip: 'Kembali',
),
          const SizedBox(width: 4),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF785600).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calculate,
              color: Color(0xFF785600),
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KALKULATOR',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0B1C30),
                  ),
                ),
                Text(
                  'PT EQUITYWORLD FUTURES',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF785600),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: resetCalculator,
            tooltip: 'Reset',
            icon: const Icon(Icons.restart_alt),
            color: const Color(0xFF4F4535),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOP UTILITY
  // ============================================================

  Widget _buildTopUtility() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF785600).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calculate,
              color: Color(0xFF785600),
              size: 23,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Simulasi Portofolio Emas',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0B1C30),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF006947),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'Multi-Variable Calculation Engine',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4F4535),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: resetCalculator,
            icon: const Icon(Icons.restart_alt, size: 16),
            label: const Text('Reset'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4F4535),
              backgroundColor: const Color(0xFFE5EEFF),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABS
  // ============================================================

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _calcTab(
              index: 0,
              icon: Icons.currency_bitcoin,
              title: 'Emas Digital',
              badge: 'LOT',
            ),
          ),
          Expanded(
            child: _calcTab(
              index: 1,
              icon: Icons.edit_note,
              title: 'Emas Fisik',
              badge: 'TOZ',
            ),
          ),
        ],
      ),
    );
  }

  Widget _calcTab({
    required int index,
    required IconData icon,
    required String title,
    required String badge,
  }) {
    final selected = selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          vertical: 11,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF213145)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected
                  ? Colors.white
                  : const Color(0xFF4F4535),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : const Color(0xFF4F4535),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF785600).withValues(alpha: 0.25)
                    : const Color(0xFFD3E4FE),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badge,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? const Color(0xFFF7BD48)
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
  // DIGITAL SECTION
  // ============================================================

  Widget _buildDigitalSection() {
    return Column(
      key: const ValueKey('digital'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDigitalBanner(),
        const SizedBox(height: 12),
        _buildDigitalParameters(),
        const SizedBox(height: 12),
        _buildDigitalResultCards(),
        const SizedBox(height: 12),
        _buildDigitalNetCard(),
        const SizedBox(height: 12),
        _buildDigitalFormula(),
      ],
    );
  }

  // ============================================================
  // DIGITAL BANNER
  // ============================================================

  Widget _buildDigitalBanner() {
    return Container(
      width: double.infinity,
      height: 96,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF213145),
            Color(0xFF344B63),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF7BD48).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.currency_bitcoin,
              color: Color(0xFFF7BD48),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KONTRAK BERJANGKA DIGITAL',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: const Color(0xFFF7BD48),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Perhitungan Kontrak Lot & Net Bersih',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
  // DIGITAL PARAMETERS
  // ============================================================

  Widget _buildDigitalParameters() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Parameter Transaksi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0B1C30),
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00855B).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '1 Lot = Rp 1jt × Δ',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF006947),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _calculatorInput(
            label: 'Harga Beli / Unit',
            prefix: 'Rp',
            controller: digitalBeliController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          _calculatorInput(
            label: 'Harga Jual / Unit',
            prefix: 'Rp',
            controller: digitalJualController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _calculatorInput(
                  label: 'Volume Kontrak',
                  suffix: 'Lot',
                  controller: digitalLotController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                margin: const EdgeInsets.only(top: 18),
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF785600).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  '${parseNumber(digitalLotController.text).round()} Lot',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF785600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Preset Lot:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4F4535),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [1, 2, 5, 10, 20].map((lot) {
                      final selected =
                          parseNumber(digitalLotController.text).round() ==
                              lot;

                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          onTap: () => setDigitalLot(lot),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFF785600).withValues(
                                      alpha: 0.10,
                                    )
                                  : const Color(0xFFE5EEFF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$lot Lot',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: selected
                                    ? const Color(0xFF785600)
                                    : const Color(0xFF0B1C30),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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
  // DIGITAL RESULT CARDS
  // ============================================================

  Widget _buildDigitalResultCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.32,
      children: [
        _resultCard(
          title: 'Spread / Selisih',
          value: formatRupiah(digitalSelisih),
          subtitle: 'Jual - Beli',
          icon: Icons.trending_up,
          iconColor: const Color(0xFF006947),
        ),
        _resultCard(
          title: 'Hasil Kotor',
          value: formatRupiah(digitalKotor),
          subtitle: 'Lot × Selisih × 1jt',
          icon: Icons.pie_chart_outline,
          iconColor: const Color(0xFF785600),
        ),
        _resultCard(
          title: 'Broker Fee',
          value: formatRupiah(digitalFee),
          subtitle: 'Rp 300.000 / Lot',
          icon: Icons.receipt_long,
          iconColor: const Color(0xFF565E74),
          valueColor: const Color(0xFFBA1A1A),
        ),
        _resultCard(
          title: 'Pajak (PPN 11%)',
          value: formatRupiah(digitalPajak),
          subtitle: '11% × Total Fee',
          icon: Icons.account_balance,
          iconColor: const Color(0xFF565E74),
          valueColor: const Color(0xFFBA1A1A),
        ),
      ],
    );
  }

  // ============================================================
  // DIGITAL NET CARD
  // ============================================================

  Widget _buildDigitalNetCard() {
    final positive = digitalNet >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF213145),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            bottom: -35,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF7BD48).withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: positive
                          ? const Color(0xFF4EDEA3)
                          : const Color(0xFFFF6B6B),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'HASIL AKHIR BERSIH (NET PROFIT)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: const Color(0xFFF7BD48),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00855B).withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${digitalNetPercentage >= 0 ? '+' : ''}${digitalNetPercentage.toStringAsFixed(2)}% Net',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4EDEA3),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                formatRupiah(digitalNet),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFF8F9FF),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Setelah dikurangi Beban Fee & PPN',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: const Color(0xFFCBDBF5),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Kotor: ${formatRupiah(digitalKotor)}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        color: const Color(0xFFEAF1FF),
                      ),
                    ),
                  ),
                  Text(
                    'Potongan: -${formatRupiah(digitalFee + digitalPajak)}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      color: const Color(0xFFFF8A8A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Row(
                  children: [
                    Expanded(
                      flex: digitalKotor > 0
                          ? digitalNet.clamp(0, digitalKotor).round()
                          : 1,
                      child: Container(
                        height: 7,
                        color: const Color(0xFF4EDEA3),
                      ),
                    ),
                    Expanded(
                      flex: digitalKotor > 0
                          ? (digitalKotor - digitalNet)
                              .clamp(0, digitalKotor)
                              .round()
                          : 1,
                      child: Container(
                        height: 7,
                        color: const Color(0xFFBA1A1A),
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

  // ============================================================
  // DIGITAL FORMULA
  // ============================================================

  Widget _buildDigitalFormula() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 18,
                color: Color(0xFF785600),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Formula Standardisasi Digital (BBJ / ICDX)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0B1C30),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          _formulaRow(
            '1. Selisih Point',
            'Harga Jual − Harga Beli',
          ),
          const SizedBox(height: 5),
          _formulaRow(
            '2. Gross Revenue',
            'Lot × Selisih × Rp 1.000.000',
          ),
          const SizedBox(height: 5),
          _formulaRow(
            '3. Total Biaya Operasional',
            'Fee (Rp300k/Lot) + PPN (11%)',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FISIK SECTION
  // ============================================================

  Widget _buildFisikSection() {
    return Column(
      key: const ValueKey('fisik'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFisikBanner(),
        const SizedBox(height: 12),
        _buildTozNotice(),
        const SizedBox(height: 12),
        _buildFisikParameters(),
        const SizedBox(height: 12),
        _buildFisikResultCards(),
        const SizedBox(height: 12),
        _buildFisikNetCard(),
        const SizedBox(height: 12),
        _buildFisikFootnote(),
      ],
    );
  }

  // ============================================================
  // FISIK BANNER
  // ============================================================

  Widget _buildFisikBanner() {
    return Container(
      width: double.infinity,
      height: 96,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF213145),
            Color(0xFF344B63),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF7BD48).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: Color(0xFFF7BD48),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SPOT PHYSICAL GOLD / LM',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: const Color(0xFFF7BD48),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Konversi Troy Ounce & Valuasi Rupiah',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
  // TOZ NOTICE
  // ============================================================

  Widget _buildTozNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF785600).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lock_outline,
            color: Color(0xFF785600),
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Standar Bobot Tetap',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0B1C30),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Troy Ounce Internasional (Non-Editable)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: const Color(0xFF4F4535),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '31.10 Gram',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF785600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FISIK PARAMETERS
  // ============================================================

  Widget _buildFisikParameters() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Parameter Pembelian Fisik',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0B1C30),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00855B).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'USD/IDR Live Basis',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF006947),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _calculatorInput(
            label: 'Kurs Tukar Dollar (USD/IDR)',
            prefix: 'Rp',
            controller: fisikKursController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          _calculatorInput(
            label: 'Modal Alokasi Tunai',
            prefix: 'Rp',
            controller: fisikModalController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          _calculatorInput(
            label: 'Harga Beli Spot (USD / oz)',
            prefix: '\$',
            controller: fisikBeliController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
          ),
          const SizedBox(height: 10),
          _calculatorInput(
            label: 'Harga Jual Spot (USD / oz)',
            prefix: '\$',
            controller: fisikJualController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FISIK RESULT CARDS
  // ============================================================

  Widget _buildFisikResultCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.28,
      children: [
        _resultCard(
          title: 'Beli / Gram',
          value: formatRupiah(fisikBeliPerGram),
          subtitle: '(USD × Kurs) / 31.1',
          icon: Icons.sell_outlined,
          iconColor: const Color(0xFF4F4535),
        ),
        _resultCard(
          title: 'Jual / Gram',
          value: formatRupiah(fisikJualPerGram),
          subtitle: '(USD × Kurs) / 31.1',
          icon: Icons.shopping_cart_outlined,
          iconColor: const Color(0xFF4F4535),
        ),
        _resultCard(
          title: 'Selisih / Gram',
          value:
              '${fisikSelisihPerGram >= 0 ? '+' : '-'}${formatRupiah(fisikSelisihPerGram.abs())}',
          subtitle: 'Margin Kotor Fisik',
          icon: Icons.trending_up,
          iconColor: const Color(0xFF006947),
          valueColor: const Color(0xFF006947),
        ),
        _resultCard(
          title: 'Total Gram Didapat',
          value: '${fisikJumlahGram.toStringAsFixed(2)} gr',
          subtitle: 'Modal / Beli Gram',
          icon: Icons.scale_outlined,
          iconColor: const Color(0xFF785600),
          valueColor: const Color(0xFF785600),
        ),
      ],
    );
  }

  // ============================================================
  // FISIK NET CARD
  // ============================================================

  Widget _buildFisikNetCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF213145),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            bottom: -35,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00855B).withValues(alpha: 0.10),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 9,
                    height: 9,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFFF7BD48),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ESTIMASI KEUNTUNGAN BERSIH',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: const Color(0xFFF7BD48),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00855B).withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${fisikRoi >= 0 ? '+' : ''}${fisikRoi.toStringAsFixed(2)}% ROI',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4EDEA3),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                formatRupiah(fisikCuan),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFF8F9FF),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Selisih/Gram × Bobot Didapat',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: const Color(0xFFCBDBF5),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.scale,
                      size: 16,
                      color: Color(0xFFF7BD48),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'Valuasi Penjualan Fisik:',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: const Color(0xFFEAF1FF),
                        ),
                      ),
                    ),
                    Text(
                      formatRupiah(fisikTotalNilai),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF8F9FF),
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

  // ============================================================
  // FISIK FOOTNOTE
  // ============================================================

  Widget _buildFisikFootnote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.help_outline,
            size: 20,
            color: Color(0xFF4F4535),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catatan Konversi Fisik',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0B1C30),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Perhitungan mengasumsikan transaksi bullion murni '
                  '24 Karat (99.99%). Standar satuan troy ounce (oz) '
                  'konstan di 31.1035 gram. Biaya cetak & sertifikasi '
                  '(Antam/UBS) tidak diperhitungkan.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    height: 1.45,
                    color: const Color(0xFF4F4535),
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
  // GENERAL SECTION CARD
  // ============================================================

  Widget _sectionCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 4,
          ),
        ],
      ),
      child: child,
    );
  }

  // ============================================================
  // INPUT
  // ============================================================

  Widget _calculatorInput({
    required String label,
    required TextEditingController controller,
    String? prefix,
    String? suffix,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF4F4535),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEFF4FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              if (prefix != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    prefix,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4F4535),
                    ),
                  ),
                ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9.]'),
                    ),
                  ],
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF0B1C30),
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Masukkan nilai',
                    hintStyle: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: const Color(0xFF817563),
                    ),
                    contentPadding: EdgeInsets.only(
                      left: prefix == null ? 12 : 8,
                      right: suffix == null ? 12 : 8,
                      top: 11,
                      bottom: 11,
                    ),
                  ),
                ),
              ),
              if (suffix != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    suffix,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4F4535),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // RESULT CARD
  // ============================================================

  Widget _resultCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF4F4535),
                  ),
                ),
              ),
              Icon(
                icon,
                size: 16,
                color: iconColor,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? const Color(0xFF0B1C30),
                ),
              ),
            ),
          ),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 8,
              color: const Color(0xFF817563),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FORMULA ROW
  // ============================================================

  Widget _formulaRow(
    String title,
    String formula,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: const Color(0xFF4F4535),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              formula,
              textAlign: TextAlign.right,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF0B1C30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
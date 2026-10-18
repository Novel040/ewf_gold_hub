import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'berita_page.dart';
import 'harga_emas_page.dart';
import 'pivot_point_page.dart';
import 'kalkulator_page.dart';
import 'histori_page.dart';
import 'informasi_pt_page.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import '../widgets/live_quotes_table.dart';
import '../widgets/latest_news_section.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const Color background = Color(0xFFF8FAFC);
  static const Color white = Color(0xFFFFFFFF);

  // Tema utama EWF
  static const Color primary = Color(0xFFF58220);
  static const Color primaryContainer = Color(0xFFD96812);

  // Permukaan dan kartu
  static const Color surfaceContainer = Color(0xFFFFE5CC);
  static const Color surfaceContainerLow = Color(0xFFFFF3E8);

  // Warna teks
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF64748B);

  // Warna indikator pasar tetap dipertahankan
  static const Color green = Color(0xFF00866A);
  static const Color red = Color(0xFFD64545);

  TextStyle jakarta({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = textPrimary,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  TextStyle mono({
    double size = 13,
    FontWeight weight = FontWeight.w500,
    Color color = textPrimary,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // ============================================================
      // APP BAR
      // ============================================================
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.trending_up, color: primary),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EQUITY PULSE',
                  style: jakarta(size: 16, weight: FontWeight.w700),
                ),
                Text(
                  'MARKET INTELLIGENCE',
                  style: jakarta(
                    size: 9,
                    weight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.notifications_none, color: textPrimary),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: surfaceContainer,
                child: Text(
                  'A',
                  style: jakarta(
                    size: 13,
                    weight: FontWeight.w700,
                    color: primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // ============================================================
      // DRAWER
      // ============================================================
      drawer: _buildDrawer(context),

      // ============================================================
      // BODY
      // ============================================================
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcome(),
              const SizedBox(height: 16),

              // Grafik dan tabel khusus instrumen XUL dan HKK
              _buildLiveChart(
                title: 'XUL',
                subtitle: 'Loco London Gold',
                color: primary,
              ),
              const SizedBox(height: 16),
              _buildLiveChart(
                title: 'HKK',
                subtitle: 'Hang Seng Index Futures',
                color: primary,
              ),
              const SizedBox(height: 20),
              _buildLiveQuotesTable(),
              const SizedBox(height: 16),
              _buildQuickMenu(context),
              const SizedBox(height: 20),
              const LatestNewsSection(),
              const SizedBox(height: 16),
              _buildInformationCard(),
            ],
          ),
        ),
      ),

      // ============================================================
      // BOTTOM NAVIGATION
      // ============================================================
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }
  // ============================================================
  // DRAWER
  // ============================================================
  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigation(BuildContext context) {
    final items = [
      (icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Dashboard'),
      (
        icon: Icons.newspaper_outlined,
        activeIcon: Icons.newspaper,
        label: 'Berita',
      ),
      (icon: Icons.show_chart, activeIcon: Icons.show_chart, label: 'Harga'),
      (
        icon: Icons.table_chart_outlined,
        activeIcon: Icons.table_chart,
        label: 'Pivot',
      ),
      (
        icon: Icons.calculate_outlined,
        activeIcon: Icons.calculate,
        label: 'Kalkulator',
      ),
      (
        icon: Icons.history_outlined,
        activeIcon: Icons.history,
        label: 'Histori',
      ),
      (
        icon: Icons.apartment_outlined,
        activeIcon: Icons.apartment,
        label: 'Profil PT',
      ),
    ];

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(items.length, (index) {
              final active = index == 0;

              return SizedBox(
                width: 82,
                child: InkWell(
                  onTap: () {
                    switch (index) {
                      case 0:
                        break;

                      case 1:
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BeritaPage(),
                          ),
                        );
                        break;

                      case 2:
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HargaEmasPage(),
                          ),
                        );
                        break;

                      case 3:
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PivotPointPage(),
                          ),
                        );
                        break;

                      case 4:
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const KalkulatorPage(),
                          ),
                        );
                        break;

                      case 5:
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HistoriPage(),
                          ),
                        );
                        break;

                      case 6:
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InformasiPtPage(),
                          ),
                        );
                        break;
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        active ? items[index].activeIcon : items[index].icon,
                        size: 21,
                        color: active ? primary : const Color(0xFF9CA3AF),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[index].label,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: active
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: active ? primary : const Color(0xFF9CA3AF),
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

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [primaryContainer, primary]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.trending_up, color: Colors.white, size: 36),
                  const SizedBox(height: 10),
                  Text(
                    'EWF GOLD HUB',
                    style: jakarta(
                      size: 20,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'PT EQUITYWORLD FUTURES',
                    style: jakarta(
                      size: 10,
                      weight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // ========================================================
            // DASHBOARD
            // ========================================================
            _drawerItem(
              icon: Icons.dashboard_outlined,
              title: 'Dashboard',
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),

            // ========================================================
            // BERITA EMAS
            // ========================================================
            _drawerItem(
              icon: Icons.newspaper_outlined,
              title: 'Berita Emas',
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BeritaPage()),
                );
              },
            ),

            // ========================================================
            // INFORMASI PT
            // ========================================================
            _drawerItem(
              icon: Icons.apartment_outlined,
              title: 'Informasi PT',
              hasArrow: true,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InformasiPtPage(),
                  ),
                );
              },
            ),

            // ========================================================
            // DATA HARGA EMAS
            // ========================================================
            _drawerItem(
              icon: Icons.show_chart_outlined,
              title: 'Data Harga Emas',
              hasArrow: true,
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HargaEmasPage(),
                  ),
                );
              },
            ),

            // ========================================================
            // PIVOT POINT
            // ========================================================
            _drawerItem(
              icon: Icons.analytics_outlined,
              title: 'Pivot Point',
              hasArrow: true,
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PivotPointPage(),
                  ),
                );
              },
            ),

            // ========================================================
            // KALKULATOR
            // ========================================================
            _drawerItem(
              icon: Icons.calculate_outlined,
              title: 'Kalkulator',
              hasArrow: true,
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const KalkulatorPage(),
                  ),
                );
              },
            ),
            // ========================================================
            // HISTORI
            // ========================================================
            _drawerItem(
              icon: Icons.history,
              title: 'Histori',
              hasArrow: true,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoriPage()),
                );
              },
            ),

            const Spacer(),
            const Divider(),

            // ========================================================
            // KELUAR
            // ========================================================
            _drawerItem(
              icon: Icons.logout_outlined,
              title: 'Keluar',
              onTap: () {
                Navigator.pop(context);
              },
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DRAWER ITEM
  // ============================================================

  Widget _drawerItem({
    required IconData icon,
    required String title,
    bool selected = false,
    bool hasArrow = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: selected ? surfaceContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          size: 21,
          color: selected ? primary : textSecondary,
        ),
        title: Text(
          title,
          style: jakarta(
            size: 13,
            weight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? primary : textPrimary,
          ),
        ),
        trailing: hasArrow
            ? const Icon(Icons.chevron_right, size: 18, color: textSecondary)
            : null,
        onTap: onTap,
      ),
    );
  }

  // ============================================================
  // WELCOME
  // ============================================================

  Widget _buildWelcome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dashboard', style: jakarta(size: 24, weight: FontWeight.w700)),
      ],
    );
  }

  // ============================================================
  // LIVE CHART PLACEHOLDER
  // ============================================================

  Widget _buildLiveChart({
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final bool isGold = title.toUpperCase().contains('XUL');
    final String symbol = isGold ? 'OANDA:XAUUSD' : 'TVC:HSI';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: surfaceContainer),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(Icons.show_chart, color: color, size: 23),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: jakarta(size: 17, weight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: jakarta(size: 11, color: textSecondary),
                    ),
                  ],
                ),
              ),
              const Text(
                'TRADINGVIEW',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2962FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(height: 320, child: _TradingViewChart(symbol: symbol)),
          const SizedBox(height: 8),
          Text(
            'Grafik dari TradingView. Harga dan ketersediaan simbol mengikuti penyedia data.',
            style: jakarta(size: 10, color: textSecondary),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LIVE QUOTES TABLE
  // ============================================================

  Widget _buildLiveQuotesTable() {
    return const LiveQuotesTable();
  }

  // ============================================================
  // PRICE CARD METHODS REMOVED
  // OPEN/HIGH/LOW/CLOSE and old HSI cards are no longer displayed.
  // ============================================================

  // ============================================================
  // MARKET SUMMARY
  // ============================================================

  // ============================================================
  // QUICK MENU
  // ============================================================

  Widget _buildQuickMenu(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Akses Cepat', style: jakarta(size: 16, weight: FontWeight.w700)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _quickButton(
                Icons.analytics_outlined,
                'Pivot Point',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PivotPointPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _quickButton(Icons.calculate_outlined, 'Kalkulator'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _quickButton(
                Icons.history,
                'Histori',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoriPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // QUICK BUTTON
  // ============================================================

  Widget _quickButton(IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: surfaceContainer),
        ),
        child: Column(
          children: [
            Icon(icon, color: primary, size: 25),
            const SizedBox(height: 7),
            Text(
              title,
              textAlign: TextAlign.center,
              style: jakarta(size: 11, weight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFORMATION CARD
  // ============================================================

  Widget _buildInformationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi Data',
                  style: jakarta(size: 13, weight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Grafik dan tabel XUL/HKK memerlukan koneksi ke sumber data live yang valid.',
                  style: jakarta(size: 11, color: textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Class painter harus berada di luar DashboardPage.
  // Pastikan semua kode DashboardPage berakhir di sini.
}

class _TradingViewChart extends StatefulWidget {
  final String symbol;

  const _TradingViewChart({required this.symbol});

  @override
  State<_TradingViewChart> createState() => _TradingViewChartState();
}

class _TradingViewChartState extends State<_TradingViewChart> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFAFBFE))
      ..loadHtmlString(_html);
  }

  String get _html =>
      '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    html, body, #chart {
      margin: 0;
      padding: 0;
      width: 100%;
      height: 100%;
      overflow: hidden;
    }
  </style>
</head>
<body>
  <div id="chart"></div>
  <script src="https://s3.tradingview.com/tv.js"></script>
  <script>
    new TradingView.widget({
      autosize: true,
      symbol: "${widget.symbol}",
      interval: "15",
      timezone: "Asia/Jakarta",
      theme: "light",
      style: "1",
      locale: "id",
      enable_publishing: false,
      hide_top_toolbar: false,
      hide_legend: false,
      save_image: false,
      container_id: "chart"
    });
  </script>
</body>
</html>
''';

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}

class _DemoPriceChart extends StatelessWidget {
  final Color color;
  final List<double> prices;

  const _DemoPriceChart({required this.color, required this.prices});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DemoPriceChartPainter(color: color, prices: prices),
      child: const SizedBox.expand(),
    );
  }
}

class _DemoPriceChartPainter extends CustomPainter {
  final Color color;
  final List<double> prices;

  const _DemoPriceChartPainter({required this.color, required this.prices});

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.length < 2 || size.width <= 0 || size.height <= 0) {
      return;
    }

    const left = 12.0;
    const right = 12.0;
    const top = 20.0;
    const bottom = 24.0;

    final chart = Rect.fromLTRB(
      left,
      top,
      size.width - right,
      size.height - bottom,
    );

    if (chart.width <= 0 || chart.height <= 0) {
      return;
    }

    final gridPaint = Paint()
      ..color = color.withValues(alpha: 0.13)
      ..strokeWidth = 0.8;

    for (int i = 0; i <= 4; i++) {
      final y = chart.top + chart.height * i / 4;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), gridPaint);
    }

    for (int i = 0; i <= 6; i++) {
      final x = chart.left + chart.width * i / 6;
      canvas.drawLine(Offset(x, chart.top), Offset(x, chart.bottom), gridPaint);
    }

    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);
    final range = maxPrice - minPrice;
    final safeRange = range == 0 ? 1.0 : range;

    final points = List<Offset>.generate(prices.length, (i) {
      final x = chart.left + chart.width * i / (prices.length - 1);

      final normalized = (prices[i] - minPrice) / safeRange;

      final y = chart.bottom - chart.height * (0.10 + normalized * 0.78);

      return Offset(x, y);
    });

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final midX = (current.dx + next.dx) / 2;

      linePath.cubicTo(midX, current.dy, midX, next.dy, next.dx, next.dy);
    }

    final areaPath = Path.from(linePath)
      ..lineTo(points.last.dx, chart.bottom)
      ..lineTo(points.first.dx, chart.bottom)
      ..close();

    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.24),
            color.withValues(alpha: 0.01),
          ],
        ).createShader(chart),
    );

    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final last = points.last;

    final dashPaint = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..strokeWidth = 1;

    for (double x = last.dx; x < chart.right; x += 8) {
      canvas.drawLine(
        Offset(x, last.dy),
        Offset((x + 4).clamp(last.dx, chart.right), last.dy),
        dashPaint,
      );
    }

    canvas.drawCircle(last, 5, Paint()..color = Colors.white);

    canvas.drawCircle(last, 3, Paint()..color = color);

    final label = TextPainter(
      text: TextSpan(
        text: prices.last.toStringAsFixed(1),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    label.paint(
      canvas,
      Offset(
        (last.dx - label.width).clamp(chart.left, chart.right - label.width),
        (last.dy - label.height - 7).clamp(0.0, size.height - label.height),
      ),
    );

    const labels = ['09:00', '11:00', '13:00', '15:00'];

    for (int i = 0; i < labels.length; i++) {
      final text = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(color: Color(0xFF8993A4), fontSize: 8),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final x = chart.left + chart.width * i / (labels.length - 1);

      text.paint(
        canvas,
        Offset(
          (x - text.width / 2).clamp(0.0, size.width - text.width),
          chart.bottom + 7,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DemoPriceChartPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.prices != prices;
  }
}

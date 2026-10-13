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
import '../services/api_service.dart';
import '../models/gold_price.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const Color background = Color(0xFFF8F9FF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF785600);
  static const Color primaryContainer = Color(0xFF986D00);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color textPrimary = Color(0xFF0B1C30);
  static const Color textSecondary = Color(0xFF4F4535);
  static const Color green = Color(0xFF006947);
  static const Color red = Color(0xFFBA1A1A);

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

              // LGD
              _buildMarketStatus(),
              const SizedBox(height: 16),
              _buildPriceCards(),

              const SizedBox(height: 24),

              // HSI
              _buildHsiStatus(),
              const SizedBox(height: 16),
              _buildHsiPriceCards(),

              const SizedBox(height: 16),
              _buildQuickMenu(context),
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
                        color: active
                            ? const Color(0xFF111827)
                            : const Color(0xFF9CA3AF),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[index].label,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: active
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: active
                              ? const Color(0xFF111827)
                              : const Color(0xFF9CA3AF),
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
  // MARKET STATUS
  // ============================================================

  Widget _buildMarketStatus() {
    Widget marketCard({
      required String name,
      required String symbol,
      required IconData icon,
    }) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [primaryContainer, primary]),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 25),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: jakarta(
                      size: 18,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    symbol,
                    style: mono(
                      size: 12,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'ACTIVE',
                    style: jakarta(
                      size: 10,
                      weight: FontWeight.w700,
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

    
return Column(
  children: [
    marketCard(
      name: 'LGD',
      symbol: 'XAU / USD',
      icon: Icons.monetization_on_outlined,
    ),
  ],
);
}


  Widget _buildHsiStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [primaryContainer, primary]),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.show_chart, color: Colors.white, size: 25),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HSI',
                  style: jakarta(
                    size: 18,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'HANG SENG INDEX',
                  style: mono(
                    size: 12,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '• ACTIVE',
              style: jakarta(
                size: 10,
                weight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHsiPriceCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          _priceCard('OPEN', '—', 'Poin indeks', Icons.login),
          _priceCard(
            'HIGH',
            '—',
            'Poin indeks',
            Icons.arrow_upward,
            positive: true,
          ),
          _priceCard('LOW', '—', 'Poin indeks', Icons.arrow_downward),
          _priceCard(
            'CLOSE',
            '—',
            'Poin indeks',
            Icons.flag_outlined,
            positive: true,
          ),
        ];

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: 12),
                Expanded(child: cards[1]),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: cards[2]),
                const SizedBox(width: 12),
                Expanded(child: cards[3]),
              ],
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // PRICE CARDS
  // ============================================================

  Widget _buildPriceCards() {
    return FutureBuilder<List<GoldPrice>>(
      future: ApiService.getGoldPrices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Gagal memuat harga emas.'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DashboardPage(),
                        ),
                      );
                    },
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        final prices = snapshot.data ?? [];

        if (prices.isEmpty) {
          return const Text('Belum ada data harga emas.');
        }

        final gold = prices.first;

        String formatPrice(double? value) {
          if (value == null) return '-';
          return value.toStringAsFixed(2);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;

            final cards = [
              _priceCard('OPEN', formatPrice(gold.open), 'USD/oz', Icons.login),
              _priceCard(
                'HIGH',
                formatPrice(gold.high),
                'USD/oz',
                Icons.arrow_upward,
                positive: true,
              ),
              _priceCard(
                'LOW',
                formatPrice(gold.low),
                'USD/oz',
                Icons.arrow_downward,
              ),
              _priceCard(
                'CLOSE',
                formatPrice(gold.close ?? gold.price),
                'USD/oz',
                Icons.flag_outlined,
                positive: true,
              ),
            ];

            if (isWide) {
              return Row(
                children: [
                  for (int i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(child: cards[i]),
                  ],
                ],
              );
            }

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: cards[0]),
                    const SizedBox(width: 12),
                    Expanded(child: cards[1]),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: cards[2]),
                    const SizedBox(width: 12),
                    Expanded(child: cards[3]),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _priceCard(
    String title,
    String value,
    String unit,
    IconData icon, {
    bool positive = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            offset: Offset(0, 2),
            color: Color(0x10000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: positive ? green : primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: jakarta(
                    size: 10,
                    weight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: mono(size: 20, weight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(unit, style: jakarta(size: 10, color: textSecondary)),
        ],
      ),
    );
  }

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
                  'Data harga emas ditampilkan berdasarkan data yang tersedia pada sistem. Sumber data: News Maker.',
                  style: jakarta(size: 11, color: textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

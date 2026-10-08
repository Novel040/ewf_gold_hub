import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dashboard_page.dart';
import 'harga_emas_page.dart';
import 'pivot_point_page.dart';
import 'kalkulator_page.dart';
import 'histori_page.dart';
import 'informasi_pt_page.dart';

class BeritaPage extends StatefulWidget {
  const BeritaPage({super.key});

  @override
  State<BeritaPage> createState() => _BeritaPageState();
}

class _BeritaPageState extends State<BeritaPage> {
  int selectedCategory = 0;
  int selectedPage = 1;

  final List<String> categories = [
    'Semua Berita',
    'Kebijakan The Fed & Inflasi',
    'Permintaan Fisik & Bank Sentral',
    'Produksi Emas Domestik',
  ];

  final List<IconData> categoryIcons = [
    Icons.all_inclusive,
    Icons.account_balance,
    Icons.assured_workload,
    Icons.factory,
  ];

  List<Map<String, dynamic>> news = [];

  bool isLoadingNews = true;
  String newsError = '';

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2/api/news'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          news = data.map<Map<String, dynamic>>((item) {
            return {
              'image': item['image'] ?? '',
              'category': item['category'] ?? 'Emas',
              'source': item['source'] ?? 'Newsmaker.id',
              'date': item['published_at'] ?? '',
              'title': item['title'] ?? '',
              'description': item['content'] ?? '',
              'metric': '-',
              'metric1Value': '-',
              'metric2Value': '-',
            };
          }).toList();

          isLoadingNews = false;
          newsError = '';
        });
      } else {
        setState(() {
          isLoadingNews = false;
          newsError = 'Gagal mengambil berita (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        isLoadingNews = false;
        newsError = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMarketFlash(),
                    _buildEditorialHeader(),
                    _buildCategoryFilter(),
                    _buildNewsFeed(),
                    _buildWeeklyDigest(),
                    _buildPagination(),
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

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
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
          // =========================
          // BACK BUTTON
          // =========================
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

          // =========================
          // LOGO
          // =========================
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF785600),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.show_chart, color: Colors.white, size: 23),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'EQUITY PULSE',
                      style: TextStyle(
                        color: Color(0xFF0B1C30),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00855B).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF006947),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Market Open',
                            style: TextStyle(
                              color: Color(0xFF006947),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                const Text(
                  'PT EQUITYWORLD FUTURES • FUTURES MARKET INTELLIGENCE',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF4F4535),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
              color: Color(0xFF4F4535),
              size: 23,
            ),
          ),

          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF785600).withValues(alpha: 0.20),
                width: 2,
              ),
            ),
            child: const CircleAvatar(
              backgroundColor: Color(0xFFD3E4FE),
              child: Icon(Icons.person, size: 18, color: Color(0xFF0B1C30)),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MARKET FLASH
  // ============================================================

  Widget _buildMarketFlash() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE9FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFF006947),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.bolt, color: Color(0xFF785600), size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  color: Color(0xFF0B1C30),
                  fontSize: 13,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: 'Kilas Pasar: ',
                    style: TextStyle(
                      color: Color(0xFF785600),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text:
                        'XAU/USD berkonsolidasi kuat di area psikologis \$2,380/oz menjelang FOMC.',
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EDITORIAL HEADER
  // ============================================================

  Widget _buildEditorialHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE5EEFF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.feed_outlined, size: 16, color: Color(0xFF785600)),
                SizedBox(width: 5),
                Text(
                  'COMMODITY INTELLIGENCE',
                  style: TextStyle(
                    color: Color(0xFF4F4535),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.7,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Berita Emas & Wawasan Komoditas',
            style: TextStyle(
              color: Color(0xFF0B1C30),
              fontSize: 24,
              height: 1.25,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Informasi dan analisis fundamental pasar emas fisik dan berjangka terkurasi harian',
            style: TextStyle(
              color: Color(0xFF4F4535),
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORY FILTER
  // ============================================================

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 58,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final selected = selectedCategory == index;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF785600)
                      : const Color(0xFFE5EEFF),
                  borderRadius: BorderRadius.circular(30),
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
                  children: [
                    Icon(
                      categoryIcons[index],
                      size: 16,
                      color: selected ? Colors.white : const Color(0xFF4F4535),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      categories[index],
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : const Color(0xFF4F4535),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // NEWS FEED
  // ============================================================

  Widget _buildNewsFeed() {
    // =========================
    // LOADING
    // =========================
    if (isLoadingNews) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // =========================
    // ERROR
    // =========================
    if (newsError.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: Color(0xFF785600),
            ),
            const SizedBox(height: 12),
            Text(
              newsError,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF4F4535), fontSize: 13),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadNews,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    // =========================
    // DATA KOSONG
    // =========================
    if (news.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        child: Center(
          child: Text(
            'Belum ada berita.',
            style: TextStyle(color: Color(0xFF4F4535), fontSize: 13),
          ),
        ),
      );
    }

    // =========================
    // BERITA BERHASIL DIMUAT
    // =========================
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Berita utama
          _buildFeaturedNews(news[0]),

          // Berita kedua
          if (news.length > 1) ...[
            const SizedBox(height: 16),
            _buildCompactNews(news[1]),
          ],

          // Berita ketiga
          if (news.length > 2) ...[
            const SizedBox(height: 16),
            _buildCompactNews(news[2]),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // FEATURED NEWS
  // ============================================================

  Widget _buildFeaturedNews(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 210,
                width: double.infinity,
                child: Image.network(
                  item['image'] ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _imagePlaceholder();
                  },
                ),
              ),
              Positioned(
                left: 14,
                bottom: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF785600),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item['category'].toString().toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSourceDate(item['source'], item['date'], Icons.business),
                const SizedBox(height: 9),
                Text(
                  item['title'],
                  style: const TextStyle(
                    color: Color(0xFF0B1C30),
                    fontSize: 16,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['description'],
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF4F4535),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 13),
                _buildFeaturedMetrics(item),
                const SizedBox(height: 14),
                _buildNewsActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMPACT NEWS
  // ============================================================

  Widget _buildCompactNews(Map<String, dynamic> item) {
    final bool derivative = item['category'] == 'Derivatif';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: 180,
                width: double.infinity,
                child: Image.network(
                  item['image'] ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _imagePlaceholder();
                  },
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: derivative
                        ? const Color(0xFF565E74)
                        : const Color(0xFF006947),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item['category'].toString().toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSourceDate(
                  item['source'],
                  item['date'],
                  derivative ? Icons.newspaper : Icons.storefront,
                ),
                const SizedBox(height: 9),
                Text(
                  item['title'],
                  style: const TextStyle(
                    color: Color(0xFF0B1C30),
                    fontSize: 16,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['description'],
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF4F4535),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: derivative
                              ? const Color(0xFFE5EEFF)
                              : const Color(0xFFE8F7F0),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          derivative
                              ? 'Support: ${item['metric']}'
                              : 'Spot Antam: ${item['metric']}',
                          style: TextStyle(
                            color: derivative
                                ? const Color(0xFF4F4535)
                                : const Color(0xFF006947),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildReadButton(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // ============================================================
  // SOURCE + DATE
  // ============================================================

  Widget _buildSourceDate(String source, String date, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF785600)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            source,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF4F4535),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            date,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF565E74),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FEATURED METRICS
  // ============================================================

  Widget _buildFeaturedMetrics(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Akuisisi',
                  style: TextStyle(color: Color(0xFF4F4535), fontSize: 10),
                ),
                const SizedBox(height: 3),
                Text(
                  item['metric1Value'],
                  style: const TextStyle(
                    color: Color(0xFF785600),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 35, color: const Color(0xFFD3E4FE)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sentimen Institusi',
                    style: TextStyle(color: Color(0xFF4F4535), fontSize: 10),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.trending_up,
                        size: 15,
                        color: Color(0xFF006947),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        item['metric2Value'],
                        style: const TextStyle(
                          color: Color(0xFF006947),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NEWS ACTIONS
  // ============================================================

  Widget _buildNewsActions() {
    return Row(
      children: [
        _roundActionButton(Icons.bookmark_border),
        const SizedBox(width: 7),
        _roundActionButton(Icons.share_outlined),
        const Spacer(),
        ElevatedButton(
          onPressed: _showArticleDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF785600),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Baca Selengkapnya',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 5),
              Icon(Icons.arrow_forward, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReadButton() {
    return ElevatedButton(
      onPressed: _showArticleDialog,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE5EEFF),
        foregroundColor: const Color(0xFF0B1C30),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Baca',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
          SizedBox(width: 3),
          Icon(Icons.chevron_right, size: 16),
        ],
      ),
    );
  }

  Widget _roundActionButton(IconData icon) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
          color: Color(0xFFE5EEFF),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF4F4535)),
      ),
    );
  }

  // ============================================================
  // WEEKLY DIGEST
  // ============================================================

  Widget _buildWeeklyDigest() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFDCE9FF), Color(0xFFE5EEFF), Color(0xFFEFF4FF)],
        ),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF785600),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buletin Pasar Mingguan',
                  style: TextStyle(
                    color: Color(0xFF0B1C30),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Dapatkan rekap Pivot Point & sentimen harga emas setiap Senin pagi.',
                  style: TextStyle(
                    color: Color(0xFF4F4535),
                    fontSize: 11,
                    height: 1.4,
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
  // PAGINATION
  // ============================================================

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton.icon(
            onPressed: selectedPage > 1
                ? () {
                    setState(() {
                      selectedPage--;
                    });
                  }
                : null,
            icon: const Icon(Icons.arrow_back_ios, size: 14),
            label: const Text('Previous'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF4F4535),
              backgroundColor: Colors.white,
              side: BorderSide.none,
              elevation: 1,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              textStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            children: [
              _pageButton(1),
              const SizedBox(width: 5),
              _pageButton(2),
              const SizedBox(width: 5),
              _pageButton(3),
            ],
          ),
          OutlinedButton.icon(
            onPressed: selectedPage < 3
                ? () {
                    setState(() {
                      selectedPage++;
                    });
                  }
                : null,
            label: const Text('Next'),
            icon: const Icon(Icons.arrow_forward_ios, size: 14),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF4F4535),
              backgroundColor: Colors.white,
              side: BorderSide.none,
              elevation: 1,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              textStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageButton(int page) {
    final selected = selectedPage == page;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPage = page;
        });
      },
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF785600) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          '$page',
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF0B1C30),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigation() {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _bottomItem(Icons.home_outlined, 'Dashboard', false),
            _bottomItem(Icons.newspaper, 'Berita', true),
            _bottomItem(Icons.show_chart, 'Harga', false),
            _bottomItem(Icons.table_chart_outlined, 'Pivot', false),
            _bottomItem(Icons.calculate_outlined, 'Kalkulator', false),
            _bottomItem(Icons.history, 'Histori', false),
            _bottomItem(Icons.apartment_outlined, 'Profil PT', false),
          ],
        ),
      ),
    );
  }

  Widget _bottomItem(IconData icon, String label, bool active) {
    return Expanded(
      child: InkWell(
        onTap: () {
          switch (label) {
            case 'Dashboard':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DashboardPage()),
              );
              break;

            case 'Berita':
              break;

            case 'Harga':
             Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HargaEmasPage()),
              );
              break;

            case 'Pivot':
             Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PivotPointPage()),
              );
              break;

            case 'Kalkulator':
             Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const KalkulatorPage()),
              );
              break;

            case 'Histori':
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoriPage()),
              );
              break;

            case 'Profil PT':
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
              icon,
              size: 20,
              color: active ? const Color(0xFF785600) : const Color(0xFF565E74),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: active
                    ? const Color(0xFF785600)
                    : const Color(0xFF565E74),
                fontSize: 9,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE PLACEHOLDER
  // ============================================================

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFDCE9FF),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 50, color: Color(0xFF785600)),
      ),
    );
  }

  // ============================================================
  // ARTICLE DIALOG
  // ============================================================

  void _showArticleDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF8F9FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Berita Emas',
            style: TextStyle(
              color: Color(0xFF0B1C30),
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Detail berita akan ditampilkan pada halaman artikel.',
            style: TextStyle(color: Color(0xFF4F4535), height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Tutup',
                style: TextStyle(
                  color: Color(0xFF785600),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

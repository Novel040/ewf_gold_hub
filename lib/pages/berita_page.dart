import 'dart:async';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'berita_detail_page.dart';
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
  Set<String> savedNewsKeys = {};
  bool isLoadingSavedNews = true;
  bool isLoadingNews = true;
  String newsError = '';

  @override
  void initState() {
    super.initState();
    _loadNews();
    _loadSavedNews();
  }

  Future<void> _loadSavedNews() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList('saved_news_items') ?? [];

    if (!mounted) return;

    setState(() {
      savedNewsKeys = items.map((raw) {
        final item = jsonDecode(raw) as Map<String, dynamic>;
        return _newsKey(item);
      }).toSet();
      isLoadingSavedNews = false;
    });
  }

  String _newsKey(Map<String, dynamic> item) {
    final url = (item['url'] ?? '').toString().trim();
    if (url.isNotEmpty) return url;

    return (item['title'] ?? '').toString().trim();
  }

  Future<void> _toggleSavedNews(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList('saved_news_items') ?? [];
    final key = _newsKey(item);

    items.removeWhere((raw) {
      final saved = jsonDecode(raw) as Map<String, dynamic>;
      return _newsKey(saved) == key;
    });

    final alreadySaved = savedNewsKeys.contains(key);

    if (!alreadySaved) {
      items.add(jsonEncode(item));
    }

    await prefs.setStringList('saved_news_items', items);

    if (!mounted) return;

    setState(() {
      if (alreadySaved) {
        savedNewsKeys.remove(key);
      } else {
        savedNewsKeys.add(key);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          alreadySaved
              ? 'Berita dihapus dari Simpan.'
              : 'Berita berhasil disimpan.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareNews(Map<String, dynamic> item) async {
    final title = (item['title'] ?? 'Berita Emas').toString();
    final url = (item['url'] ?? '').toString().trim();

    final text = url.isNotEmpty ? '$title\n\nBaca selengkapnya: $url' : title;

    await SharePlus.instance.share(ShareParams(text: text, subject: title));
  }

  String _formatDate(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;

    // Waktu API berakhiran Z dikonversi ke waktu lokal perangkat.
    final date = parsed.toLocal();

    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day ${months[date.month - 1]} ${date.year} • $hour:$minute';
  }

  Future<void> _loadNews() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/news'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          news = data.map<Map<String, dynamic>>((item) {
            return {
              'image': item['image'] ?? '',
              'category': item['category'] ?? 'Emas',
              'source': item['source'] ?? 'Newsmaker.id',
              'date': _formatDate((item['published_at'] ?? '').toString()),
              'publishedAt': (item['published_at'] ?? '').toString(),
              'title': item['title'] ?? '',
              'url': item['url'] ?? '',
              'description': item['content'] ?? '',
              'metric': '-',
              'metric1Value': '-',
              'metric2Value': '-',
            };
          }).toList();

          news.sort((a, b) {
            final dateA = DateTime.tryParse(
              (a['publishedAt'] ?? '').toString(),
            );
            final dateB = DateTime.tryParse(
              (b['publishedAt'] ?? '').toString(),
            );

            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1;
            if (dateB == null) return -1;

            return dateB.compareTo(dateA);
          });

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
    backgroundColor: const Color(0xFFF8FAFC),

    // HEADER mengikuti gaya Dashboard
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8CC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.trending_up,
              color: Color(0xFF785600),
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EQUITY PULSE',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              Text(
                'MARKET INTELLIGENCE',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
  onPressed: () {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur notifikasi belum dihubungkan.'),
      ),
    );
  },
  icon: const Icon(
    Icons.notifications_none,
    color: Color(0xFF111827),
  ),
),
        Padding(
  padding: const EdgeInsets.only(right: 12),
  child: CircleAvatar(
    radius: 18,
    backgroundColor: const Color(0xFFF3E8CC),
    child: const Text(
      'A',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF785600),
      ),
    ),
  ),
),
      ],
    ),

    body: SafeArea(
      top: false,
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEditorialHeader(),
            _buildCategoryFilter(),
            _buildNewsFeed(),
          ],
        ),
      ),
    ),

    bottomNavigationBar: _buildBottomNavigation(),
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
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.feed_outlined, size: 16, color: Color(0xFFF58220)),
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
              color: Color(0xFF1F2937),
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
              color: Color(0xFF64748B),
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
    if (isLoadingNews || news.isEmpty || newsError.isNotEmpty) {
      return const SizedBox.shrink();
    }

    final headlines = news
        .where((item) => (item['title'] ?? '').toString().trim().isNotEmpty)
        .toList();

    if (headlines.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 52,
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: const Color(0xFF1F2937),
      child: Row(
        children: [
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            color: const Color(0xFFF58220),
            alignment: Alignment.center,
            child: const Text(
              'TOP NEWS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 52,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: headlines.length,
                itemBuilder: (context, index) {
                  final item = headlines[index];

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => _openNewsDetail(item),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          child: Text(
                            item['title'].toString(),
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const Text(
                        '|',
                        style: TextStyle(
                          color: Color(0xFFF58220),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
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

    // Tampilkan seluruh berita yang diterima dari API.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (int i = 0; i < news.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),

            _buildCompactNews(news[i]),
          ],
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
                    color: const Color(0xFFFFE5CC),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item['category'].toString().toUpperCase(),

                    style: const TextStyle(
                      color: Color(0xFFD96812),
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
                _buildNewsActions(item),
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
        Icon(icon, size: 16, color: const Color(0xFFF58220)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            source,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF64748B),
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
              color: Color(0xFF64748B),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(Map<String, dynamic> item) {
    final isSaved = savedNewsKeys.contains(_newsKey(item));

    return IconButton(
      tooltip: isSaved ? 'Hapus dari Simpan' : 'Simpan berita',
      onPressed: () => _toggleSavedNews(item),
      icon: Icon(
        isSaved ? Icons.bookmark : Icons.bookmark_border,
        color: const Color(0xFFF58220),
      ),
    );
  }

  // ============================================================
  // NEWS ACTIONS
  // ============================================================

  Widget _buildNewsActions(Map<String, dynamic> item) {
    return Row(
      children: [
        _buildSaveButton(item),
        const SizedBox(width: 7),
        IconButton(
          tooltip: 'Bagikan berita',
          onPressed: () => _shareNews(item),
          icon: const Icon(Icons.share_outlined),
          color: const Color(0xFFF58220),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: () => _openNewsDetail(item),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF58220),
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

  void _openNewsDetail(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BeritaDetailPage(article: item)),
    );
  }

  // ============================================================
  // WEEKLY DIGEST
  // ============================================================

  
Widget _buildBottomNavigation() {
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
      border: Border(
        top: BorderSide(color: Colors.grey.shade200),
      ),
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
            final active = index == 1;

            return SizedBox(
              width: 82,
              child: InkWell(
                onTap: () {
                  switch (index) {
                    case 0:
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardPage(),
                        ),
                      );
                      break;
                    case 1:
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
                          ? const Color(0xFF785600)
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
                            ? const Color(0xFF785600)
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
}

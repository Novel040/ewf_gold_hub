import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../pages/berita_detail_page.dart';
import '../pages/berita_page.dart';

class LatestNewsSection extends StatefulWidget {
  const LatestNewsSection({super.key});

  @override
  State<LatestNewsSection> createState() => _LatestNewsSectionState();
}

class _LatestNewsSectionState extends State<LatestNewsSection> {
  static const Color _orange = Color(0xFFF58220);
  static const Color _dark = Color(0xFF1F2937);
  static const Color _muted = Color(0xFF64748B);

  List<Map<String, dynamic>> _news = [];
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    try {
      final response = await http
          .get(Uri.parse('http://10.0.2.2:8000/api/news'))
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        throw Exception('Failed to load news');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw const FormatException('Invalid news response');
      }

      final items = decoded
          .map<Map<String, dynamic>>((item) {
            final publishedAt = (item['published_at'] ?? '').toString();

            return {
              'image': item['image']?.toString() ?? '',
              'category': item['category']?.toString() ?? 'Market News',
              'source': item['source']?.toString() ?? 'Equity Pulse',
              'date': _formatDate(publishedAt),
              'title': item['title']?.toString() ?? '',
              'url': item['url']?.toString() ?? '',
              'description': item['content']?.toString() ?? '',
              'metric': '-',
              'metric1Value': '-',
              'metric2Value': '-',
            };
          })
          .where((item) => (item['title'] as String).trim().isNotEmpty)
          .take(4)
          .toList();

      if (!mounted) return;
      setState(() {
        _news = items;
        _loading = false;
        _failed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  String _formatDate(String raw) {
    final date = DateTime.tryParse(raw);
    if (date == null) return raw.isEmpty ? 'Latest update' : raw;

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _openAllNews() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BeritaPage()),
    );
  }

  void _openArticle(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BeritaDetailPage(article: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Latest News',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _dark,
                ),
              ),
            ),
            TextButton(
              onPressed: _openAllNews,
              child: const Text(
                'View All News',
                style: TextStyle(
                  color: _orange,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Latest updates from the market',
          style: TextStyle(fontSize: 12, color: _muted),
        ),
        const SizedBox(height: 12),

        if (!_loading && !_failed && _news.isNotEmpty) ...[
          _NewsTicker(news: _news, onTap: _openArticle),
          const SizedBox(height: 12),
        ],
        if (_loading)
          const SizedBox(
            height: 190,
            child: Center(child: CircularProgressIndicator(color: _orange)),
          )
        else if (_failed)
          _buildMessage(
            icon: Icons.wifi_off_outlined,
            message: 'News could not be loaded.',
            buttonLabel: 'Retry',
            onPressed: _loadNews,
          )
        else if (_news.isEmpty)
          _buildMessage(
            icon: Icons.newspaper_outlined,
            message: 'No news available yet.',
            buttonLabel: 'View All News',
            onPressed: _openAllNews,
          )
        else
          SizedBox(
            height: 252,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _news.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = _news[index];
                return _buildNewsCard(item);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String message,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE5CC)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: _muted),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: _muted, fontSize: 12)),
          TextButton(onPressed: onPressed, child: Text(buttonLabel)),
        ],
      ),
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> item) {
    final image = (item['image'] ?? '').toString();

    return SizedBox(
      width: 245,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openArticle(item),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFE5CC)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 118,
                  width: double.infinity,
                  child: image.isNotEmpty
                      ? Image.network(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _imagePlaceholder(),
                        )
                      : _imagePlaceholder(),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (item['category'] ?? 'Market News')
                              .toString()
                              .toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _orange,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Text(
                            (item['title'] ?? '').toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _dark,
                              fontSize: 12,
                              height: 1.35,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${item['source']} · ${item['date']}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: _muted, fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFFFF3E8),
      alignment: Alignment.center,
      child: const Icon(Icons.newspaper_outlined, size: 36, color: _orange),
    );
  }
}

class _NewsTicker extends StatefulWidget {
  final List<Map<String, dynamic>> news;
  final ValueChanged<Map<String, dynamic>> onTap;

  const _NewsTicker({required this.news, required this.onTap});

  @override
  State<_NewsTicker> createState() => _NewsTickerState();
}

class _NewsTickerState extends State<_NewsTicker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  double _contentWidth = 0;
  final GlobalKey _tickerContentKey = GlobalKey();

  static const double _speed = 45;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
  }

  @override
  void didUpdateWidget(covariant _NewsTicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.news != widget.news) {
      _animationController.stop();
      _contentWidth = 0;
    }
  }

  void _startAnimation(double width) {
    if (!mounted || width <= 0) return;

    if ((_contentWidth - width).abs() < 1 && _animationController.isAnimating) {
      return;
    }

    _contentWidth = width;

    _animationController.duration = Duration(
      milliseconds: (width / _speed * 1000).round().clamp(1000, 3600000),
    );

    _animationController.repeat();
  }

  Widget _buildNewsItems() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widget.news.map((item) {
        return InkWell(
          onTap: () => widget.onTap(item),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, size: 7, color: Color(0xFFF58220)),
                const SizedBox(width: 8),
                Text(
                  (item['title'] ?? '').toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.news.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 40,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: const Color(0xFFF58220),
            child: const Text(
              'TOP NEWS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          Expanded(
            child: ClipRect(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;

                    final keyContext = _tickerContentKey.currentContext;
                    final renderObject = keyContext?.findRenderObject();

                    if (renderObject is RenderBox && renderObject.hasSize) {
                      final measuredWidth = renderObject.size.width / 2;

                      if (measuredWidth > 0 &&
                          (_contentWidth - measuredWidth).abs() >= 1) {
                        _startAnimation(measuredWidth);
                      } else if (measuredWidth > 0 &&
                          !_animationController.isAnimating) {
                        _startAnimation(measuredWidth);
                      }
                    }
                  });

                  return OverflowBox(
                    alignment: Alignment.centerLeft,
                    minWidth: 0,
                    maxWidth: double.infinity,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            -_animationController.value * _contentWidth,
                            0,
                          ),
                          child: child,
                        );
                      },
                      child: Row(
                        key: _tickerContentKey,
                        mainAxisSize: MainAxisSize.min,
                        children: [_buildNewsItems(), _buildNewsItems()],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

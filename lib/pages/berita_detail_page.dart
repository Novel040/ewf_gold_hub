import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;

class BeritaDetailPage extends StatelessWidget {
  final Map<String, dynamic> article;

  const BeritaDetailPage({super.key, required this.article});

  String _cleanContent(String raw) {
    final formatted = raw
        .replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');

    final document = html_parser.parse(formatted);
    return (document.body?.text ?? formatted).trim();
  }

  @override
  Widget build(BuildContext context) {
    final title = article['title']?.toString() ?? 'Berita';
    final category = article['category']?.toString() ?? 'Berita';
    final source = article['source']?.toString() ?? 'Equity Pulse';
    final date = article['date']?.toString() ?? '';
    final image = article['image']?.toString() ?? '';
    final content = _cleanContent(article['description']?.toString() ?? '');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FF),
        foregroundColor: const Color(0xFF0B1C30),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Detail Berita',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: image.isNotEmpty
                  ? Image.network(
                      image,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _imagePlaceholder();
                      },
                    )
                  : _imagePlaceholder(),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE5EEFF),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                category.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF785600),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0B1C30),
                fontSize: 24,
                height: 1.35,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.newspaper_outlined,
                  size: 17,
                  color: Color(0xFF785600),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    source,
                    style: const TextStyle(
                      color: Color(0xFF4F4535),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Color(0xFF565E74),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    date,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: Color(0xFF565E74),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFFDCE3EF)),
            const SizedBox(height: 16),
            const Text(
              'Isi Berita',
              style: TextStyle(
                color: Color(0xFF0B1C30),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            SelectableText(
              content.isNotEmpty ? content : 'Isi berita belum tersedia.',
              style: const TextStyle(
                color: Color(0xFF30394B),
                fontSize: 15,
                height: 1.8,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali ke Daftar Berita'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF785600),
                  side: const BorderSide(color: Color(0xFF785600)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 220,
      color: const Color(0xFFE5EEFF),
      alignment: Alignment.center,
      child: const Icon(
        Icons.newspaper_outlined,
        size: 56,
        color: Color(0xFF785600),
      ),
    );
  }
}

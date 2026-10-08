import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String filter = 'Semua';
  final items = const [
    NotificationItem('Pivot Point', 'Volatilitas Tinggi', '5 mnt lalu', 'Pemberitahuan Pivot Level R1 LGD Terlewati', 'Harga acuan spot Loco London Gold menyentuh level R1 (2,402.57 USD/toz). Formulasi Pivot Point harian telah terbarui.', Icons.trending_up, Color(0xFF059669)),
    NotificationItem('Berita Emas', 'Makro AS', '42 mnt lalu', 'Rilis Data Cadangan Devisa & Inflasi AS (Core CPI)', 'Data ekonomi utama AS dirilis malam ini pukul 19:30 WIB. Antisipasi lonjakan spread dan volatilitas harga emas.', Icons.newspaper, Color(0xFF2563EB)),
    NotificationItem('Regulasi & PT', 'Resmi', 'Hari ini, 09:15 WIB', 'Surat Edaran Bappebti Mengenai Jam Libur Bursa Kliring', 'Jadwal operasional penarikan dana dan kliring transaksi komoditas berjangka.', Icons.gavel_rounded, Color(0xFFB8860B)),
    NotificationItem('Keamanan Akun', 'Audit Log', 'Kemarin, 16:40 WIB', 'Login Terdeteksi di Perangkat Mobile Baru', 'Sesi internal Equity Pulse diakses melalui perangkat mobile baru.', Icons.shield_rounded, Color(0xFFDC2626)),
    NotificationItem('Kalkulator', 'Kurs Acuan', 'Kemarin, 08:30 WIB', 'Update Kurs Referensi Valuta Asing (USD/IDR)', 'Kurs acuan kalkulator emas disinkronkan ke Rp 16.240 per USD.', Icons.calculate_rounded, Color(0xFF2563EB)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('Notifikasi'),
),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFEFF4FF), borderRadius: BorderRadius.circular(14)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFFFDEA6), borderRadius: BorderRadius.circular(20)), child: const Text('LIVE BROADCAST FEED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800))),
                const Spacer(),
                TextButton.icon(onPressed: () => setState(() {}), icon: const Icon(Icons.done_all, size: 16), label: const Text('Tandai Semua')),
              ]),
              const SizedBox(height: 8),
              const Text('Pusat Notifikasi & Info Pasar', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
              const SizedBox(height: 6),
              const Text('Pemberitahuan resmi pembukaan sesi, pengumuman Bappebti, update harga acuan, dan pembaruan sistem.', style: TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF4F4535))),
              const SizedBox(height: 14),
              Wrap(spacing: 8, runSpacing: 8, children: const [
                _StatusPill(label: 'Sinkronisasi BBJ', value: 'Aktif (Realtime)', good: true),
                _StatusPill(label: 'Bappebti Feed', value: 'Tervalidasi', good: false),
              ]),
            ]),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: ['Semua', 'Harga & Pivot', 'Berita Penting', 'Sistem & Keamanan'].map((x) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(label: Text(x), selected: filter == x, onSelected: (_) => setState(() => filter = x)),
            )).toList()),
          ),
          const SizedBox(height: 14),
          ...items.map((n) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _NotificationCard(item: n))),
          const SizedBox(height: 6),
          _SettingsPanel(),
        ],
      ),
    );
  }
}

class NotificationItem {
  final String category, tag, time, title, body;
  final IconData icon;
  final Color color;
  const NotificationItem(this.category, this.tag, this.time, this.title, this.body, this.icon, this.color);
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem item;
  const _NotificationCard({required this.item});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
  width: 38,
  height: 38,
  decoration: BoxDecoration(
    color: item.color.withValues(alpha: 0.10),
    borderRadius: BorderRadius.circular(10),
  ),
  child: Icon(
    item.icon,
    color: item.color,
    size: 20,
  ),
),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.category, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: item.color)),
          Text(item.tag, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        ])),
        Text(item.time, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
      ]),
      const SizedBox(height: 11),
      Text(item.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      const SizedBox(height: 5),
      Text(item.body, style: const TextStyle(fontSize: 12.5, height: 1.45, color: Color(0xFF475569))),
      const SizedBox(height: 10),
      TextButton(onPressed: () {}, child: const Text('Lihat Detail')),
    ]),
  );
}

class _StatusPill extends StatelessWidget {
  final String label, value;
  final bool good;
  const _StatusPill({required this.label, required this.value, required this.good});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.circle, size: 7, color: good ? const Color(0xFF059669) : const Color(0xFFB8860B)),
      const SizedBox(width: 6),
      Text('$label: ', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
      Text(value, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: good ? const Color(0xFF059669) : const Color(0xFFB8860B))),
    ]),
  );
}

class _SettingsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Pengaturan Notifikasi Cepat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      const Text('Kontrol kanal siaran real-time terminal internal', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
      const SizedBox(height: 8),
      SwitchListTile(contentPadding: EdgeInsets.zero, value: true, onChanged: (_) {}, title: const Text('Peringatan Level Pivot Point Harian', style: TextStyle(fontSize: 13))),
      SwitchListTile(contentPadding: EdgeInsets.zero, value: true, onChanged: (_) {}, title: const Text('Notifikasi Berita Breaking News', style: TextStyle(fontSize: 13))),
      SwitchListTile(contentPadding: EdgeInsets.zero, value: true, onChanged: (_) {}, title: const Text('Pengumuman Resmi & Regulasi', style: TextStyle(fontSize: 13))),
    ]),
  );
}

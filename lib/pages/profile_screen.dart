import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color orange = Color(0xFFF58220);
  static const Color orangeDark = Color(0xFFD96812);
  static const Color pageBackground = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFF5F5F5);
  static const Color textPrimary = Color(0xFF171717);
  static const Color textSecondary = Color(0xFF737373);

  final name = TextEditingController(text: 'Hendrawan Pradipta, S.E., M.M.');
  final email = TextEditingController(
    text: 'hendrawan@equityworld-futures.com',
  );
  final unit = TextEditingController(text: 'Surabaya - Trilium Office Lt. 2');

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    unit.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Theme(
    data: Theme.of(context).copyWith(
      textTheme: GoogleFonts.robotoTextTheme(
        Theme.of(context).textTheme,
      ),
    ),
    child: Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profil',
          style: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          _profileHeader(),
          const SizedBox(height: 28),
          _section(
            title: 'Informasi Pribadi',
            children: [
              _infoRow(
                icon: Icons.badge_outlined,
                title: 'Nama lengkap',
                value: name.text,
              ),
              _infoRow(
                icon: Icons.mail_outline_rounded,
                title: 'Email perusahaan',
                value: email.text,
                trailing: const Icon(
                  Icons.verified_rounded,
                  color: Color(0xFF16845B),
                  size: 19,
                ),
              ),
              _infoRow(
                icon: Icons.business_outlined,
                title: 'Unit kantor',
                value: unit.text,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _section(
            title: 'Kredensial & Otentikasi',
            children: [
              _actionRow(
                icon: Icons.lock_outline_rounded,
                title: 'Perbarui kata sandi',
                subtitle: 'Ubah kata sandi akun Anda',
                onTap: _showPasswordDialog,
              ),
              _actionRow(
                icon: Icons.notifications_none_rounded,
                title: 'Notifikasi',
                subtitle: 'Atur notifikasi keamanan dan informasi pasar',
                trailing: Switch(
                  value: notificationsEnabled,
                  activeThumbColor: orange,
                  onChanged: (value) =>
                      setState(() => notificationsEnabled = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _section(
            title: 'Pengaturan',
            children: [
              _actionRow(
                icon: Icons.palette_outlined,
                title: 'Tema aplikasi',
                subtitle: 'Terang',
                trailing: const Text(
                  'Terang',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              _actionRow(
                icon: Icons.support_agent_rounded,
                title: 'Hubungi dukungan',
                subtitle: 'Bantuan untuk akun EWF Gold Hub',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur dukungan belum dihubungkan.'),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            icon: const Icon(Icons.logout_rounded, size: 19),
            label: const Text('Keluar dari akun'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD64545),
              side: const BorderSide(color: Color(0xFFF0B8B8)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
                    const SizedBox(height: 18),
          const Center(
            child: Text(
              'PT EQUITYWORLD FUTURES • EWF GOLD HUB',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ),
        ],
      ),
    ), // Menutup Scaffold
  );   // Menutup Theme
}

  bool notificationsEnabled = true;

  Widget _profileHeader() => Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 112,
            height: 112,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFE5CC),
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 66,
              color: orange,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 23,
              height: 1.2,
              color: textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            email.text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: textSecondary),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _showEditProfileDialog,
            style: OutlinedButton.styleFrom(
              foregroundColor: orangeDark,
              side: const BorderSide(color: orange, width: 1.4),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: const StadiumBorder(),
            ),
            child: const Text(
              'Edit profil',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      );

  Widget _section({
    required String title,
    required List<Widget> children,
  }) =>
      Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                color: textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      );

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
    Widget? trailing,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Icon(icon, color: textPrimary, size: 22),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      color: textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      );

  Widget _actionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) =>
      ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: textPrimary, size: 23),
        title: Text(
          title,
          style: const TextStyle(
            color: textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: textSecondary, fontSize: 11),
        ),
        trailing: trailing ??
            const Icon(
              Icons.chevron_right_rounded,
              color: textSecondary,
            ),
      );

  Future<void> _showEditProfileDialog() async {
    final nameController = TextEditingController(text: name.text);
    final unitController = TextEditingController(text: unit.text);
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit profil'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama lengkap'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Nama wajib diisi'
                      : null,
                ),
                TextFormField(
                  controller: unitController,
                  decoration: const InputDecoration(labelText: 'Unit kantor'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Unit kantor wajib diisi'
                      : null,
                ),
                TextFormField(
                  initialValue: email.text,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Email perusahaan (terverifikasi)',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: orange),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                setState(() {
                  name.text = nameController.text.trim();
                  unit.text = unitController.text.trim();
                });
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Perubahan tampil di aplikasi. Hubungkan API untuk menyimpan ke server.',
                    ),
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    nameController.dispose();
    unitController.dispose();
  }

  Future<void> _showPasswordDialog() async {
    final currentPassword = TextEditingController();
    final newPassword = TextEditingController();
    final confirmPassword = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Perbarui kata sandi'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentPassword,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Kata sandi saat ini',
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Wajib diisi' : null,
                ),
                TextFormField(
                  controller: newPassword,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Kata sandi baru',
                  ),
                  validator: (value) => value == null || value.length < 8
                      ? 'Minimal 8 karakter'
                      : null,
                ),
                TextFormField(
                  controller: confirmPassword,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Konfirmasi kata sandi baru',
                  ),
                  validator: (value) => value != newPassword.text
                      ? 'Kata sandi belum cocok'
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: orange),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Validasi berhasil. Hubungkan endpoint API untuk memperbarui kata sandi.',
                    ),
                  ),
                );
              }
            },
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );

    currentPassword.dispose();
    newPassword.dispose();
    confirmPassword.dispose();
  }
}

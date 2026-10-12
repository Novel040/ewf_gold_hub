import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_page.dart';
import 'daftar_akun_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool rememberSession = false;
  bool isLoading = false;

  String? statusMessage;
  bool statusError = false;
  IconData statusIcon = Icons.info_outline;

  // Warna dari desain Stitch
  static const Color surface = Color(0xFFF8F9FF);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);

  static const Color primary = Color(0xFF785600);
  static const Color primaryContainer = Color(0xFF986D00);
  static const Color primaryFixed = Color(0xFFFFDEA6);

  static const Color onSurface = Color(0xFF0B1C30);
  static const Color onSurfaceVariant = Color(0xFF4F4535);
  static const Color secondary = Color(0xFF565E74);

  static const Color tertiary = Color(0xFF006947);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showStatus(
    String message, {
    IconData icon = Icons.info_outline,
    bool error = false,
  }) {
    setState(() {
      statusMessage = message;
      statusIcon = icon;
      statusError = error;
    });
  }


Future<void> handleLogin() async {
  final email = emailController.text.trim();
  final password = passwordController.text;

  if (email.isEmpty || password.isEmpty) {
    showStatus(
      'Email dan kata sandi wajib diisi.',
      icon: Icons.warning_amber_rounded,
      error: true,
    );
    return;
  }

  setState(() {
    isLoading = true;
    statusMessage = null;
  });

  try {
    const baseUrl = 'http://10.0.2.2:8000/api';

    final response = await http
        .post(
          Uri.parse('$baseUrl/login'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 15));

    final data = jsonDecode(response.body);

    if (!mounted) return;

    if (response.statusCode == 200 &&
        data is Map &&
        data['success'] == true) {
      showStatus(
        'Login berhasil. Mengalihkan ke dashboard...',
        icon: Icons.check_circle_outline,
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardPage(),
        ),
      );
    } else {
      showStatus(
        data is Map
            ? (data['message']?.toString() ??
                'Login gagal. Periksa email dan kata sandi.')
            : 'Login gagal. Periksa email dan kata sandi.',
        icon: Icons.error_outline,
        error: true,
      );
    }
  } catch (e) {
    if (!mounted) return;

    showStatus(
      'Tidak dapat terhubung ke server. Periksa koneksi dan coba lagi.',
      icon: Icons.wifi_off,
      error: true,
    );
  } finally {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}

  void triggerForgotFeedback() {
    showStatus(
      'Silakan hubungi Administrator IT Divisi Treasury untuk reset kredensial.',
      icon: Icons.support_agent,
    );
  }

  void triggerHelpFeedback() {
    showStatus(
      'Helpdesk Operasional: support.gold@equityworld.co.id | Hunting: +62 21 515-0555',
      icon: Icons.contact_support_outlined,
    );
  }

  TextStyle jakarta({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = onSurface,
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
    Color color = onSurface,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  InputDecoration inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: mono(size: 13, weight: FontWeight.w400, color: secondary),
      prefixIcon: Icon(icon, color: secondary, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primary, width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  _buildBranding(),
                  const SizedBox(height: 8),
                  _buildLoginCard(),
                  const SizedBox(height: 16),
                  _buildSupportCard(),
                  const SizedBox(height: 32),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBranding() {
    return Column(
      children: [
        const SizedBox(height: 4),

        // Logo + nama perusahaan
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: surfaceContainer,
              ),
              child: const Icon(Icons.trending_up, color: primary, size: 28),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: jakarta(size: 20, weight: FontWeight.w700),
                    children: const [
                      TextSpan(text: 'EQUITY '),
                      TextSpan(
                        text: 'PULSE',
                        style: TextStyle(color: primary),
                      ),
                    ],
                  ),
                ),
                Text(
                  'PT EQUITYWORLD FUTURES',
                  style: jakarta(
                    size: 10,
                    weight: FontWeight.w600,
                    color: secondary,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Internal Operations Terminal
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: surfaceContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: primaryContainer,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'INTERNAL OPERATIONS TERMINAL',
                style: jakarta(
                  size: 10,
                  weight: FontWeight.w600,
                  color: onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'FUTURES MARKET INTELLIGENCE',
          textAlign: TextAlign.center,
          style: jakarta(size: 13, color: secondary),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            offset: Offset(0, 4),
            color: Color(0x18000000),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Garis gold atas
          Container(
            height: 6,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryContainer, primary, primaryFixed],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Masuk ke Platform',
                        style: jakarta(size: 20, weight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: surfaceContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'v4.8.2',
                        style: mono(size: 11, color: onSurfaceVariant),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 2),

                Text(
                  'Internal Portal PT Equityworld Futures',
                  style: jakarta(size: 13, color: onSurfaceVariant),
                ),

                const SizedBox(height: 20),

                // Email
                Text(
                  'Email Perusahaan / ID Analis',
                  style: jakarta(size: 13, weight: FontWeight.w600),
                ),

                const SizedBox(height: 4),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: mono(size: 13),
                  decoration: inputDecoration(
                    hint: 'nama.pengguna@equityworld.co.id',
                    icon: Icons.badge_outlined,
                  ),
                ),

                const SizedBox(height: 16),

                // Password + lupa password
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Kata Sandi Akses',
                        style: jakarta(size: 13, weight: FontWeight.w600),
                      ),
                    ),
                    TextButton(
                      onPressed: triggerForgotFeedback,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Lupa Password?',
                        style: jakarta(
                          size: 10,
                          weight: FontWeight.w600,
                          color: primary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  style: mono(size: 13),
                  decoration: inputDecoration(
                    hint: '••••••••••••',
                    icon: Icons.key_outlined,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: secondary,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // Remember session
                Row(
                  children: [
                    Checkbox(
                      value: rememberSession,
                      activeColor: primary,
                      onChanged: (value) {
                        setState(() {
                          rememberSession = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Ingat sesi di perangkat aman ini',
                        style: jakarta(size: 13, color: onSurface),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Tombol login
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [primaryContainer, primary, primaryContainer],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ElevatedButton(
                      onPressed: isLoading ? null : handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Memverifikasi Otorisasi...',
                                  style: jakarta(
                                    size: 13,
                                    weight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.verified_user_outlined,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Masuk ke Equity Pulse',
                                  style: jakarta(
                                    size: 13,
                                    weight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),


                // Status message
                if (statusMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusError
                          ? const Color(0xFFFFDAD6)
                          : surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          statusError
                              ? Icons.warning_amber_rounded
                              : statusIcon,
                          size: 18,
                          color: statusError
                              ? const Color(0xFFBA1A1A)
                              : primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            statusMessage!,
                            style: jakarta(
                              size: 12,
                              color: statusError
                                  ? const Color(0xFF93000A)
                                  : onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Tombol menuju halaman pendaftaran
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Belum memiliki akun? ',
                        style: jakarta(
                          size: 12,
                          color: secondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const DaftarAkunPage(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Daftar di sini',
                          style: jakarta(
                            size: 12,
                            weight: FontWeight.w700,
                            color: primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Security panel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: surfaceContainerLow,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: jakarta(size: 10, color: onSurfaceVariant),
                      children: const [
                        TextSpan(
                          text: 'Sistem Informasi Internal Terproteksi',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          ),
                        ),
                        TextSpan(
                          text:
                              ' • Khusus Karyawan & Analis PT Equityworld Futures. Seluruh sesi diaudit secara digital.',
                        ),
                      ],
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

  Widget _buildSupportCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.headset_mic_outlined,
              size: 18,
              color: onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IT Desk Support',
                  style: jakarta(size: 10, weight: FontWeight.w600),
                ),
                Text(
                  'Ext. 4410 (Equity Tower LT. 22)',
                  style: jakarta(size: 13, color: secondary),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: triggerHelpFeedback,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFD3E4FE),
              foregroundColor: onSurface,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text(
              'Bantuan',
              style: jakarta(size: 10, weight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Terdaftar & Diawasi oleh Bappebti • Anggota ICDX & ICH',
          textAlign: TextAlign.center,
          style: jakarta(size: 10, weight: FontWeight.w600, color: secondary),
        ),
        const SizedBox(height: 4),
        Text(
          '© 2025 PT Equityworld Futures. Hak Cipta Dilindungi Undang-Undang.',
          textAlign: TextAlign.center,
          style: jakarta(size: 10, color: secondary),
        ),
      ],
    );
  }
}

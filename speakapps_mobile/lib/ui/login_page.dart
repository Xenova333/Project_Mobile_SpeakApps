import 'package:flutter/material.dart';
import '../auth_service.dart';
import 'home_page.dart';
import 'register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ─── Controllers ────────────────────────────────────────────────
  final _nimController      = TextEditingController();
  final _passwordController = TextEditingController();

  // ─── State ──────────────────────────────────────────────────────
  bool _isLoading   = false;
  bool _obscurePass = true;

  final _apiService = AuthService();

  @override
  void dispose() {
    _nimController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─── Fungsi Login ────────────────────────────────────────────────
  Future<void> _handleLogin() async {
    final nim      = _nimController.text.trim();
    final password = _passwordController.text.trim();

    // Validasi lokal
    if (nim.isEmpty || password.isEmpty) {
      _showSnackBar('NIM dan password wajib diisi.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Panggil ApiService.login()
      final result = await _apiService.login(nim, password);

      if (!mounted) return;

      if (result['status'] == 'success') {
        // ✅ Login berhasil — simpan data ke SharedPreferences dan bawa ke HomePage
        final userData = result['data'] as Map<String, dynamic>;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', int.parse(userData['id'].toString()));
        await prefs.setString('user_nim',      userData['nim'].toString());
        await prefs.setString('user_name',     userData['name'].toString());
        await prefs.setString('user_semester', userData['semester']?.toString()   ?? '');
        await prefs.setString('user_gender',   userData['gender']?.toString()     ?? '');
        await prefs.setString('user_pic',      userData['profile_pic']?.toString() ?? '');

        _showSnackBar('Selamat datang, ${userData['name']}!', isError: false);

        await Future.delayed(const Duration(milliseconds: 800));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomePage(userData: userData),
            ),
          );
        }
      } else {
        // ❌ Login gagal
        final msg = result['message'] ?? 'NIM atau password salah.';
        _showSnackBar(msg, isError: true);
      }
    } catch (e) {
      if (mounted) _showSnackBar('Terjadi kesalahan: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Helper SnackBar ────────────────────────────────────────────
  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor:
            isError ? const Color(0xFFE53935) : const Color(0xFF43A047),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Background Gradient ──────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF78C8E6),
                  Colors.white,
                  Color(0xFFF6A039),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // ── Konten Utama ─────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Login Card ─────────────────────────────────
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 40),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF81B1DF), Color(0xFFBBE5F1)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Judul
                          const Text(
                            'Login SpeakApps',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // NIM Field
                          _buildInputField(
                            controller: _nimController,
                            hint: 'Masukan NIM PNC',
                            icon: Icons.badge_outlined,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          _buildInputField(
                            controller: _passwordController,
                            hint: 'Masukan Password',
                            icon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          const SizedBox(height: 30),

                          // ── Tombol Masuk ─────────────────────────
                          SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: _isLoading ? null : _handleLogin,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _isLoading
                                        ? [
                                            Colors.grey.shade400,
                                            Colors.grey.shade400
                                          ]
                                        : [
                                            const Color(0xFF4AC2E3),
                                            const Color(0xFF1976D2),
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text(
                                          'Masuk',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ── Tombol Buat Akun Baru ──────────────────────
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterPage()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4AC2E3), Color(0xFF29B6F6)],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Buat Akun Baru',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Full-screen Loading Overlay ──────────────────────────
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF4AC2E3)),
                        SizedBox(height: 16),
                        Text(
                          'Sedang masuk...',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A3A5C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Widget Helper: Input Field ─────────────────────────────────
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePass : false,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 12),
          prefixIcon: Icon(icon, color: const Color(0xFF4AC2E3), size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePass ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black38,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePass = !_obscurePass),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
      ),
    );
  }
}

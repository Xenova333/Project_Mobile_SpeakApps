import 'package:flutter/material.dart';
import '../auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // ─── Controllers ────────────────────────────────────────────────
  final _nameController     = TextEditingController();
  final _nimController      = TextEditingController();
  final _semesterController = TextEditingController();
  final _passwordController = TextEditingController();

  // ─── State ──────────────────────────────────────────────────────
  String _selectedGender = 'male'; // default
  bool   _isLoading      = false;
  bool   _obscurePass    = true;

  final _apiService = AuthService();

  // Pilihan gender yang tersedia
  final List<Map<String, String>> _genderOptions = [
    {'value': 'male',   'label': 'Laki-laki'},
    {'value': 'female', 'label': 'Perempuan'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _semesterController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─── Fungsi Register ────────────────────────────────────────────
  Future<void> _handleRegister() async {
    // Ambil nilai dari controller
    final name     = _nameController.text.trim();
    final nim      = _nimController.text.trim();
    final semester = _semesterController.text.trim();
    final password = _passwordController.text.trim();
    final gender   = _selectedGender;

    // Validasi lokal sebelum ke server
    if (name.isEmpty || nim.isEmpty || semester.isEmpty || password.isEmpty) {
      _showSnackBar('Semua field wajib diisi.', isError: true);
      return;
    }

    if (int.tryParse(semester) == null) {
      _showSnackBar('Semester harus berupa angka.', isError: true);
      return;
    }

    // Tampilkan loading
    setState(() => _isLoading = true);

    try {
      // Panggil ApiService.register()
      final result = await _apiService.register(
        nim:      nim,
        name:     name,
        password: password,
        semester: semester,
        gender:   gender,
      );

      if (!mounted) return;

      if (result['status'] == 'success') {
        // ✅ Berhasil
        _showSnackBar('Registrasi berhasil! Silakan login.', isError: false);
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context); // Kembali ke halaman login
      } else {
        // ❌ Gagal dari server
        final msg = result['message'] ?? 'Registrasi gagal.';
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
        backgroundColor: isError ? const Color(0xFFE53935) : const Color(0xFF43A047),
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
                    // Judul
                    const Text(
                      'Daftar Akun Baru',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A3A5C),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Isi data di bawah untuk membuat akun',
                      style: TextStyle(fontSize: 12, color: Color(0xFF4A6A8A)),
                    ),
                    const SizedBox(height: 24),

                    // ── Register Card ──────────────────────────────
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 28),
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
                        children: [
                          // Nama
                          _buildInputField(
                            controller: _nameController,
                            hint: 'Masukan Nama Lengkap',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 14),

                          // NIM
                          _buildInputField(
                            controller: _nimController,
                            hint: 'Masukan NIM PNC',
                            icon: Icons.badge_outlined,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 14),

                          // Semester
                          _buildInputField(
                            controller: _semesterController,
                            hint: 'Semester (1–8)',
                            icon: Icons.school_outlined,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 14),

                          // Gender Dropdown
                          _buildGenderDropdown(),
                          const SizedBox(height: 14),

                          // Password
                          _buildInputField(
                            controller: _passwordController,
                            hint: 'Masukan Password',
                            icon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          const SizedBox(height: 24),

                          // ── Tombol Daftar Sekarang ───────────────
                          SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: _isLoading ? null : _handleRegister,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _isLoading
                                        ? [Colors.grey.shade400, Colors.grey.shade400]
                                        : [
                                            const Color(0xFF4AC2E3),
                                            const Color(0xFF1976D2),
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 6,
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
                                          'Daftar Sekarang',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Kembali ke Login ───────────────────────────
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4AC2E3), Color(0xFF29B6F6)],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Kembali ke Form Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
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
                          'Mendaftarkan akun...',
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
          // Toggle visibilitas password
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

  // ─── Widget Helper: Gender Dropdown ────────────────────────────
  Widget _buildGenderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGender,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4AC2E3)),
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          hint: const Text('Pilih Jenis Kelamin'),
          items: _genderOptions
              .map(
                (g) => DropdownMenuItem<String>(
                  value: g['value'],
                  child: Row(
                    children: [
                      const Icon(Icons.wc, color: Color(0xFF4AC2E3), size: 20),
                      const SizedBox(width: 10),
                      Text(g['label']!),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedGender = val);
          },
        ),
      ),
    );
  }
}

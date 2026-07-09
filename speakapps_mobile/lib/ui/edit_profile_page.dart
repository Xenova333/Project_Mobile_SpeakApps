// dart:io diimport untuk FileImage (hanya dipanggil di Android lewat !kIsWeb guard)
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/edit_profile_controller.dart';
import '../user_service.dart';
import '../controllers/global_user_controller.dart';
import 'widgets/custom_bottom_nav.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Daftarkan controller — otomatis di-dispose saat halaman ditutup
    final controller = Get.put(EditProfileController());

    final primaryOrange = const Color(0xFFF6A039);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Opsi gender yang tersedia
    final genderOptions = ['male', 'female'];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // ── Custom App Bar ───────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 20.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0A1128) : null,
                    gradient: isDark
                        ? null
                        : LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              primaryOrange.withOpacity(0.4),
                              primaryOrange.withOpacity(0.1),
                              Colors.white,
                            ],
                          ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Icon(
                          Icons.arrow_back,
                          size: 24,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Body ─────────────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 110),
                    child: GetBuilder<EditProfileController>(
                      builder: (c) => Column(
                        children: [
                          const SizedBox(height: 36),

                          // ── Avatar + Tombol Pilih Foto ─────────────────
                          GestureDetector(
                            onTap: () => c.pickImage(),
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                // Foto: preview gambar baru (Web/Android) atau foto lama dari server
                                CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.white,
                                  backgroundImage: _resolveProfileImage(c),
                                ),

                                // Badge kamera di pojok kanan bawah avatar
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: primaryOrange,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Label tap untuk ganti foto
                          GestureDetector(
                            onTap: () => c.pickImage(),
                            child: Text(
                              'Edit foto profile',
                              style: TextStyle(
                                fontSize: 11,
                                color: primaryOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // ── Form Card ──────────────────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 28.0),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF111827)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16.0),
                                border:
                                    Border.all(color: primaryOrange, width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? primaryOrange.withOpacity(0.25)
                                        : Colors.black.withOpacity(0.06),
                                    blurRadius: isDark ? 20 : 12,
                                    spreadRadius: isDark ? 2 : 0,
                                    offset: isDark
                                        ? Offset.zero
                                        : const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  // ── Field Nama ─────────────────────────
                                  _buildLabeledField(
                                    label: 'NAMA',
                                    primaryColor: primaryOrange,
                                    isDark: isDark,
                                    child: TextField(
                                      controller: c.nameController,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                        hintText: 'Masukkan nama lengkap',
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // ── Field NIM (read-only) ──────────────
                                  _buildLabeledField(
                                    label: 'NIM',
                                    primaryColor: primaryOrange,
                                    isDark: isDark,
                                    isReadOnly: true,
                                    child: TextField(
                                      controller: c.nimController,
                                      readOnly: true,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Colors.white54
                                            : Colors.black45,
                                      ),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                        hintText: 'NIM tidak dapat diubah',
                                        hintStyle: TextStyle(
                                          color: isDark
                                              ? Colors.white38
                                              : Colors.black38,
                                          fontSize: 14,
                                        ),
                                        suffixIcon: Icon(
                                          Icons.lock_outline,
                                          size: 14,
                                          color: isDark
                                              ? Colors.white38
                                              : Colors.black38,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // ── Field Semester ─────────────────────
                                  _buildLabeledField(
                                    label: 'SEMESTER',
                                    primaryColor: primaryOrange,
                                    isDark: isDark,
                                    child: TextField(
                                      controller: c.semesterController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter
                                            .digitsOnly,
                                        LengthLimitingTextInputFormatter(2),
                                      ],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                        hintText: 'Contoh: 4',
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // ── Field Jenis Kelamin (Dropdown) ─────
                                  _buildLabeledField(
                                    label: 'JENIS KELAMIN',
                                    primaryColor: primaryOrange,
                                    isDark: isDark,
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        isDense: true,
                                        value: c.selectedGender.isEmpty
                                            ? null
                                            : c.selectedGender,
                                        hint: Text(
                                          'Pilih jenis kelamin',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDark
                                                ? Colors.white54
                                                : Colors.black45,
                                          ),
                                        ),
                                        dropdownColor: isDark
                                            ? const Color(0xFF1F2A3C)
                                            : Colors.white,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                        icon: Icon(
                                          Icons.keyboard_arrow_down,
                                          color: primaryOrange,
                                          size: 20,
                                        ),
                                        onChanged: (val) {
                                          if (val != null) c.setGender(val);
                                        },
                                        items: genderOptions.map((g) {
                                          final label = g == 'male'
                                              ? 'Laki-laki'
                                              : 'Perempuan';
                                          return DropdownMenuItem(
                                            value: g,
                                            child: Text(label),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 28),

                                  // ── Tombol Simpan Perubahan ────────────
                                  SizedBox(
                                    width: double.infinity,
                                    child: GestureDetector(
                                      onTap: c.isLoading
                                          ? null
                                          : () => c.submitUpdate(),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 13.0),
                                        decoration: BoxDecoration(
                                          gradient: c.isLoading
                                              ? LinearGradient(
                                                  colors: [
                                                    primaryOrange.withOpacity(0.6),
                                                    primaryOrange.withOpacity(0.4),
                                                  ],
                                                )
                                              : LinearGradient(
                                                  colors: [
                                                    primaryOrange,
                                                    const Color(0xFFF28500),
                                                  ],
                                                ),
                                          borderRadius:
                                              BorderRadius.circular(24.0),
                                          boxShadow: c.isLoading
                                              ? []
                                              : [
                                                  BoxShadow(
                                                    color: primaryOrange
                                                        .withOpacity(0.4),
                                                    blurRadius: 10,
                                                    offset:
                                                        const Offset(0, 4),
                                                  ),
                                                ],
                                        ),
                                        child: Center(
                                          child: c.isLoading
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2.5,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : const Text(
                                                  'Simpan Perubahan',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold,
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Bottom Navigation Bar ──────────────────────────────────
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomBottomNav(),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget helper untuk membuat field berlabel gaya SpeakApps
  Widget _buildLabeledField({
    required String label,
    required Color primaryColor,
    required bool isDark,
    required Widget child,
    bool isReadOnly = false,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isReadOnly
            ? (isDark
                ? Colors.white.withOpacity(0.04)
                : const Color(0xFFF3F3F3))
            : (isDark
                ? const Color(0xFF1A2235)
                : const Color(0xFFFDF5ED)),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: isReadOnly
              ? primaryColor.withOpacity(0.15)
              : primaryColor.withOpacity(0.4),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: isReadOnly
                  ? primaryColor.withOpacity(0.4)
                  : primaryColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }

  /// Memilih [ImageProvider] yang tepat berdasarkan platform dan state controller:
  /// 1. Web     + webImage ada         → MemoryImage (bytes dari Web picker)
  /// 2. Android + selectedImagePath ada → FileImage  (File dari path String)
  /// 3. Ada foto dari server            → NetworkImage
  /// 4. Fallback                        → AssetImage default
  ///
  /// PENTING: File() hanya dipanggil di dalam blok !kIsWeb sehingga aman
  /// di Web meskipun dart:io diimport — Flutter tidak akan memanggil
  /// kode tersebut di runtime Web.
  ImageProvider _resolveProfileImage(EditProfileController c) {
    // ── Web (Chrome): tampilkan dari bytes pembacaan readAsBytes() ─────────
    if (kIsWeb && c.webImage != null) {
      return MemoryImage(c.webImage!);
    }
    // ── Android: buat FileImage dari path String ─────────────────────────
    // Guard !kIsWeb memastikan File() TIDAK pernah dieksekusi di Web
    if (!kIsWeb &&
        c.selectedImagePath != null &&
        c.selectedImagePath!.isNotEmpty) {
      return FileImage(File(c.selectedImagePath!));
    }
    // ── Foto lama dari server ────────────────────────────────────────
    if (c.userPic.isNotEmpty && c.userPic != 'default.png') {
      final globalUser = Get.isRegistered<GlobalUserController>() ? Get.find<GlobalUserController>() : null;
      final timestamp = globalUser?.imageTimestamp.value ?? DateTime.now().millisecondsSinceEpoch;
      return NetworkImage('${UserService.profilePicBaseUrl}${c.userPic}?v=$timestamp');
    }
    // ── Fallback: gambar default lokal ────────────────────────────────
    return const AssetImage('assets/default.png');
  }
}

import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../user_service.dart';
import 'global_user_controller.dart';

class EditProfileController extends GetxController {
  // ─────────────────────────────────────────────────────────────────────────
  //  Text Controllers
  // ─────────────────────────────────────────────────────────────────────────

  /// Controller untuk field Nama
  final TextEditingController nameController = TextEditingController();

  /// Controller untuk field NIM (read-only – tidak dikirim ke backend)
  final TextEditingController nimController = TextEditingController();

  /// Controller untuk field Semester
  final TextEditingController semesterController = TextEditingController();

  // ─────────────────────────────────────────────────────────────────────────
  //  State gambar (disimpan terpisah per platform untuk menghindari crash)
  // ─────────────────────────────────────────────────────────────────────────

  /// [Android] Path file gambar terpilih (String, bukan File — aman di semua platform)
  String? selectedImagePath;

  /// [Web / Chrome] Data biner gambar yang dipilih (Uint8List, tidak ada path di Web)
  Uint8List? webImage;

  /// Nama file foto profil saat ini (dari backend / SharedPreferences)
  String userPic = '';

  // ─────────────────────────────────────────────────────────────────────────
  //  State lain
  // ─────────────────────────────────────────────────────────────────────────

  /// Gender yang dipilih user ('male' / 'female')
  String selectedGender = '';

  /// State loading — true = tombol dikunci + tampil spinner
  bool isLoading = false;

  // ─────────────────────────────────────────────────────────────────────────
  //  Dependencies
  // ─────────────────────────────────────────────────────────────────────────

  final UserService _userService = UserService();
  final ImagePicker _imagePicker = ImagePicker();

  // ─────────────────────────────────────────────────────────────────────────
  //  Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUserData();
  }

  @override
  void onClose() {
    nameController.dispose();
    nimController.dispose();
    semesterController.dispose();
    super.onClose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Load data profil dari SharedPreferences saat halaman dibuka
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadCurrentUserData() async {
    final prefs = await SharedPreferences.getInstance();
    nameController.text     = prefs.getString('user_name')     ?? '';
    nimController.text      = prefs.getString('user_nim')      ?? '';
    semesterController.text = prefs.getString('user_semester') ?? '';

    final rawGender = (prefs.getString('user_gender') ?? '').toLowerCase();
    if (rawGender == 'laki-laki' || rawGender == 'male') {
      selectedGender = 'male';
    } else if (rawGender == 'perempuan' || rawGender == 'female') {
      selectedGender = 'female';
    } else {
      selectedGender = '';
    }

    userPic = prefs.getString('user_pic') ?? '';
    update();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  pickImage()
  //
  //  Membuka galeri dan menyimpan hasil pilihan sesuai platform:
  //  • Android  → simpan path ke [selectedImagePath]
  //  • Web      → baca bytes ke [webImage]
  //
  //  Anti-crash:
  //  • imageQuality: 30 + maxWidth: 800 → kompres di sisi klien sebelum upload
  //  • if (pickedFile == null) return   → aman jika user cancel
  //  • try-catch                        → aman jika galeri crash / permission ditolak
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 30,  // Kompres 70% → file kecil, aman untuk CI4
        maxWidth: 800,     // Batasi lebar maksimum 800px
      );

      // ── Null-check ketat: user membatalkan → return tanpa error ─────────
      if (pickedFile == null) return;

      if (kIsWeb) {
        // ── Mode WEB (Chrome) ─────────────────────────────────────────────
        // Di Web tidak ada path file nyata → baca sebagai bytes
        webImage = await pickedFile.readAsBytes();
        selectedImagePath = null; // bersihkan state Android
      } else {
        // ── Mode ANDROID ──────────────────────────────────────────────────
        // Simpan path sebagai String saja — File() dibuat di UserService
        // agar tidak ada referensi class File di scope bersama Web
        selectedImagePath = pickedFile.path;
        webImage = null; // bersihkan state Web
      }

      update(); // Perbarui UI: preview foto baru tampil
    } catch (e) {
      _showSnackBar('Tidak dapat membuka galeri: $e', isError: true);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  submitUpdate()
  //
  //  Alur: Validasi → isLoading=true → MultipartRequest → SharedPrefs update
  //        → SnackBar sukses → Get.back()
  //        → catch error → SnackBar dengan detail error untuk debugging
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> submitUpdate() async {
    // ── 1. Validasi input ────────────────────────────────────────────────
    final name     = nameController.text.trim();
    final semester = semesterController.text.trim();

    if (name.isEmpty) {
      _showSnackBar('Nama tidak boleh kosong', isError: true);
      return;
    }
    if (semester.isEmpty || int.tryParse(semester) == null) {
      _showSnackBar('Semester harus berupa angka', isError: true);
      return;
    }
    if (selectedGender.isEmpty) {
      _showSnackBar('Pilih jenis kelamin terlebih dahulu', isError: true);
      return;
    }

    // ── 2. Ambil userId dari SharedPreferences ───────────────────────────
    final prefs  = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) {
      _showSnackBar('Sesi login tidak valid. Silakan login ulang.', isError: true);
      return;
    }

    // ── 3. Kunci tombol + tampilkan spinner ──────────────────────────────
    isLoading = true;
    update();

    try {
      // Field teks (NIM TIDAK dikirim — dijaga read-only)
      final body = {
        'name'    : name,
        'semester': semester,
        'gender'  : selectedGender,
      };

      // Kirim ke UserService yang menangani multipart + platform check
      final result = await _userService.updateProfile(
        userId,
        body,
        selectedImagePath, // String path untuk Android (null = tidak ganti foto)
        webImage,          // Uint8List untuk Web      (null = tidak ganti foto)
      );

      if (result['status'] == 'success') {
        // ── 4a. Update data lokal di SharedPreferences ─────────────────
        final updated = result['data'] as Map<String, dynamic>? ?? {};
        await prefs.setString('user_name',    updated['name']?.toString()        ?? name);
        await prefs.setString('user_semester', updated['semester']?.toString()   ?? semester);
        await prefs.setString('user_gender',   updated['gender']?.toString()     ?? selectedGender);
        
        // Update foto profil ke GlobalUserController
        final newPic = updated['profile_pic']?.toString() ?? userPic;
        if (Get.isRegistered<GlobalUserController>()) {
          await Get.find<GlobalUserController>().updateUserPic(newPic);
        } else {
          await prefs.setString('user_pic', newPic);
        }
        
        userPic = newPic;
        selectedImagePath = null;
        webImage = null;

        // ── 4b. Buka kunci tombol + tampilkan sukses ───────────────────────────────────
        isLoading = false;
        update();
        _showSnackBar('Profil berhasil diperbarui!', isError: false);

        // ── 4c. Kembali ke halaman profil ───────────────────────────────────────
        // Tunggu sedikit agar SnackBar selesai render sebelum navigasi
        // Ini mencegah crash animasi di Chrome Web.
        await Future.delayed(const Duration(milliseconds: 1200));
        
        // Gunakan Navigator native Flutter sebagai metode paling aman.
        // Get.back() bergantung pada GetMaterialApp, tapi sebagai fallback
        // tambahkan Navigator.pop via Get.key.currentContext.
        final ctx = Get.key.currentContext;
        if (ctx != null && Navigator.canPop(ctx)) {
          Navigator.of(ctx).pop();
        } else {
          // Fallback: Get.back() jika context tidak tersedia
          Get.back();
        }
      } else {
        // Backend error → tampilkan detail pesan untuk debugging
        final errMsg = result['message']
            ?? 'Server error (status: ${result['status']})';
        _showSnackBar('Gagal dari server: $errMsg', isError: true);
      }
    } catch (e) {
      // Error jaringan / timeout / JSON parsing → tampilkan detail
      _showSnackBar('Upload gagal: $e', isError: true);
    } finally {
      // Pastikan spinner SELALU berhenti meski ada error apapun
      isLoading = false;
      update();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Helper: set gender dari dropdown
  // ─────────────────────────────────────────────────────────────────────────

  void setGender(String gender) {
    selectedGender = gender;
    update();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Helper: tampilkan SnackBar via GetX
  // ─────────────────────────────────────────────────────────────────────────

  void _showSnackBar(String message, {required bool isError}) {
    // Tutup SnackBar yang masih tampil agar tidak menumpuk
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.snackbar(
      isError ? 'Gagal' : 'Berhasil',
      message,
      backgroundColor: isError ? const Color(0xFFB00020) : const Color(0xFF2E7D32),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: Colors.white,
      ),
    );
  }
}

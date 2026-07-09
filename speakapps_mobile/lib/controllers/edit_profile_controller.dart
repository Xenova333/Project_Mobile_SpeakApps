import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../user_service.dart';

class EditProfileController extends GetxController {
  // ─────────────────────────────────────────────────────────────────────────
  //  Text Controllers
  // ─────────────────────────────────────────────────────────────────────────

  /// Controller untuk field Nama
  final TextEditingController nameController = TextEditingController();

  /// Controller untuk field NIM (read-only)
  final TextEditingController nimController = TextEditingController();

  /// Controller untuk field Semester
  final TextEditingController semesterController = TextEditingController();

  // ─────────────────────────────────────────────────────────────────────────
  //  Reactive State (menggunakan .obs agar UI auto-update via GetBuilder/Obx)
  // ─────────────────────────────────────────────────────────────────────────

  /// Gender yang dipilih user ('male' / 'female' / 'laki-laki' / 'perempuan')
  String selectedGender = '';

  /// File gambar yang dipilih dari galeri (null = belum memilih foto baru)
  File? selectedImage;

  /// File nama gambar profil saat ini (dari backend)
  String userPic = '';

  /// State loading saat proses submit berlangsung
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
  //  Load data profil saat ini dari SharedPreferences
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadCurrentUserData() async {
    final prefs = await SharedPreferences.getInstance();
    nameController.text     = prefs.getString('user_name')     ?? '';
    nimController.text      = prefs.getString('user_nim')      ?? '';
    semesterController.text = prefs.getString('user_semester')  ?? '';
    final rawGender         = (prefs.getString('user_gender')  ?? '').toLowerCase();
    if (rawGender == 'laki-laki' || rawGender == 'male') {
      selectedGender = 'male';
    } else if (rawGender == 'perempuan' || rawGender == 'female') {
      selectedGender = 'female';
    } else {
      selectedGender = '';
    }
    userPic                 = prefs.getString('user_pic')       ?? '';
    update();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  pickImage() – membuka galeri HP dan menyimpan file yang dipilih
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> pickImage() async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,      // Kompres sedikit agar tidak terlalu besar
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (picked != null) {
        selectedImage = File(picked.path);
        update(); // Perbarui UI agar preview foto baru tampil
      }
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat membuka galeri: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  submitUpdate() – validasi → kirim ke backend → update lokal → navigasi
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

    // ── 2. Ambil userId dari SharedPreferences ────────────────────────────
    final prefs  = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId == null) {
      _showSnackBar('Sesi login tidak valid. Silakan login ulang.', isError: true);
      return;
    }

    // ── 3. Tampilkan loading & kirim ke backend ──────────────────────────
    isLoading = true;
    update();

    try {
      final body = {
        'name'    : name,
        'semester': semester,
        'gender'  : selectedGender,
      };

      final result = await _userService.updateProfile(userId, body, selectedImage);

      if (result['status'] == 'success') {
        // ── 4a. Update data lokal di SharedPreferences ─────────────────
        final updatedData = result['data'] as Map<String, dynamic>? ?? {};

        await prefs.setString('user_name',     updatedData['name']?.toString()        ?? name);
        await prefs.setString('user_semester',  updatedData['semester']?.toString()    ?? semester);
        await prefs.setString('user_gender',    updatedData['gender']?.toString()      ?? selectedGender);
        await prefs.setString('user_pic',       updatedData['profile_pic']?.toString() ?? '');

        // ── 4b. Tampilkan SnackBar sukses ──────────────────────────────
        _showSnackBar('Profil berhasil diperbarui!', isError: false);

        // ── 4c. Kembali ke halaman sebelumnya (profil / halaman utama) ─
        await Future.delayed(const Duration(milliseconds: 800));
        Get.back();
      } else {
        // Backend mengembalikan error
        _showSnackBar(result['message'] ?? 'Gagal memperbarui profil', isError: true);
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e', isError: true);
    } finally {
      isLoading = false;
      update();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Helper: set gender dari dropdown / pilihan UI
  // ─────────────────────────────────────────────────────────────────────────

  void setGender(String gender) {
    selectedGender = gender;
    update();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Helper: SnackBar menggunakan GetX
  // ─────────────────────────────────────────────────────────────────────────

  void _showSnackBar(String message, {required bool isError}) {
    Get.snackbar(
      isError ? 'Gagal' : 'Berhasil',
      message,
      backgroundColor: isError ? Colors.red : Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
    );
  }
}

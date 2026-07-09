import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controller global untuk background chat.
/// Setiap akun (user_id) menyimpan wallpaper-nya masing-masing di SharedPreferences
/// dengan key yang memuat user_id, sehingga ganti akun = background berbeda.
class ChatBackgroundController extends GetxController {
  // ── State Reaktif ──────────────────────────────────────────────────────────

  /// Path file gambar background (Android). Null = tidak ada background.
  var bgImagePath = Rxn<String>();

  /// Data biner gambar background (Web/Chrome). Null = tidak ada background.
  var bgImageBytes = Rxn<Uint8List>();

  /// Matriks transformasi (posisi pan + zoom) tersimpan dari WallpaperPreviewPage.
  var bgMatrix = Matrix4.identity().obs;

  /// Suffix kunci SharedPreferences berdasarkan user_id yang sedang login.
  /// Default 'guest' agar tidak crash sebelum user_id tersedia.
  String _userSuffix = 'guest';

  // ── Key helpers ────────────────────────────────────────────────────────────
  String get _kPath   => 'chat_bg_path_$_userSuffix';
  String get _kBase64 => 'chat_bg_base64_$_userSuffix';
  String get _kMatrix => 'chat_bg_matrix_$_userSuffix';

  // ── Flag background aktif ──────────────────────────────────────────────────
  bool get hasBackground {
    if (kIsWeb) return bgImageBytes.value != null;
    return bgImagePath.value != null && bgImagePath.value!.isNotEmpty;
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _initForCurrentUser();
  }

  // ── Inisialisasi per-user ──────────────────────────────────────────────────

  /// Dipanggil saat controller pertama kali di-init, dan bisa dipanggil ulang
  /// setelah login/logout untuk memuat background akun yang baru.
  Future<void> _initForCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    _userSuffix = userId != null ? 'user_$userId' : 'guest';
    await _loadFromPrefs(prefs);
  }

  /// Panggil method ini setelah login berhasil agar background langsung
  /// disesuaikan dengan akun yang baru login.
  Future<void> reloadForUser(int userId) async {
    // Bersihkan state dulu
    bgImagePath.value = null;
    bgImageBytes.value = null;
    bgMatrix.value = Matrix4.identity();

    _userSuffix = 'user_$userId';
    final prefs = await SharedPreferences.getInstance();
    await _loadFromPrefs(prefs);
  }

  // ── Load dari SharedPreferences ────────────────────────────────────────────

  Future<void> _loadFromPrefs(SharedPreferences prefs) async {
    // Load matriks transformasi
    final matrixJson = prefs.getString(_kMatrix);
    if (matrixJson != null) {
      try {
        final List<dynamic> raw = jsonDecode(matrixJson);
        final List<double> storage =
            raw.map((e) => (e as num).toDouble()).toList();
        if (storage.length == 16) {
          bgMatrix.value = Matrix4.fromList(storage);
        }
      } catch (_) {
        bgMatrix.value = Matrix4.identity();
      }
    } else {
      bgMatrix.value = Matrix4.identity();
    }

    // Load gambar
    if (kIsWeb) {
      final base64Str = prefs.getString(_kBase64);
      if (base64Str != null && base64Str.isNotEmpty) {
        try {
          bgImageBytes.value = base64Decode(base64Str);
        } catch (_) {
          bgImageBytes.value = null;
        }
      } else {
        bgImageBytes.value = null;
      }
    } else {
      bgImagePath.value = prefs.getString(_kPath);
    }
  }

  // ── Simpan ke SharedPreferences ────────────────────────────────────────────

  Future<void> applyBackground({
    required Matrix4 matrix,
    String? imagePath,     // Android
    Uint8List? imageBytes, // Web
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Simpan matriks
    final List<double> storage = matrix.storage.toList();
    await prefs.setString(_kMatrix, jsonEncode(storage));
    bgMatrix.value = matrix;

    // Simpan gambar
    if (kIsWeb && imageBytes != null) {
      await prefs.setString(_kBase64, base64Encode(imageBytes));
      bgImageBytes.value = imageBytes;
    } else if (!kIsWeb && imagePath != null) {
      await prefs.setString(_kPath, imagePath);
      bgImagePath.value = imagePath;
    }
  }

  // ── Hapus Background akun ini ──────────────────────────────────────────────

  Future<void> removeBackground() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPath);
    await prefs.remove(_kBase64);
    await prefs.remove(_kMatrix);

    bgImagePath.value = null;
    bgImageBytes.value = null;
    bgMatrix.value = Matrix4.identity();
  }

  // ── Buka galeri ────────────────────────────────────────────────────────────
  // Mengembalikan data gambar; navigasi ke WallpaperPreviewPage
  // dilakukan di UI (BackgroundPesanPage) agar tidak circular import.

  Future<({String? path, Uint8List? bytes})?> pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (picked == null) return null;

      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        return (path: null, bytes: bytes);
      } else {
        return (path: picked.path, bytes: null);
      }
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat membuka galeri: $e',
        backgroundColor: const Color(0xFFB00020),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }
}

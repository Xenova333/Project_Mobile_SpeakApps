import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_background_controller.dart';

/// Halaman preview wallpaper — user bisa pan & zoom gambar sebelum menerapkannya.
///
/// Setelah menekan "Terapkan", matriks transformasi (posisi zoom + pan) disimpan
/// ke SharedPreferences melalui [ChatBackgroundController.applyBackground].
class WallpaperPreviewPage extends StatefulWidget {
  /// Path file gambar — digunakan di Android.
  final String? imagePath;

  /// Bytes gambar — digunakan di Web (Chrome).
  final Uint8List? imageBytes;

  const WallpaperPreviewPage({
    super.key,
    this.imagePath,
    this.imageBytes,
  });

  @override
  State<WallpaperPreviewPage> createState() => _WallpaperPreviewPageState();
}

class _WallpaperPreviewPageState extends State<WallpaperPreviewPage> {
  // TransformationController merekam posisi pan & zoom secara real-time
  late final TransformationController _transformCtrl;

  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _transformCtrl = TransformationController();
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final primaryOrange = const Color(0xFFF6A039);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // ── 1. Area InteractiveViewer (pan & zoom bebas) ──────────────
            SizedBox(
              width: size.width,
              height: size.height,
              child: InteractiveViewer(
                transformationController: _transformCtrl,
                panEnabled: true,
                scaleEnabled: true,
                minScale: 1.0,
                maxScale: 4.0,
                child: _buildImage(size),
              ),
            ),

            // ── 2. Top Bar ─────────────────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Geser & Zoom untuk menyesuaikan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // balancing spacer
                  ],
                ),
              ),
            ),

            // ── 3. Bottom Bar: Tombol Terapkan ─────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.85),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // Tombol Reset posisi
                    Expanded(
                      flex: 1,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _transformCtrl.value = Matrix4.identity();
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Reset'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Tombol Terapkan
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _isApplying ? null : _apply,
                        icon: _isApplying
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.check_circle_outline, size: 20),
                        label: Text(_isApplying ? 'Menyimpan...' : 'Terapkan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor: primaryOrange.withOpacity(0.5),
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
    );
  }

  // ── Gambar: pilih ImageProvider sesuai platform ───────────────────────────

  Widget _buildImage(Size size) {
    if (kIsWeb && widget.imageBytes != null) {
      return Image.memory(
        widget.imageBytes!,
        width: size.width,
        height: size.height,
        fit: BoxFit.contain,
      );
    }
    if (!kIsWeb && widget.imagePath != null) {
      return Image.file(
        File(widget.imagePath!),
        width: size.width,
        height: size.height,
        fit: BoxFit.contain,
      );
    }
    // Fallback: tidak seharusnya terjadi
    return const Center(
      child: Text('Gambar tidak tersedia', style: TextStyle(color: Colors.white)),
    );
  }

  // ── Terapkan: simpan gambar + matriks ke SharedPreferences ───────────────

  Future<void> _apply() async {
    setState(() => _isApplying = true);

    try {
      final ctrl = Get.find<ChatBackgroundController>();

      // Ambil matriks saat ini dari TransformationController
      final Matrix4 currentMatrix = Matrix4.copy(_transformCtrl.value);

      await ctrl.applyBackground(
        matrix: currentMatrix,
        imagePath: kIsWeb ? null : widget.imagePath,
        imageBytes: kIsWeb ? widget.imageBytes : null,
      );

      if (mounted) {
        Get.back(); // Kembali ke BackgroundPesanPage
        Get.snackbar(
          'Berhasil',
          'Latar belakang chat berhasil diterapkan!',
          backgroundColor: const Color(0xFF2E7D32),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(12),
          borderRadius: 10,
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Gagal',
          'Tidak dapat menyimpan background: $e',
          backgroundColor: const Color(0xFFB00020),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }
}

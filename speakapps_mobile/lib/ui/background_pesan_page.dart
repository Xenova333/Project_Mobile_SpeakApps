import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_background_controller.dart';
import 'wallpaper_preview_page.dart';
import 'widgets/custom_bottom_nav.dart';

class BackgroundPesanPage extends StatelessWidget {
  const BackgroundPesanPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan Get.find — controller sudah terdaftar sebagai permanent di main.dart.
    // Pastikan ChatBackgroundController tersedia (sudah permanent dari main.dart)
    // Tidak perlu Get.put lagi — cukup find.
    final ctrl = Get.find<ChatBackgroundController>();
    final primaryOrange = const Color(0xFFF6A039);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // ── App Bar ──────────────────────────────────────────────────
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
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.arrow_back,
                            size: 24,
                            color: isDark ? Colors.white : Colors.black87),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Background Pesan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Body ─────────────────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 110),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // ── Chat Preview Container ────────────────────────────
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Obx(() {
                            final hasBg = ctrl.hasBackground;
                            return Container(
                              height: 420,
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF0A1128)
                                    : const Color(0xFFF4F7F6),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: isDark
                                        ? primaryOrange.withOpacity(0.6)
                                        : primaryOrange.withOpacity(0.3),
                                    width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryOrange.withOpacity(
                                        isDark ? 0.4 : 0.2),
                                    blurRadius: isDark ? 20 : 12,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              // ── Struktur identik dengan ChatPage yang sebenarnya ──
                              child: Column(
                                children: [
                                  // ① Header — SOLID background (TIDAK tertutup wallpaper)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 10.0),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF111C44)
                                          : Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.arrow_back_ios_new,
                                            size: 14,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87),
                                        const SizedBox(width: 6),
                                        Container(
                                          width: 26,
                                          height: 26,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: primaryOrange, width: 1.5),
                                          ),
                                          child: const Icon(Icons.person,
                                              size: 14, color: Colors.grey),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'nama teman',
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black87),
                                        ),
                                        const Spacer(),
                                        Icon(Icons.more_vert,
                                            size: 16,
                                            color: isDark
                                                ? Colors.white70
                                                : Colors.black54),
                                      ],
                                    ),
                                  ),

                                  // ② Area Pesan — wallpaper HANYA di sini
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        // Background wallpaper
                                        if (hasBg)
                                          SizedBox.expand(
                                            child: InteractiveViewer(
                                              panEnabled: false,
                                              scaleEnabled: false,
                                              transformationController:
                                                  TransformationController()
                                                    ..value =
                                                        ctrl.bgMatrix.value,
                                              child: _buildBgImage(ctrl),
                                            ),
                                          )
                                        else
                                          // Warna default ketika tidak ada wallpaper
                                          Positioned.fill(
                                            child: ColoredBox(
                                              color: isDark
                                                  ? const Color(0xFF0A1128)
                                                  : const Color(0xFFF4F7F6),
                                            ),
                                          ),

                                        // Bubble chat di atas wallpaper
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0, vertical: 10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              _buildPreviewReceivedChat(
                                                  primaryOrange, isDark),
                                              const SizedBox(height: 10),
                                              _buildPreviewSentChat(
                                                  primaryOrange),
                                              const SizedBox(height: 10),
                                              _buildPreviewReceivedChat(
                                                  primaryOrange, isDark),
                                              const SizedBox(height: 10),
                                              _buildPreviewSentChat(
                                                  primaryOrange),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // ③ Input Field — SOLID background (TIDAK tertutup wallpaper)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 8.0),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF111C44)
                                          : Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 4,
                                          offset: const Offset(0, -2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.add_circle_outline,
                                            size: 18,
                                            color: isDark
                                                ? Colors.white54
                                                : Colors.black38),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? const Color(0xFF0A1128)
                                                  : const Color(0xFFF0F2F5),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                              'Ketik pesan...',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: isDark
                                                      ? Colors.white38
                                                      : Colors.black38),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: primaryOrange,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                              Icons.send_rounded,
                                              size: 14,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 30),

                        // ── Action Buttons ────────────────────────────────────
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 60.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Pilih Gambar Baru
                              _buildActionButton(
                                context: context,
                                text: 'Pilih Gambar dari Galeri',
                                icon: Icons.photo_library_outlined,
                                bgColor: Colors.white,
                                textColor: Colors.black87,
                                borderColor: primaryOrange,
                                onTap: () async {
                                  final result = await ctrl.pickImage();
                                  if (result == null) return;
                                  // Navigasi ke preview — dilakukan di UI, bukan di controller
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => WallpaperPreviewPage(
                                        imagePath: result.path,
                                        imageBytes: result.bytes,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),

                              // Hapus Background
                              Obx(() => ctrl.hasBackground
                                  ? Column(
                                      children: [
                                        _buildActionButton(
                                          context: context,
                                          text: 'Hapus Background',
                                          icon: Icons.delete_outline,
                                          bgColor: const Color(0xFFFCDCDC),
                                          textColor: const Color(0xFFB00020),
                                          borderColor: Colors.transparent,
                                          onTap: () => _confirmRemove(context, ctrl),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                    )
                                  : const SizedBox.shrink()),
                            ],
                          ),
                        ),

                        // ── Tip ───────────────────────────────────────────────
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 32.0, vertical: 16.0),
                          child: Text(
                            'Tip: Setelah memilih gambar, geser dan zoom '
                            'sesuai keinginan, lalu tekan Terapkan.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Bottom Navigation
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

  // ── Helper: tampilkan gambar background sesuai platform ──────────────────

  Widget _buildBgImage(ChatBackgroundController ctrl) {
    if (kIsWeb && ctrl.bgImageBytes.value != null) {
      return Image.memory(
        ctrl.bgImageBytes.value!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (!kIsWeb &&
        ctrl.bgImagePath.value != null &&
        ctrl.bgImagePath.value!.isNotEmpty) {
      return Image.file(
        File(ctrl.bgImagePath.value!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    return const SizedBox.shrink();
  }

  // ── Konfirmasi hapus background ──────────────────────────────────────────

  void _confirmRemove(BuildContext context, ChatBackgroundController ctrl) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Background?'),
        content: const Text(
            'Latar belakang chat akan dikembalikan ke tampilan default.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              ctrl.removeBackground();
              Navigator.pop(ctx);
            },
            child: const Text('Hapus',
                style: TextStyle(color: Color(0xFFB00020))),
          ),
        ],
      ),
    );
  }

  // ── UI Helpers ───────────────────────────────────────────────────────────

  Widget _buildPreviewReceivedChat(Color primaryColor, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1A2652).withOpacity(0.9)
              : Colors.white.withOpacity(0.92),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: const Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Text('isi chat', style: TextStyle(fontSize: 10)),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child:
                  Text('10:00', style: TextStyle(fontSize: 8, color: Colors.black54)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSentChat(Color primaryColor) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor.withOpacity(0.85), primaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: const Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Text('isi chat',
                  style: TextStyle(fontSize: 10, color: Colors.white)),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Text('10:00',
                  style: TextStyle(fontSize: 8, color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

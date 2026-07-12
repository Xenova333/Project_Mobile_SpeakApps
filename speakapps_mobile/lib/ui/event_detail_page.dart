import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/event_model.dart';
import '../controllers/event_controller.dart';

class EventDetailPage extends StatelessWidget {
  final EventModel event;

  const EventDetailPage({Key? key, required this.event}) : super(key: key);

  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Get.snackbar('Error', 'Could not launch $url');
    }
  }

  void _showEditDialog(BuildContext context, EventController controller) {
    final titleController = TextEditingController(text: event.title);
    final descriptionController = TextEditingController(text: event.description);
    final dateController = TextEditingController(text: event.eventDate ?? '');
    final linkController = TextEditingController(text: event.eventLink ?? '');
    final ImagePicker picker = ImagePicker();
    XFile? selectedImage;

    // Gunakan showModalBottomSheet agar dapat ukuran layar penuh (tidak kena bug AlertDialog)
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.92,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (_, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      // ── Handle bar ──────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // ── Header ──────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            const Text(
                              'Edit Event',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(sheetContext),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // ── Form (scrollable) ────────────────────────────────
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 16,
                            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Pratinjau gambar saat ini
                              if (event.image != null && event.image!.isNotEmpty && selectedImage == null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    event.image!,
                                    height: 140,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 140,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                                    ),
                                  ),
                                ),

                              // Indikator gambar baru dipilih
                              if (selectedImage != null)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.green[300]!),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Gambar dipilih: ${selectedImage!.name}',
                                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              const SizedBox(height: 12),

                              // Tombol pilih gambar
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.image_outlined),
                                  label: const Text('Ganti Gambar Banner'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: const BorderSide(color: Color(0xFFF6A039)),
                                    foregroundColor: const Color(0xFFF6A039),
                                  ),
                                  onPressed: () async {
                                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                                    if (image != null) {
                                      setModalState(() => selectedImage = image);
                                    }
                                  },
                                ),
                              ),

                              const SizedBox(height: 20),
                              _buildFormField(titleController, 'Judul Event', Icons.title),
                              const SizedBox(height: 16),
                              _buildFormField(descriptionController, 'Deskripsi', Icons.description_outlined, maxLines: 4),
                              const SizedBox(height: 16),
                              // Date field dengan date picker
                              TextFormField(
                                controller: dateController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Tanggal Event',
                                  prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFFF6A039)),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFF6A039), width: 2),
                                  ),
                                ),
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: sheetContext,
                                    initialDate: DateTime.tryParse(dateController.text) ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null) {
                                    dateController.text =
                                        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildFormField(linkController, 'Tautan (Link Web/IG)', Icons.link),
                              const SizedBox(height: 28),

                              // Tombol Simpan
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF6A039),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  onPressed: () async {
                                    Uint8List? imgBytes;
                                    String? imgPath;
                                    if (selectedImage != null) {
                                      if (kIsWeb) {
                                        imgBytes = await selectedImage!.readAsBytes();
                                      } else {
                                        imgPath = selectedImage!.path;
                                      }
                                    }

                                    final result = await controller.updateEvent(
                                      id: event.id,
                                      title: titleController.text,
                                      description: descriptionController.text,
                                      eventDate: dateController.text,
                                      eventLink: linkController.text.isNotEmpty ? linkController.text : null,
                                      imagePath: imgPath,
                                      imageBytes: imgBytes,
                                    );
                                    if (result['status'] == 'success') {
                                      Navigator.pop(sheetContext);
                                      Get.back();
                                      Get.snackbar(
                                        'Sukses',
                                        'Data event berhasil diupdate',
                                        backgroundColor: Colors.green,
                                        colorText: Colors.white,
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    }
                                  },
                                  child: const Text(
                                    'Simpan Perubahan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
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
                );
              },
            );
          },
        );
      },
    );
  }

  // Helper untuk field teks standar
  Widget _buildFormField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFF6A039)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF6A039), width: 2),
        ),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final RxBool isMain = (event.isMain == 1).obs;
    final controller = Get.find<EventController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Detail Event',
            style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF0F172A), const Color(0xFF1E3A5F)]
                  : [const Color(0xFFF9EFE5), const Color(0xFFF6A039)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        iconTheme: IconThemeData(color: iconColor),
        actions: [
          Obx(() {
            if (controller.isAdmin.value) {
              return Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isMain.value ? Icons.star : Icons.star_border,
                      color: isMain.value ? Colors.orange : iconColor,
                    ),
                    tooltip: 'Set as Main Event',
                    onPressed: () async {
                      bool success = await controller.setMainEvent(event.id);
                      if (success) {
                        isMain.value = true;
                        controller.fetchMainEvent();
                        Get.back();
                        Get.snackbar('Sukses', 'Berhasil mengatur sebagai Main Event');
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: iconColor),
                    tooltip: 'Edit Event',
                    onPressed: () => _showEditDialog(context, controller),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Card(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            margin: const EdgeInsets.all(16.0),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Elemen 1: Gambar Banner di Dalam Card ─────────────
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: (event.image != null && event.image!.isNotEmpty)
                      ? Image.network(
                          event.image!,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: double.infinity,
                            height: 220,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 60,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: 220,
                          color: isDark
                              ? const Color(0xFF263548)
                              : const Color(0xFFE0D6C8),
                          child: const Center(
                            child: Icon(
                              Icons.event,
                              size: 80,
                              color: Color(0xFFF6A039),
                            ),
                          ),
                        ),
                ),

                // ─── Elemen 2: Konten Teks ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul
                      Text(
                        event.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Tanggal + Ikon
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: isDark ? Colors.white60 : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            event.eventDate ?? '-',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.grey,
                            ),
                          ),
                        ],
                      ),

                      Divider(
                        height: 30,
                        thickness: 1,
                        color: isDark ? Colors.white24 : Colors.grey[300],
                      ),

                      // Deskripsi
                      Text(
                        event.description,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black87,
                          height: 1.4,
                        ),
                      ),

                      // Tombol (hanya muncul jika ada link)
                      if (event.eventLink != null &&
                          event.eventLink!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF6A039),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _launchUrl(event.eventLink),
                            child: const Text(
                              'Selengkapnya',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

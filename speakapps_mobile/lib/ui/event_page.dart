import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'dart:io';
import '../controllers/event_controller.dart';
import '../models/event_model.dart';
import 'event_detail_page.dart';

class EventPage extends StatefulWidget {
  final int? selectedMonth;

  EventPage({Key? key, this.selectedMonth}) : super(key: key);

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  final EventController controller = Get.put(EventController());
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.currentMonth = widget.selectedMonth;
      controller.fetchEvents();
    });
  }

  void _showEventDialog(BuildContext context, {EventModel? event}) {
    final isEdit = event != null;
    final titleController = TextEditingController(text: event?.title ?? '');
    final descriptionController = TextEditingController(text: event?.description ?? '');
    final dateController = TextEditingController(text: event?.eventDate ?? '');
    final linkController = TextEditingController(text: event?.eventLink ?? '');
    XFile? selectedImage;

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
                      // ── Handle bar ────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Container(
                          width: 40, height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // ── Header ────────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6A039).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isEdit ? Icons.edit_outlined : Icons.add_circle_outline,
                                color: const Color(0xFFF6A039),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              isEdit ? 'Edit Event' : 'Tambah Event',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.black54),
                              onPressed: () => Navigator.pop(sheetContext),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // ── Form (scrollable) ─────────────────────────────────
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: EdgeInsets.only(
                            left: 20, right: 20, top: 20,
                            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Pratinjau gambar (mode edit)
                              if (isEdit && event.image != null && event.image!.isNotEmpty && selectedImage == null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    event.image!,
                                    height: 140,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _imageFallback(),
                                  ),
                                ),

                              // Indikator gambar baru dipilih
                              if (selectedImage != null)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.green[300]!),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.green, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          selectedImage!.name,
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              const SizedBox(height: 14),

                              // Tombol pilih gambar
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.image_search_outlined, size: 20),
                                  label: Text(selectedImage == null ? 'Pilih Gambar Banner' : 'Ganti Gambar'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    side: const BorderSide(color: Color(0xFFF6A039)),
                                    foregroundColor: const Color(0xFFF6A039),
                                  ),
                                  onPressed: () async {
                                    final XFile? img = await _picker.pickImage(source: ImageSource.gallery);
                                    if (img != null) setModalState(() => selectedImage = img);
                                  },
                                ),
                              ),

                              const SizedBox(height: 22),
                              const Text('Detail Event', style: TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 10),

                              // Judul Event
                              _buildField(titleController, 'Judul Event', Icons.title_outlined),
                              const SizedBox(height: 14),

                              // Deskripsi
                              _buildField(descriptionController, 'Deskripsi', Icons.notes_outlined, maxLines: 4),
                              const SizedBox(height: 14),

                              // Tanggal (date picker)
                              TextFormField(
                                controller: dateController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Tanggal Event',
                                  prefixIcon: const Icon(Icons.calendar_month_outlined, color: Color(0xFFF6A039)),
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
                                    builder: (ctx, child) => Theme(
                                      data: Theme.of(ctx).copyWith(
                                        colorScheme: const ColorScheme.light(primary: Color(0xFFF6A039)),
                                      ),
                                      child: child!,
                                    ),
                                  );
                                  if (picked != null) {
                                    dateController.text =
                                        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                                  }
                                },
                              ),
                              const SizedBox(height: 14),

                              // Tautan
                              _buildField(linkController, 'Tautan (Link Web/IG)', Icons.link_outlined),
                              const SizedBox(height: 30),

                              // ── Tombol aksi ────────────────────────────────
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => Navigator.pop(sheetContext),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        side: BorderSide(color: Colors.grey[400]!),
                                        foregroundColor: Colors.black54,
                                      ),
                                      child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFF6A039),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

                                        Map<String, dynamic> result;
                                        if (!isEdit) {
                                          result = await controller.createEvent(
                                            title: titleController.text,
                                            description: descriptionController.text,
                                            eventDate: dateController.text,
                                            eventLink: linkController.text.isNotEmpty ? linkController.text : null,
                                            createdBy: 0,
                                            imagePath: imgPath,
                                            imageBytes: imgBytes,
                                          );
                                        } else {
                                          result = await controller.updateEvent(
                                            id: event.id,
                                            title: titleController.text,
                                            description: descriptionController.text,
                                            eventDate: dateController.text,
                                            eventLink: linkController.text.isNotEmpty ? linkController.text : null,
                                            imagePath: imgPath,
                                            imageBytes: imgBytes,
                                          );
                                        }
                                        if (result['status'] == 'success') {
                                          Navigator.pop(sheetContext);
                                          Get.snackbar(
                                            'Sukses', 'Data event berhasil disimpan',
                                            backgroundColor: Colors.green,
                                            colorText: Colors.white,
                                            snackPosition: SnackPosition.BOTTOM,
                                          );
                                        }
                                      },
                                      child: Text(
                                        isEdit ? 'Simpan Perubahan' : 'Tambah Event',
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
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

  // Helper: field teks berdesain
  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {int maxLines = 1}) {
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

  // Helper: fallback gambar broken
  Widget _imageFallback() => Container(
    height: 140, width: double.infinity,
    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
    child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
  );

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ikon peringatan
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.red, size: 32),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Hapus Event?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Event ini akan dihapus secara permanen dan tidak dapat dikembalikan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: Colors.grey[400]!),
                          foregroundColor: Colors.black54,
                        ),
                        child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          final result = await controller.deleteEvent(id);
                          Navigator.pop(context);
                          if (result['status'] == 'success') {
                            Get.snackbar(
                              'Dihapus', 'Event berhasil dihapus',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        },
                        child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9EFE5), // Latar warna lembut sesuai mockup
      appBar: AppBar(
        title: const Text('Berita dan Informasi', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF9EFE5), Color(0xFFF6A039)], // Gradasi krem oranye
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          Obx(() {
            if (controller.isAdmin.value) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: controller.isDeleteMode.value ? Colors.red : Colors.black87,
                    ),
                    onPressed: () {
                      controller.toggleDeleteMode();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.black87),
                    onPressed: () => _showEventDialog(context),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  "Tidak ada event bulan ini",
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.events.length,
          itemBuilder: (context, index) {
            final event = controller.events[index];
            return GestureDetector(
              onTap: () {
                if (controller.isDeleteMode.value) {
                  _confirmDelete(context, event.id);
                } else {
                  Get.to(() => EventDetailPage(event: event));
                }
              },
              child: Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: controller.isDeleteMode.value
                      ? const BorderSide(color: Colors.red, width: 2)
                      : BorderSide.none,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Elemen 1 (Atas): Gambar
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: event.image != null && event.image!.isNotEmpty
                          ? Image.network(
                              event.image!,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 180,
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                  ),
                                );
                              },
                            )
                          : Container(
                              height: 180,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Text('gambar event/berita', style: TextStyle(color: Colors.grey)),
                              ),
                            ),
                    ),
                    // Elemen 2 & 3 (Bawah): Teks dan Tombol
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  event.eventDate ?? '-',
                                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

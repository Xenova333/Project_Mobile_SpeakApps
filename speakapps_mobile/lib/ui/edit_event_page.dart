import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api_services.dart';
import '../models/event_model.dart';
import '../controllers/event_controller.dart';

class EditEventPage extends StatefulWidget {
  final EventModel event;

  const EditEventPage({super.key, required this.event});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dateController;
  late TextEditingController _linkController;
  String? _imagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(text: widget.event.description ?? '');
    _dateController = TextEditingController(text: widget.event.eventDate ?? '');
    _linkController = TextEditingController(text: widget.event.eventLink ?? '');
    _imagePath = null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _handleSubmit() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final eventDate = _dateController.text.trim();
    final eventLink = _linkController.text.trim();

    if (title.isEmpty) {
      Get.snackbar('Error', 'Judul event wajib diisi',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (eventDate.isEmpty) {
      Get.snackbar('Error', 'Tanggal event wajib diisi',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final controller = Get.find<EventController>();
      final result = await controller.updateEvent(
        id: widget.event.id,
        title: title,
        description: description,
        eventDate: eventDate,
        eventLink: eventLink.isNotEmpty ? eventLink : null,
        imagePath: _imagePath,
      );

      if (!mounted) return;

      if (result['status'] == 'success') {
        Get.snackbar('Sukses', 'Event berhasil diperbarui',
            backgroundColor: Colors.green, colorText: Colors.white);
        Navigator.pop(context);
      } else {
        Get.snackbar('Error', result['message'] ?? 'Gagal memperbarui event',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryOrange = const Color(0xFFF6A039);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentImageUrl = ApiConfig.eventImage(widget.event.image);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Custom App Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0A1128) : null,
                    gradient: isDark ? null : LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        primaryOrange.withOpacity(0.8),
                        primaryOrange.withOpacity(0.4),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.arrow_back, size: 24, color: isDark ? Colors.white : Colors.black87),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Edit Event',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Form
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Current Image Preview
                        if (currentImageUrl.isNotEmpty) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              currentImageUrl,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 150,
                                  color: Colors.grey[200],
                                  child: const Center(child: Icon(Icons.event, size: 50, color: Colors.grey)),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Title Field
                        _buildTextField(
                          controller: _titleController,
                          label: 'Judul Event',
                          icon: Icons.title,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),

                        // Date Field
                        GestureDetector(
                          onTap: _pickDate,
                          child: AbsorbPointer(
                            child: _buildTextField(
                              controller: _dateController,
                              label: 'Tanggal Event',
                              icon: Icons.calendar_today,
                              isDark: isDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Description Field
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Deskripsi',
                          icon: Icons.description,
                          isDark: isDark,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 16),

                        // Link Field
                        _buildTextField(
                          controller: _linkController,
                          label: 'Link Event (opsional)',
                          icon: Icons.link,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),

                        // Image Picker (placeholder)
                        GestureDetector(
                          onTap: () async {
                            Get.snackbar('Info', 'Image picker akan segera hadir',
                                backgroundColor: Colors.blue, colorText: Colors.white);
                          },
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1A2456) : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? Colors.white24 : Colors.grey[300]!,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate,
                                    size: 36, color: isDark ? Colors.white54 : Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text(
                                  'Ganti Gambar (opsional)',
                                  style: TextStyle(
                                    color: isDark ? Colors.white54 : Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: _isLoading ? null : _handleSubmit,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _isLoading
                                      ? [Colors.grey.shade400, Colors.grey.shade400]
                                      : [primaryOrange, primaryOrange.withOpacity(0.8)],
                                ),
                                borderRadius: BorderRadius.circular(25),
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
                                        'Simpan Perubahan',
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
                ),
              ],
            ),

            // Loading Overlay
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFFF6A039)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2456) : Colors.white,
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
        maxLines: maxLines,
        style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12),
          prefixIcon: Icon(icon, color: const Color(0xFFF6A039), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/event_controller.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final _linkController = TextEditingController();
  String? _imagePath;
  Uint8List? _imageBytes;
  bool _isLoading = false;
  int _userId = 0;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('user_id') ?? 0;
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
      final result = await controller.createEvent(
        title: title,
        description: description,
        eventDate: eventDate,
        eventLink: eventLink.isNotEmpty ? eventLink : null,
        imagePath: _imagePath,
        imageBytes: _imageBytes,
        createdBy: _userId,
      );

      if (!mounted) return;

      if (result['status'] == 'success') {
        Get.snackbar('Sukses', 'Event berhasil dibuat',
            backgroundColor: Colors.green, colorText: Colors.white);
        Navigator.pop(context);
      } else {
        Get.snackbar('Error', result['message'] ?? 'Gagal membuat event',
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
                          'Tambah Event',
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

                        // Image Picker
                        GestureDetector(
                          onTap: () async {
                            final picker = ImagePicker();
                            final picked = await picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 80,
                              maxWidth: 1200,
                            );
                            if (picked != null) {
                              if (kIsWeb) {
                                final bytes = await picked.readAsBytes();
                                setState(() {
                                  _imagePath = null;
                                  _imageBytes = bytes;
                                });
                              } else {
                                setState(() {
                                  _imagePath = picked.path;
                                  _imageBytes = null;
                                });
                              }
                            }
                          },
                          child: Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1A2456) : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? Colors.white24 : Colors.grey[300]!,
                              ),
                            ),
                            child: _buildImagePreview(isDark),
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
                                        'Buat Event',
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

  Widget _buildImagePreview(bool isDark) {
    if (_imageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(_imageBytes!, fit: BoxFit.cover, width: double.infinity, height: 120),
      );
    } else if (_imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(File(_imagePath!), fit: BoxFit.cover, width: double.infinity, height: 120),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate, size: 40, color: isDark ? Colors.white54 : Colors.grey[400]),
        const SizedBox(height: 8),
        Text('Pilih Gambar', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[500], fontSize: 12)),
      ],
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

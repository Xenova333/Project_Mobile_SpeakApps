import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_services.dart';
import '../models/event_model.dart';
import '../controllers/event_controller.dart';
import 'widgets/custom_bottom_nav.dart';

class NewsDetailPage extends StatefulWidget {
  final EventModel event;

  const NewsDetailPage({
    super.key,
    required this.event,
  });

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  String _userRole = 'user';

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role') ?? 'user';
    setState(() => _userRole = role);
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Event'),
        content: Text('Yakin ingin menghapus "${widget.event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final controller = Get.find<EventController>();
              final result = await controller.deleteEvent(widget.event.id);
              if (result['status'] == 'success') {
                Get.snackbar('Sukses', 'Event berhasil dihapus',
                    backgroundColor: Colors.green, colorText: Colors.white);
                Navigator.pop(context);
              } else {
                Get.snackbar('Error', result['message'] ?? 'Gagal menghapus event',
                    backgroundColor: Colors.red, colorText: Colors.white);
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryOrange = const Color(0xFFF6A039);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final event = widget.event;
    final imageUrl = ApiConfig.eventImage(event.image);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: bgColor,
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
                        child: Icon(Icons.arrow_back, size: 28, color: isDark ? Colors.white : Colors.black87),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Detail Event',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      if (_userRole == 'admin') ...[
                        GestureDetector(
                          onTap: _showDeleteDialog,
                          child: Icon(Icons.delete, size: 22, color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0).copyWith(bottom: 100),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF111C44) : Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Header
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Container(
                              width: double.infinity,
                              height: 200,
                              color: const Color(0xFFFDF5ED),
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(
                                          child: Icon(Icons.event, color: Colors.grey, size: 50),
                                        );
                                      },
                                    )
                                  : const Center(
                                      child: Icon(Icons.event, color: Colors.grey, size: 50),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Title
                          Text(
                            event.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Date Row
                          if (event.eventDate != null && event.eventDate!.isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 14, color: primaryOrange),
                                const SizedBox(width: 6),
                                Text(
                                  event.eventDate!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white54 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Description
                          Text(
                            'Deskripsi Lengkap:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            (event.description != null && event.description!.isNotEmpty)
                                ? event.description!
                                : 'Tidak ada deskripsi untuk event ini.',
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white70 : Colors.black87,
                              height: 1.5,
                            ),
                          ),

                          // Event Link
                          if (event.eventLink != null && event.eventLink!.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            GestureDetector(
                              onTap: () {
                                // Can launch URL if needed
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: primaryOrange,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Kunjungi Link Event',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Bottom Navigation Bar
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
}

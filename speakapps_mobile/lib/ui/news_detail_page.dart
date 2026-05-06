import 'package:flutter/material.dart';
import 'widgets/custom_bottom_nav.dart';

class NewsDetailPage extends StatelessWidget {
  final String title;
  final String date;
  final String imagePath;
  final String description;

  const NewsDetailPage({
    super.key,
    required this.title,
    required this.date,
    this.imagePath = '',
    this.description = '',
  });

  @override
  Widget build(BuildContext context) {
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
                      Text(
                        'Detail Berita',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
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
                        color: Colors.white,
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
                              child: imagePath.isNotEmpty
                                  ? Image.asset(
                                      imagePath,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 50));
                                      },
                                    )
                                  : const Center(
                                      child: Text(
                                        'gambar event/berita',
                                        style: TextStyle(fontSize: 14, color: Colors.black54),
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Title
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Date Row
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 14, color: primaryOrange),
                              const SizedBox(width: 6),
                              Text(
                                date,
                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Description
                          const Text(
                            'Deskripsi Lengkap:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            description.isNotEmpty 
                              ? description 
                              : 'Silahkan isi deskripsi berita atau event di sini untuk memberikan informasi lebih lanjut kepada pengguna.',
                            textAlign: TextAlign.justify,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Selengkapnya Button
                          GestureDetector(
                            onTap: () {
                              // Action for Read More
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: primaryOrange,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryOrange.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'Selengkapnya',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
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

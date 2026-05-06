import 'package:flutter/material.dart';
import 'news_detail_page.dart';
import 'widgets/custom_bottom_nav.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  // Dummy data untuk berita/event
  static const List<Map<String, String>> _newsList = [
    {
      'title': 'Lomba Live Coding',
      'date': '20 Mei 2024',
      'image': 'assets/lomba_live_coding.png',
      'desc': 'Ikuti keseruan Lomba Live Coding tingkat nasional! Tunjukkan kemampuan coding kamu dan menangkan hadiah jutaan rupiah. Lomba ini terbuka untuk umum dan akan dilaksanakan secara online. Persiapkan diri kamu untuk tantangan algoritma dan problem solving yang menarik!'
    },
    {
      'title': 'Tips Mahir Flutter dalam 30 Hari',
      'date': '15 April 2024',
      'image': '',
      'desc': 'Pelajari langkah-langkah sistematis untuk menguasai Flutter dari dasar hingga tingkat lanjut hanya dalam satu bulan.'
    },
    {
      'title': 'Seminar Teknologi AI 2024',
      'date': '10 Maret 2024',
      'image': '',
      'desc': 'Seminar eksklusif mengenai perkembangan Artificial Intelligence terbaru dan bagaimana AI mengubah cara kita bekerja di masa depan.'
    },
  ];

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
                          'Berita dan Informasi',
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

                // News List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20.0).copyWith(bottom: 100),
                    itemCount: _newsList.length,
                    itemBuilder: (context, index) {
                      final news = _newsList[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewsDetailPage(
                                  title: news['title']!,
                                  date: news['date']!,
                                  imagePath: news['image']!,
                                  description: news['desc']!,
                                ),
                              ),
                            );
                          },
                          child: _buildNewsCard(
                            news['title']!,
                            news['date']!,
                            news['image']!,
                            primaryOrange,
                          ),
                        ),
                      );
                    },
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

  Widget _buildNewsCard(String title, String date, String imagePath, Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12.0),
              topRight: Radius.circular(12.0),
            ),
            child: Container(
              height: 160,
              width: double.infinity,
              color: Colors.grey[200],
              child: imagePath.isNotEmpty
                  ? Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.image_not_supported, color: Colors.grey),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        'gambar',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
            ),
          ),

          // Text info
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}

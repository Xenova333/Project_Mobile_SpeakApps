import 'package:flutter/material.dart';
import 'widgets/custom_bottom_nav.dart';

class BackgroundPesanPage extends StatelessWidget {
  const BackgroundPesanPage({super.key});

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
                        child: Icon(Icons.arrow_back, size: 24, color: isDark ? Colors.white : Colors.black87),
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
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        
                        // Chat Preview Container
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: Container(
                            height: 380, // Fixed height for preview
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0A1128) : const Color(0xFFFAF3EB), // Very light beige background inside preview
                              border: Border.all(color: isDark ? primaryOrange : Colors.black12),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark ? primaryOrange.withOpacity(0.5) : primaryOrange.withOpacity(0.3),
                                  blurRadius: isDark ? 20 : 15,
                                  spreadRadius: isDark ? 2 : 2,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Preview Header
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        primaryOrange.withOpacity(0.6),
                                        primaryOrange.withOpacity(0.2),
                                      ],
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'nama user',
                                        style: TextStyle(fontSize: 10, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Preview Chat Area
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      children: [
                                        _buildPreviewReceivedChat(primaryOrange),
                                        const SizedBox(height: 12),
                                        _buildPreviewSentChat(primaryOrange),
                                        const SizedBox(height: 12),
                                        _buildPreviewReceivedChat(primaryOrange),
                                        const SizedBox(height: 12),
                                        _buildPreviewSentChat(primaryOrange),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                // Preview Input Box
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'kolom isi teks...',
                                        style: TextStyle(fontSize: 10, color: Colors.black54),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Action Buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 80.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Pilih Gambar Baru
                              _buildActionButton(
                                'Pilih Gambar Baru',
                                Colors.white,
                                Colors.black,
                              ),
                              const SizedBox(height: 12),
                              
                              // Terapkan Gambar
                              _buildActionButton(
                                'terapkan gambar',
                                primaryOrange.withOpacity(0.6), // Light orange
                                Colors.white,
                              ),
                              const SizedBox(height: 12),
                              
                              // Hapus Background
                              _buildActionButton(
                                'Hapus background',
                                const Color(0xFFFCDCDC), // Light pinkish red
                                const Color(0xFFFF0000), // Red text
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildPreviewReceivedChat(Color primaryColor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(color: primaryColor, width: 1.0),
        ),
        child: const Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text('isi chat', style: TextStyle(fontSize: 10)),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Text('waktu', style: TextStyle(fontSize: 8, color: Colors.black54)),
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
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor.withOpacity(0.7), primaryColor],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: const Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text('isi chat', style: TextStyle(fontSize: 10, color: Colors.black87)),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Text('waktu', style: TextStyle(fontSize: 8, color: Colors.black87)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, Color bgColor, Color textColor) {
    return GestureDetector(
      onTap: () {
        // Action placeholder
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

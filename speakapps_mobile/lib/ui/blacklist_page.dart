import 'package:flutter/material.dart';
import 'widgets/custom_bottom_nav.dart';

class BlacklistPage extends StatelessWidget {
  const BlacklistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryOrange = const Color(0xFFF6A039);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF16213E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

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
                        'Blacklist',
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
                    padding: const EdgeInsets.all(20.0).copyWith(bottom: 100),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Cari Kontak Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Cari Kontak',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.white : const Color(0xFFF5F5F5),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      child: const TextField(
                                        textAlign: TextAlign.left,
                                        style: TextStyle(fontSize: 12, color: Colors.black87),
                                        decoration: InputDecoration(
                                          hintText: 'Masukkan Nama teman',
                                          hintStyle: TextStyle(
                                            color: Colors.black38,
                                            fontSize: 11,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12.0,
                                            vertical: 10.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () {
                                      // Search action
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 8.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.white : const Color(0xFFE0E0E0),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      child: const Text(
                                        'Cari',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Daftar Blokir Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Daftar Blokir',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildBlockedUser(context, primaryOrange, isDark),
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

  Widget _buildBlockedUser(BuildContext context, Color primaryColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isDark ? Colors.white : const Color(0xFFFDF5ED),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          // Profile picture
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: const Center(
              child: Text(
                'foto\nprofile',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 7, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name
          const Expanded(
            child: Text(
              'nama user',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
          // Buka Button
          GestureDetector(
            onTap: () {
              _showUnblockConfirmation(context, primaryColor);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: isDark ? Colors.white : const Color(0xFF81C784),
                borderRadius: BorderRadius.circular(12.0),
                border: isDark ? Border.all(color: Colors.green, width: 1.0) : null,
              ),
              child: Text(
                'Buka',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.green : Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUnblockConfirmation(BuildContext context, Color primaryColor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Buka Blokir',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Apakah Anda yakin ingin membuka blokir pengguna ini?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // No Button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: const Text(
                          'Tidak',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    // Yes Button
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        // Unblock logic here
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: const Text(
                          'Ya',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
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
}

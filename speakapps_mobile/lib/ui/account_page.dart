import 'package:flutter/material.dart';
import 'blacklist_page.dart';
import 'login_page.dart';
import 'widgets/custom_bottom_nav.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

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
                        'Akun',
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
                    padding: const EdgeInsets.all(24.0).copyWith(bottom: 100),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        
                        // Blacklist Option
                        _buildAccountOption(
                          'Blacklist',
                          Colors.black87,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const BlacklistPage()),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Hapus Akun Option
                        _buildAccountOption(
                          'Hapus Akun',
                          const Color(0xFFFF4B4B), // Red color
                          onTap: () {
                            _showDeleteAccountDialog(context, primaryOrange);
                          },
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

  Widget _buildAccountOption(String title, Color textColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, Color primaryColor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white, // Always white
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: primaryColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Konfirmasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Yakin ingin hapus akun?',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Ya, Hapus button
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                          (route) => false,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935), // Red
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: const Text(
                          'Ya, Hapus',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // BATAL button
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Close dialog
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 10.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: const Text(
                          'BATAL',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
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

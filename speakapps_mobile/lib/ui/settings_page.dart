import 'package:flutter/material.dart';
import 'account_page.dart';
import 'theme_page.dart';
import 'widgets/custom_bottom_nav.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
                        'Setelan',
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        _buildSettingItem('Akun', onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AccountPage()),
                          );
                        }),
                        const SizedBox(height: 16),
                        _buildSettingItem('Tema', onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ThemePage()),
                          );
                        }),
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

  Widget _buildSettingItem(String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme_notifier.dart';
import 'background_pesan_page.dart';
import 'widgets/custom_bottom_nav.dart';

class ThemePage extends StatefulWidget {
  const ThemePage({super.key});

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  String _selectedTheme = themeNotifier.value == ThemeMode.dark ? 'Gelap' : 'Terang';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryOrange = const Color(0xFFF6A039);
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
                        child: Icon(Icons.arrow_back, size: 28, color: textColor),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Tema',
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor,
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
                        const SizedBox(height: 40),
                        
                        // Theme Selection Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: primaryOrange, width: 1.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildRadioOption('Terang', primaryOrange, textColor),
                                const SizedBox(height: 16),
                                _buildRadioOption('Gelap', primaryOrange, textColor),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Change Background Button
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BackgroundPesanPage(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 12.0),
                            decoration: BoxDecoration(
                              color: primaryOrange,
                              borderRadius: BorderRadius.circular(25.0),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark ? primaryOrange.withOpacity(0.5) : Colors.black.withOpacity(0.15),
                                  blurRadius: isDark ? 15 : 8,
                                  spreadRadius: isDark ? 2 : 0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Ubah latar Belakang',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
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

  Widget _buildRadioOption(String title, Color activeColor, Color textColor) {
    bool isSelected = _selectedTheme == title;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTheme = title;
        });
        // Update global theme
        if (title == 'Gelap') {
          themeNotifier.value = ThemeMode.dark;
        } else {
          themeNotifier.value = ThemeMode.light;
        }
      },
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? activeColor : Colors.grey,
                width: isSelected ? 6.0 : 2.0,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

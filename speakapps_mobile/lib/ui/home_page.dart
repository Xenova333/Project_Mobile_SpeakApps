import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'profile_page.dart';
import 'add_contact_page.dart';
import 'login_page.dart';
import 'news_page.dart';
import 'settings_page.dart';
import 'widgets/custom_bottom_nav.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryOrange = const Color(0xFFF6A039);
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF111C44) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    children: [
                      // Logo Placeholder
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cardColor,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Text(
                                  'S',
                                  style: TextStyle(
                                    color: primaryOrange,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // App Name
                      Text(
                        'SpeakApp',
                        style: TextStyle(
                          color: primaryOrange,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // Menu Icon
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          size: 30,
                          color: isDark ? Colors.white : primaryOrange,
                        ),
                        color: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        offset: const Offset(0, 45),
                        onSelected: (value) {
                          if (value == 'profile') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfilePage(),
                              ),
                            );
                          } else if (value == 'setelan') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsPage(),
                              ),
                            );
                          } else if (value == 'logout') {
                            _showLogoutDialog(context, primaryOrange);
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'profile',
                                child: Text(
                                  'profile',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'setelan',
                                child: Text(
                                  'setelan',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'logout',
                                child: Text(
                                  'logout',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      bottom: 100,
                    ), // add padding for bottom nav
                    child: Column(
                      children: [
                        // Search Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(20.0),
                              border: isDark
                                  ? null
                                  : Border.all(
                                      color: primaryOrange,
                                      width: 1.0,
                                    ),
                            ),
                            child: TextField(
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                hintText: 'Cari kontak....',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: subTextColor,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Horizontal Event Filters (Januari - Desember)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            children: [
                              'Januari', 'Februari', 'Maret', 'April',
                              'Mei', 'Juni', 'Juli', 'Agustus',
                              'September', 'Oktober', 'November', 'Desember',
                            ].asMap().entries.map((entry) {
                              final label = entry.value;
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: entry.key < 11 ? 12.0 : 0,
                                ),
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const NewsPage(),
                                    ),
                                  ),
                                  child: _buildEventFilter(
                                    'event\n$label',
                                    primaryOrange,
                                    cardColor,
                                    textColor,
                                    isDark,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Main Event Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NewsPage(),
                                ),
                              );
                            },
                            child: Container(
                              height: 200,
                              width: double.infinity,
                              padding: const EdgeInsets.all(20.0),
                              decoration: BoxDecoration(
                                color:
                                    Colors.white, // Always white as per design
                                borderRadius: BorderRadius.circular(20.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        'assets/lomba_live_coding.png',
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Gambar tidak ditemukan',
                                                  style: TextStyle(fontSize: 10, color: Colors.grey),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Lomba Live Coding',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '20 Mei 2024 - 09:00 WIB',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // User List
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            children: [
                              _buildUserCard(
                                context,
                                primaryOrange,
                                cardColor,
                                textColor,
                                subTextColor,
                              ),
                              const SizedBox(height: 16),
                              _buildUserCard(
                                context,
                                primaryOrange,
                                cardColor,
                                textColor,
                                subTextColor,
                              ),
                              const SizedBox(height: 16),
                              _buildUserCard(
                                context,
                                primaryOrange,
                                cardColor,
                                textColor,
                                subTextColor,
                              ),
                              const SizedBox(height: 24),
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

  Widget _buildEventFilter(
    String text,
    Color borderColor,
    Color cardColor,
    Color textColor,
    bool isDark,
  ) {
    return Container(
      width: 70,
      height: 60,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20.0),
        border: isDark ? null : Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, color: textColor, height: 1.2),
        ),
      ),
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    Color primaryColor,
    Color cardColor,
    Color textColor,
    Color subTextColor,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Center(
                child: Text(
                  'foto\nprofil',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: textColor),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'nama user',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'klik untuk chat',
                    style: TextStyle(fontSize: 12, color: subTextColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, Color primaryColor) {
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
                  'Yakin ingin keluar?',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Ya, Keluar button
                    GestureDetector(
                      onTap: () {
                        // Close dialog and go to login page
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
                          'Ya, Keluar',
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

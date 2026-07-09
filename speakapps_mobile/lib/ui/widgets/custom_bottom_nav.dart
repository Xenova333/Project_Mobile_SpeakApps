import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home_page.dart';
import '../profile_page.dart';
import '../add_contact_page.dart';
import '../../user_service.dart';

class CustomBottomNav extends StatefulWidget {
  const CustomBottomNav({super.key});

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  String _userPic = '';

  @override
  void initState() {
    super.initState();
    _loadUserPic();
  }

  Future<void> _loadUserPic() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userPic = prefs.getString('user_pic') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryOrange = Color(0xFFF6A039);
    final navBgColor = isDark ? const Color(0xFF111C44) : Colors.white;
    final buttonBgColor = isDark ? const Color(0xFF111C44) : Colors.white;
    
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: isDark ? navBgColor : null,
        gradient: isDark 
            ? null 
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  primaryOrange.withOpacity(0.7),
                ],
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Profile Button (Left)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                ).then((_) => _loadUserPic());
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: ClipOval(
                  child: (_userPic.isNotEmpty && _userPic != 'default.png')
                      ? Image.network(
                          '${UserService.profilePicBaseUrl}$_userPic',
                          width: 38,
                          height: 38,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/default.png',
                            width: 38,
                            height: 38,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          'assets/default.png',
                          width: 38,
                          height: 38,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            
            // Add Contact Button (Center)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddContactPage()),
                );
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF16213E) : primaryOrange,
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
            ),
            
            // Home Button (Right)
            GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
                );
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: buttonBgColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Icon(Icons.home, color: isDark ? Colors.white : primaryOrange, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

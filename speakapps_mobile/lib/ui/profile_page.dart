import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile_page.dart';
import '../user_service.dart';
import 'widgets/custom_bottom_nav.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = '';
  String _nim = '';
  String _semester = '';
  String _gender = '';
  String _userPic = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('user_name') ?? '';
      _nim = prefs.getString('user_nim') ?? '';
      _semester = prefs.getString('user_semester') ?? '';
      _gender = prefs.getString('user_gender') ?? '';
      _userPic = prefs.getString('user_pic') ?? '';
      _isLoading = false;
    });
  }

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
                        'Profile',
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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 100),
                          child: Column(
                            children: [
                              const SizedBox(height: 40),
                              
                              // Circle Avatar
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: (_userPic.isNotEmpty && _userPic != 'default.png')
                                      ? Image.network(
                                          '${UserService.profilePicBaseUrl}$_userPic',
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Image.asset(
                                            'assets/default.png',
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Image.asset(
                                          'assets/default.png',
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              
                              const SizedBox(height: 40),
                              
                              // Info Card
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF111827) : Colors.white,
                                    borderRadius: BorderRadius.circular(12.0),
                                    border: Border.all(color: primaryOrange),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDark ? primaryOrange.withOpacity(0.5) : Colors.black.withOpacity(0.05),
                                        blurRadius: isDark ? 20 : 10,
                                        spreadRadius: isDark ? 2 : 0,
                                        offset: isDark ? Offset.zero : const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      _buildInfoField('Nama : $_name', primaryOrange, isDark),
                                      const SizedBox(height: 16),
                                      _buildInfoField('Nim : $_nim', primaryOrange, isDark),
                                      const SizedBox(height: 16),
                                      _buildInfoField('Semester : $_semester', primaryOrange, isDark),
                                      const SizedBox(height: 16),
                                      _buildInfoField(
                                        'Jenis Kelamin : ${_gender.toLowerCase() == 'male' || _gender.toLowerCase() == 'laki-laki' ? 'Laki-laki' : 'Perempuan'}',
                                        primaryOrange,
                                        isDark,
                                      ),
                                      
                                      const SizedBox(height: 30),
                                      
                                      // Edit Profile Button
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const EditProfilePage()),
                                          ).then((_) => _loadUserData());
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                                          decoration: BoxDecoration(
                                            color: primaryOrange,
                                            borderRadius: BorderRadius.circular(20.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.1),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Text(
                                            'Edit profile',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
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

  Widget _buildInfoField(String label, Color primaryColor, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : const Color(0xFFFDF5ED), // Light beige / dark gray
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: primaryColor, width: 1.0),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }
}

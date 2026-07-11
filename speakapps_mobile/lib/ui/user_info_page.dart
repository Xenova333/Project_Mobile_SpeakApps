import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../user_service.dart';
import '../auth_service.dart';
import '../controllers/profile_friend_controller.dart';
import 'widgets/custom_bottom_nav.dart';

class UserInfoPage extends StatefulWidget {
  final int friendId;
  final String friendName;
  final String? friendProfilePic;

  const UserInfoPage({
    super.key,
    required this.friendId,
    required this.friendName,
    this.friendProfilePic,
  });

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final ProfileFriendController _controller = Get.put(ProfileFriendController());
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _friendProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller.initFriendData(widget.friendId, widget.friendName, widget.friendProfilePic ?? '');
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    try {
      final data = await _authService.getUserProfile(widget.friendId);
      if (mounted) {
        setState(() {
          _friendProfile = data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showDeleteDialog() {
    final primaryOrange = const Color(0xFFF6A039);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: primaryOrange, width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Hapus Teman', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 12),
                Text(
                  'Yakin ingin menghapus ${widget.friendName} dari daftar teman?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: primaryOrange, width: 1.0),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: const Text('BATAL', style: TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _controller.handleDelete(context, widget.friendId);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: const Text('Hapus', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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

  @override
  Widget build(BuildContext context) {
    final primaryOrange = const Color(0xFFF6A039);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    final profilePic = _friendProfile?['profile_pic'] ?? widget.friendProfilePic ?? '';
    final imageUrl = (profilePic.isNotEmpty && profilePic != 'default.png') 
        ? (profilePic.startsWith('http') ? profilePic : '${UserService.profilePicBaseUrl}$profilePic') 
        : '';

    final name = _friendProfile?['name'] ?? widget.friendName;
    final nim = _friendProfile?['nim']?.toString() ?? '-';
    final semester = _friendProfile?['semester']?.toString() ?? '-';
    final genderRaw = _friendProfile?['gender']?.toString() ?? '';
    final genderDisplay = genderRaw == 'male' || genderRaw == 'laki-laki'
        ? 'Laki-laki'
        : genderRaw == 'female' || genderRaw == 'perempuan'
            ? 'Perempuan'
            : genderRaw.isNotEmpty ? genderRaw : '-';

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
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFF6A039)))
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
                                      color: primaryOrange.withOpacity(0.3),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: imageUrl.isNotEmpty
                                      ? Image.network(
                                          imageUrl,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const CircleAvatar(
                                              backgroundColor: Colors.grey,
                                              child: Icon(Icons.person, color: Colors.white, size: 60),
                                            );
                                          },
                                        )
                                      : const CircleAvatar(
                                          backgroundColor: Colors.grey,
                                          child: Icon(Icons.person, color: Colors.white, size: 60),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 16),
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),

                              const SizedBox(height: 30),

                              // Info Card
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF111C44) : Colors.white,
                                    borderRadius: BorderRadius.circular(12.0),
                                    border: Border.all(color: primaryOrange),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryOrange.withOpacity(isDark ? 0.5 : 0.15),
                                        blurRadius: isDark ? 20 : 10,
                                        spreadRadius: isDark ? 2 : 0,
                                        offset: isDark ? Offset.zero : const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      _buildInfoField('Nama', name, primaryOrange, isDark),
                                      const SizedBox(height: 12),
                                      _buildInfoField('NIM', nim, primaryOrange, isDark),
                                      const SizedBox(height: 12),
                                      _buildInfoField('Semester', semester, primaryOrange, isDark),
                                      const SizedBox(height: 12),
                                      _buildInfoField('Jenis Kelamin', genderDisplay, primaryOrange, isDark),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              // Action Buttons
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: _showDeleteDialog,
                                        child: Container(
                                          margin: const EdgeInsets.only(right: 8),
                                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE53935),
                                            borderRadius: BorderRadius.circular(20.0),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'Hapus Kontak',
                                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _controller.handleBlock(context, widget.friendId),
                                        child: Container(
                                          margin: const EdgeInsets.only(left: 8),
                                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                                          decoration: BoxDecoration(
                                            color: primaryOrange,
                                            borderRadius: BorderRadius.circular(20.0),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'Blokir Akun',
                                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
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

  Widget _buildInfoField(String label, String value, Color primaryColor, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A1128) : const Color(0xFFFDF5ED),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: primaryColor, width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

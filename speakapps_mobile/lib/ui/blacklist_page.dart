import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../contact_service.dart';
import '../models/contact_model.dart';
import '../controllers/contact_controller.dart';
import 'package:get/get.dart';
import 'widgets/custom_bottom_nav.dart';
import '../user_service.dart';

class BlacklistPage extends StatefulWidget {
  const BlacklistPage({super.key});

  @override
  State<BlacklistPage> createState() => _BlacklistPageState();
}

class _BlacklistPageState extends State<BlacklistPage> {
  final ContactService _contactService = ContactService();
  List<ContactModel> _blockedUsers = [];
  bool _isLoading = true;
  int _userId = 0;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('user_id') ?? 0;

    setState(() => _isLoading = true);
    final blocked = await _contactService.getBlockedUsers(_userId);
    setState(() {
      _blockedUsers = blocked;
      _isLoading = false;
    });
  }

  void _showUnblockDialog(ContactModel user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68, height: 68,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_open_rounded, color: Colors.orange, size: 36),
                ),
                const SizedBox(height: 16),
                Text(
                  'Buka Blokir',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Buka blokir ${user.name ?? 'pengguna ini'}?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.orange),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                      ),
                      child: const Text(
                        'BATAL',
                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        final blockedId = (user.userId == _userId)
                            ? user.friendId
                            : user.userId;
                        final result = await _contactService.unblockFriend(_userId, blockedId);
                        if (result['status'] == 'success') {
                          Get.snackbar('Berhasil', 'Blokir berhasil dibuka',
                              backgroundColor: Colors.green, colorText: Colors.white);
                          _loadBlockedUsers();
                          if (Get.isRegistered<ContactController>()) {
                            Get.find<ContactController>().loadContacts();
                          }
                        } else {
                          Get.snackbar('Error', result['message'] ?? 'Gagal membuka blokir',
                              backgroundColor: Colors.red, colorText: Colors.white);
                        }
                      },
                      child: const Text(
                        'Ya, Buka',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFF6A039)))
                      : _blockedUsers.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.block, size: 60, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Tidak ada pengguna yang diblokir',
                                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadBlockedUsers,
                              color: primaryOrange,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(20.0).copyWith(bottom: 100),
                                itemCount: _blockedUsers.length,
                                itemBuilder: (context, index) {
                                  final user = _blockedUsers[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12.0),
                                    child: _buildBlockedUser(user, primaryOrange, isDark, cardColor, textColor),
                                  );
                                },
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

  Widget _buildBlockedUser(ContactModel user, Color primaryColor, bool isDark, Color cardColor, Color textColor) {
    final profilePic = user.profilePic;
    final friendId = user.friendId;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
      child: Row(
        children: [
          // Profile picture
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: (profilePic != null && profilePic.isNotEmpty && profilePic != 'default.png')
                  ? Image.network(
                      profilePic.startsWith('http') ? profilePic : '${UserService.profilePicBaseUrl}$profilePic',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: primaryColor,
                          child: const Icon(Icons.person, color: Colors.white, size: 20),
                        );
                      },
                    )
                  : Container(
                      color: primaryColor,
                      child: const Icon(Icons.person, color: Colors.white, size: 20),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Name & NIM
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name ?? 'Tidak diketahui',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
                ),
                if (user.nim != null && user.nim!.isNotEmpty)
                  Text(
                    'NIM: ${user.nim}',
                    style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54),
                  ),
              ],
            ),
          ),
          // Buka Blokir Button
          GestureDetector(
            onTap: () => _showUnblockDialog(user),
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
}

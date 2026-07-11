import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'profile_page.dart';
import 'login_page.dart';
import 'settings_page.dart';
import 'widgets/custom_bottom_nav.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/contact_controller.dart';
import '../controllers/chat_controller.dart';
import '../controllers/event_controller.dart';
import '../controllers/global_user_controller.dart';
import '../models/contact_model.dart';
import 'event_page.dart';
import 'event_detail_page.dart';
import '../user_service.dart';
import '../controllers/auth_controller.dart';


class HomePage extends StatefulWidget {
  /// Data user yang diterima dari LoginPage setelah login berhasil.
  final Map<String, dynamic>? userData;

  const HomePage({super.key, this.userData});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ContactController contactController = Get.put(ContactController()..loadFriends());
  final ChatController _chatController = Get.put(ChatController());
  final EventController eventController = Get.put(EventController());

  String _userName = 'Pengguna';

  @override
  void initState() {
    super.initState();
    _userName = widget.userData?['name'] ?? 'Pengguna';
    _loadUserName();
    eventController.loadEvents();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('user_name');
    if (savedName != null && savedName.isNotEmpty) {
      setState(() {
        _userName = savedName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userName = _userName;
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
                      // App Name + Greeting
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SpeakApp',
                            style: TextStyle(
                              color: primaryOrange,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Halo, $userName 👋',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 11,
                            ),
                          ),
                        ],
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
                            ).then((_) => _loadUserName());
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
                  child: RefreshIndicator(
                    onRefresh: () => contactController.loadFriends(),
                    color: primaryOrange,
                    child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    onChanged: (val) => contactController.searchFriend(val),
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
                                GetBuilder<ContactController>(
                                  builder: (c) {
                                    if (c.isSearching && c.isLoading) {
                                      return const Padding(
                                        padding: EdgeInsets.only(left: 8.0),
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  }
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Horizontal Event Filters (Januari - Desember)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            children:
                                [
                                  'Januari',
                                  'Februari',
                                  'Maret',
                                  'April',
                                  'Mei',
                                  'Juni',
                                  'Juli',
                                  'Agustus',
                                  'September',
                                  'Oktober',
                                  'November',
                                  'Desember',
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
                                          builder: (context) => EventPage(selectedMonth: entry.key + 1),
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

                        // Kelola Event (Khusus Admin)
                        Obx(() {
                          if (Get.isRegistered<AuthController>()) {
                            final authController = Get.find<AuthController>();
                            if (authController.currentUser.value.role.toString().trim().toLowerCase() == 'admin') {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: ListTile(
                                    leading: const Icon(Icons.event_note, color: Colors.amber),
                                    title: const Text('Kelola Event Aplikasi', style: TextStyle(fontWeight: FontWeight.bold)),
                                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                    onTap: () => Get.to(() => EventPage()),
                                  ),
                                ),
                              );
                            }
                          }
                          return const SizedBox.shrink();
                        }),

                        // Main Event Card
                        Obx(() {
                          final mainEvent = eventController.mainEvent.value;
                          if (mainEvent == null) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: GestureDetector(
                                onTap: () => Get.to(() => EventPage()),
                                child: Container(
                                  height: 200,
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
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
                                    children: [
                                      Icon(Icons.event, size: 50, color: Colors.grey[400]),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Belum ada main event',
                                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Ketuk untuk melihat semua event',
                                        style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: GestureDetector(
                              onTap: () {
                                Get.to(() => EventDetailPage(event: mainEvent));
                              },
                              child: Container(
                                height: 200,
                                width: double.infinity,
                                padding: const EdgeInsets.all(20.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
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
                                        child: (mainEvent.image != null && mainEvent.image!.isNotEmpty)
                                            ? Image.network(
                                                mainEvent.image!,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Center(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: const [
                                                        Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
                                                        SizedBox(height: 8),
                                                        Text('Gambar tidak ditemukan', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              )
                                            : const Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.event, color: Colors.grey, size: 50),
                                                    SizedBox(height: 8),
                                                    Text('Belum ada gambar', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                                  ],
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      mainEvent.title,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      mainEvent.eventDate ?? '-',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 24),

                        // User List from ContactController
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: GetBuilder<ContactController>(
                            builder: (controller) {
                              if (controller.isLoading && !controller.isSearching) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final displayList = controller.isSearching 
                                  ? controller.filteredFriends 
                                  : controller.acceptedFriends;

                              if (displayList.isEmpty) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: Text(
                                      'Belum ada teman, ayo tambah teman baru!',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: displayList.length,
                                itemBuilder: (context, index) {
                                  final contact = displayList[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0),
                                    child: _buildUserCard(
                                      context: context,
                                      contact: contact,
                                      primaryColor: primaryOrange,
                                      cardColor: cardColor,
                                      textColor: textColor,
                                      subTextColor: subTextColor,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
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

  Widget _buildUserCard({
    required BuildContext context,
    required ContactModel contact,
    required Color primaryColor,
    required Color cardColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    final name            = contact.name ?? 'Nama Tidak Diketahui';
    final profilePic      = contact.profilePic;
    final lastMessage     = contact.lastMessage;
    final lastMessageTime = contact.lastMessageTime;

    return GestureDetector(
      onTap: () async {
        // Tentukan friendId: pilih sisi yang bukan myId
        // Prioritaskan ID dari userData (sinkron) dibanding controller (asinkron)
        final myIdFromData = widget.userData != null ? int.tryParse(widget.userData!['id'].toString()) : null;
        final myId = myIdFromData ?? _chatController.myId;
        
        final friendId = (myId != null && contact.userId == myId)
            ? contact.friendId
            : contact.userId;

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatPage(
              friendId: friendId,
              friendName: name,
              friendProfilePic: profilePic,
            ),
          ),
        );
        // Refresh data saat kembali
        contactController.loadContacts();
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
                color: profilePic == null ? primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: (profilePic != null && profilePic.isNotEmpty && profilePic != 'default.png')
                    ? Image.network(
                        profilePic.startsWith('http') ? profilePic : '${UserService.profilePicBaseUrl}$profilePic',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, color: Colors.white, size: 24),
                        ),
                      )
                    : const CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, color: Colors.white, size: 24),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage ?? 'Belum ada pesan',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: subTextColor),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (lastMessageTime != null && lastMessageTime.isNotEmpty) ...[
                  Text(
                    _formatTime(lastMessageTime),
                    style: TextStyle(fontSize: 10, color: subTextColor),
                  ),
                  const SizedBox(height: 6),
                ],
                contact.unreadCount > 0
                    ? Container(
                        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            contact.unreadCount > 99 ? '99+' : '${contact.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String timeStr) {
    try {
      final dateTime = DateTime.parse(timeStr);
      final now = DateTime.now();
      
      final today = DateTime(now.year, now.month, now.day);
      final msgDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
      
      final difference = today.difference(msgDate).inDays;

      if (difference == 0) {
        // Hari ini: Tampilkan jam saja
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else if (difference == 1) {
        // Kemarin
        return 'Kemarin';
      } else {
        // Lewat dari kemarin: Tampilkan tanggal dan bulan
        const months = [
          '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
          'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
        ];
        return '${dateTime.day.toString().padLeft(2, '0')} ${months[dateTime.month]}';
      }
    } catch (e) {
      return '';
    }
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
                      onTap: () async {
                        // Hapus session HANYA untuk data user
                        // Jangan gunakan prefs.clear() karena akan menghapus wallpaper milik akun lain!
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('user_id');
                        await prefs.remove('user_nim');
                        await prefs.remove('user_name');
                        await prefs.remove('user_semester');
                        await prefs.remove('user_gender');
                        await prefs.remove('user_pic');
                        await prefs.remove('user_role');

                        // Hapus controller agar data bersih saat login kembali
                        Get.delete<ContactController>();
                        Get.delete<ChatController>();
                        Get.delete<EventController>();
                        // Reset foto profil di GlobalUserController agar tidak bocor ke akun lain
                        if (Get.isRegistered<GlobalUserController>()) {
                          final globalUser = Get.find<GlobalUserController>();
                          globalUser.userPic.value = '';
                          globalUser.imageTimestamp.value = DateTime.now().millisecondsSinceEpoch;
                        }

                        // Close dialog and go to login page
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                            (route) => false,
                          );
                        }
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

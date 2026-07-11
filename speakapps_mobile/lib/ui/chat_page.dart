import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../controllers/chat_background_controller.dart';
import '../models/chat_model.dart';
import '../user_service.dart';
import 'user_info_page.dart';

class ChatPage extends StatefulWidget {
  final int friendId;
  final String friendName;
  final String? friendProfilePic;

  const ChatPage({
    super.key,
    required this.friendId,
    required this.friendName,
    this.friendProfilePic,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<ChatController>();

    // ChatBackgroundController sudah terdaftar permanent dari main.dart.
    // Tidak perlu Get.put lagi di sini.

    // Muat riwayat chat saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.startChat(widget.friendId);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryOrange = const Color(0xFFF6A039);
    final primaryBlue   = const Color(0xFF111C44);
    final isDark       = Theme.of(context).brightness == Brightness.dark;
    final bgColor      = isDark ? const Color(0xFF0A1128) : const Color(0xFFF4F7F6);
    final cardColor    = isDark ? primaryBlue : Colors.white;
    final textColor    = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF8E8E93);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ────────────────────────────────────────────────
            _buildAppBar(primaryOrange, isDark, cardColor, textColor, subTextColor),

            // ── Chat Area dengan Background Wallpaper ───────────────────────
            Expanded(
              child: Stack(
                children: [
                  // ── Layer 1: Background Wallpaper (Obx = reaktif) ────────
                  Obx(() {
                    final bgCtrl = Get.find<ChatBackgroundController>();
                    if (!bgCtrl.hasBackground) {
                      return ColoredBox(color: bgColor);
                    }
                    return SizedBox.expand(
                      child: InteractiveViewer(
                        panEnabled: false,
                        scaleEnabled: false,
                        transformationController: TransformationController()
                          ..value = bgCtrl.bgMatrix.value,
                        child: _buildWallpaperImage(bgCtrl),
                      ),
                    );
                  }),

                  // ── Layer 2: Pesan Chat ───────────────────────────────────
                  Obx(() {
                    if (ctrl.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFFF6A039)),
                      );
                    }
                    if (ctrl.messages.isEmpty) {
                      return Center(
                        child: Text(
                          'Belum ada pesan.\nKirim pesan pertamamu! 👋',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: subTextColor, fontSize: 14),
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: ctrl.scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      itemCount: ctrl.messages.length,
                      itemBuilder: (_, i) {
                        final msg = ctrl.messages[i];
                        final isMe = msg.senderId == ctrl.myId;
                        final time = _formatTime(msg.createdAt);
                        final showDate = i == 0 ||
                            _isSameDay(ctrl.messages[i - 1].createdAt,
                                    msg.createdAt) ==
                                false;
                        return Column(
                          children: [
                            if (showDate) ...[
                              _buildDateDivider(
                                  _formatDate(msg.createdAt),
                                  isDark,
                                  primaryOrange),
                              const SizedBox(height: 12),
                            ],
                            isMe
                                ? _buildSentBubble(msg, time, primaryOrange)
                                : _buildReceivedBubble(msg, time, primaryOrange,
                                    cardColor, textColor, subTextColor, isDark),
                            const SizedBox(height: 8),
                          ],
                        );
                      },
                    );
                  }),
                ],
              ),
            ),

            // ── Input Field ────────────────────────────────────────────────
            _buildInputField(
                primaryOrange, bgColor, cardColor, textColor, subTextColor, isDark),
          ],
        ),
      ),
    );
  }

  // ── Helper: render wallpaper sesuai platform ───────────────────────────────
  Widget _buildWallpaperImage(ChatBackgroundController bgCtrl) {
    if (kIsWeb && bgCtrl.bgImageBytes.value != null) {
      return Image.memory(
        bgCtrl.bgImageBytes.value!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (!kIsWeb &&
        bgCtrl.bgImagePath.value != null &&
        bgCtrl.bgImagePath.value!.isNotEmpty) {
      return Image.file(
        File(bgCtrl.bgImagePath.value!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    return const SizedBox.shrink();
  }

  // ─── App Bar ─────────────────────────────────────────────────
  Widget _buildAppBar(Color primaryOrange, bool isDark, Color cardColor,
      Color textColor, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111C44) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new, size: 22, color: textColor),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserInfoPage(
                  friendId: widget.friendId,
                  friendName: widget.friendName,
                  friendProfilePic: widget.friendProfilePic,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryOrange, width: 1.5),
                    boxShadow: [
                      if (isDark)
                        BoxShadow(
                          color: primaryOrange.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                    ],
                  ),
                  child: ClipOval(
                      child: (widget.friendProfilePic != null &&
                              widget.friendProfilePic!.isNotEmpty && widget.friendProfilePic != 'default.png')
                          ? Image.network(
                              widget.friendProfilePic!.startsWith('http') ? widget.friendProfilePic! : '${UserService.profilePicBaseUrl}${widget.friendProfilePic}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const CircleAvatar(
                                backgroundColor: Colors.grey,
                                child: Icon(Icons.person, color: Colors.white, size: 20),
                              ),
                            )
                          : const CircleAvatar(
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person, color: Colors.white, size: 20),
                            ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.friendName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert, color: textColor),
          ),
        ],
      ),
    );
  }

  // ─── Sent Bubble (Kanan – Orange Modern) ───────────────────────
  Widget _buildSentBubble(ChatModel msg, String time, Color primaryOrange) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryOrange, const Color(0xFFE88A1A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: primaryOrange.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            Text(
              msg.message,
              style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.3),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 2.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all, color: Colors.white70, size: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Received Bubble (Kiri – Soft Solid) ───────────────────
  Widget _buildReceivedBubble(ChatModel msg, String time, Color primaryOrange,
      Color cardColor, Color textColor, Color subTextColor, bool isDark) {
    
    final bubbleColor = isDark ? const Color(0xFF1A2652) : Colors.white;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            Text(
              msg.message,
              style: TextStyle(color: textColor, fontSize: 15, height: 1.3),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 2.0),
              child: Text(
                time,
                style: TextStyle(color: subTextColor, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Input Field ─────────────────────────────────────────────
  Widget _buildInputField(Color primaryOrange, Color bgColor, Color cardColor,
      Color textColor, Color subTextColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Attachment Button
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: subTextColor, size: 28),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0A1128) : const Color(0xFFF0F2F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: ctrl.chatController,
                style: TextStyle(color: textColor, fontSize: 15),
                maxLines: null,
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: 'Ketik pesan...',
                  hintStyle: TextStyle(color: subTextColor, fontSize: 15),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _doSend(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Obx(
            () => GestureDetector(
              onTap: ctrl.isSending.value ? null : _doSend,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: ctrl.isSending.value ? Colors.grey : primaryOrange,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryOrange.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ctrl.isSending.value
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded,
                        color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _doSend() {
    ctrl.sendChat(widget.friendId);
  }

  // ─── Date Divider ─────────────────────────────────────────────
  Widget _buildDateDivider(String label, bool isDark, Color primaryColor) {
    return Row(
      children: [
        Expanded(child: Divider(color: primaryColor.withOpacity(0.25))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: TextStyle(
                fontSize: 11, color: primaryColor, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Divider(color: primaryColor.withOpacity(0.25))),
      ],
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────
  String _formatTime(String createdAt) {
    try {
      final dt = DateTime.parse(createdAt);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return createdAt;
    }
  }

  String _formatDate(String createdAt) {
    try {
      final dt  = DateTime.parse(createdAt);
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return 'Hari Ini';
      }
      final yesterday = now.subtract(const Duration(days: 1));
      if (dt.year == yesterday.year &&
          dt.month == yesterday.month &&
          dt.day == yesterday.day) {
        return 'Kemarin';
      }
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return createdAt;
    }
  }

  bool _isSameDay(String a, String b) {
    try {
      final da = DateTime.parse(a);
      final db = DateTime.parse(b);
      return da.year == db.year && da.month == db.month && da.day == db.day;
    } catch (_) {
      return false;
    }
  }
}

import 'package:flutter/material.dart';
import 'user_info_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryOrange = const Color(0xFFF6A039);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF111C44) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- PREMIUM APP BAR ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UserInfoPage()),
                      );
                    },
                    child: Row(
                      children: [
                        // Avatar with Glow
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
                          child: const CircleAvatar(
                            backgroundColor: Color(0xFFE0E0E0),
                            child: Icon(Icons.person, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nama User',
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
            ),

            // --- CHAT AREA ---
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                children: [
                  // Date Divider
                  _buildDateDivider('Hari Ini', isDark, primaryOrange),
                  const SizedBox(height: 24),

                  _buildReceivedChat('Halo! Apa kabar hari ini?', '09:41', primaryOrange, cardColor, textColor, subTextColor),
                  _buildReceivedChat('Apakah event besok jadi dilaksanakan?', '09:42', primaryOrange, cardColor, textColor, subTextColor),
                  
                  _buildSentChat('Halo! Kabar baik. Iya, event tetap sesuai jadwal kok.', '09:45', primaryOrange),
                  _buildSentChat('Jangan lupa bawa perlengkapannya ya!', '09:45', primaryOrange),

                  _buildReceivedChatWithReply(
                    'Siap, terima kasih infonya!', 
                    'Jangan lupa bawa perlengkapannya ya!', 
                    '09:48', 
                    primaryOrange, cardColor, textColor, subTextColor, isDark
                  ),
                  
                  _buildSentChatWithReply(
                    'Oke, sampai jumpa di sana!', 
                    'Siap, terima kasih infonya!', 
                    '09:50', 
                    primaryOrange
                  ),
                ],
              ),
            ),

            // --- INPUT FIELD ---
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              decoration: BoxDecoration(
                color: bgColor,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(30.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Ketik pesan...',
                          hintStyle: TextStyle(color: subTextColor, fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      if (_messageController.text.isNotEmpty) {
                        _messageController.clear();
                      }
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: primaryOrange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryOrange.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateDivider(String label, bool isDark, Color primaryColor) {
    return Row(
      children: [
        Expanded(child: Divider(color: primaryColor.withOpacity(0.2))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(child: Divider(color: primaryColor.withOpacity(0.2))),
      ],
    );
  }

  Widget _buildReceivedChat(String message, String time, Color primaryColor, Color cardColor, Color textColor, Color subTextColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 280),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(4),
            ),
            border: Border.all(color: primaryColor.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: TextStyle(color: textColor, fontSize: 14)),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(time, style: TextStyle(color: subTextColor, fontSize: 10)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSentChat(String message, String time, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 280),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withOpacity(0.8)],
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
                color: primaryColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: const TextStyle(color: Colors.white, fontSize: 14)),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(time, style: const TextStyle(color: Colors.white70, fontSize: 10)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceivedChatWithReply(String message, String replyTo, String time, Color primaryColor, Color cardColor, Color textColor, Color subTextColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 280),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryColor.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reply Box
              Container(
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? primaryColor.withOpacity(0.1) : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border(left: BorderSide(color: primaryColor, width: 4)),
                ),
                child: Text(
                  replyTo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: subTextColor, fontStyle: FontStyle.italic),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(message, style: TextStyle(color: textColor, fontSize: 14)),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(time, style: TextStyle(color: subTextColor, fontSize: 10)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSentChatWithReply(String message, String replyTo, String time, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 280),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reply Box
              Container(
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: const Border(left: BorderSide(color: Colors.white, width: 4)),
                ),
                child: Text(
                  replyTo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.white70, fontStyle: FontStyle.italic),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(message, style: const TextStyle(color: Colors.white, fontSize: 14)),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(time, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

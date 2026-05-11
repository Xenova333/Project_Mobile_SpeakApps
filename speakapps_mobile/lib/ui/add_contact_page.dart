import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/add_contact_controller.dart';

class AddContactPage extends StatelessWidget {
  final AddContactController controller = Get.put(AddContactController());

  AddContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryOrange = const Color(0xFFF6A039);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF111C44) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // App Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0A1128) : null,
                gradient: isDark ? null : LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[
                    primaryOrange.withOpacity(0.4),
                    primaryOrange.withOpacity(0.1),
                    Colors.white,
                  ],
                ),
              ),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Kelola Kontak',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Pending Requests dengan RefreshIndicator yang benar
            Expanded(
              child: GetBuilder<AddContactController>(
                builder: (c) {
                  if (c.isPageLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Menggunakan ListView utama agar RefreshIndicator selalu bisa ditarik
                  return RefreshIndicator(
                    onRefresh: () => c.loadIncomingRequests(),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        if (c.pendingRequests.isEmpty) ...[
                          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                          Center(
                            child: Text(
                              'Tidak ada permintaan pertemanan',
                              style: TextStyle(color: textColor.withOpacity(0.6)),
                            ),
                          ),
                        ] else ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                            child: Text(
                              'Permintaan Masuk',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: primaryOrange,
                              ),
                            ),
                          ),
                          // Daftar permintaan
                          ...c.pendingRequests.map((request) {
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                              color: cardColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: primaryOrange.withOpacity(0.2),
                                  backgroundImage: request.profilePic != null ? NetworkImage(request.profilePic!) : null,
                                  child: request.profilePic == null ? Icon(Icons.person, color: primaryOrange) : null,
                                ),
                                title: Text(
                                  request.name ?? 'Unknown',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                                ),
                                subtitle: Text(
                                  request.nim ?? '-',
                                  style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.7)),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: () => c.handleAccept(context, request.id),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            // Add Friend Form
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              decoration: BoxDecoration(
                color: isDark ? cardColor : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Tambah Teman Baru',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'NIM Teman :',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.nimController,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Masukkan NIM teman',
                      filled: true,
                      fillColor: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFFAF3EB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GetBuilder<AddContactController>(
                    builder: (c) {
                      if (c.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ElevatedButton(
                        onPressed: () => c.submitAdd(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryOrange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                        ),
                        child: const Text(
                          'Kirim Permintaan',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

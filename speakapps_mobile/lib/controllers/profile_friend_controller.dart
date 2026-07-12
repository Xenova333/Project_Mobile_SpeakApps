import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../contact_service.dart';
import 'contact_controller.dart';
import '../ui/home_page.dart'; // Sesuaikan jika path HomePage berbeda

class ProfileFriendController extends GetxController {
  final ContactService _contactService = ContactService();
  bool isLoading = false;

  // Bisa digunakan untuk menyimpan data profil teman jika ingin diakses oleh UI
  Map<String, dynamic> friendData = {};

  /// Load data awal jika diperlukan dari ID (Opsional: dipanggil saat halaman dibuka)
  void initFriendData(int friendId, String name, String profilePic) {
    friendData = {
      'id': friendId,
      'name': name,
      'profile_pic': profilePic,
    };
    update();
  }

  /// Menghapus pertemanan
  Future<void> handleDelete(BuildContext context, int friendId) async {
    isLoading = true;
    update();

    try {
      final prefs = await SharedPreferences.getInstance();
      final myId = prefs.getInt('user_id');

      if (myId == null) {
        throw Exception("User ID tidak ditemukan");
      }

      final result = await _contactService.deleteFriendship(myId, friendId);

      if (result['status'] == 'success') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berhasil menghapus teman')),
          );
        }
        
        // Refresh daftar kontak di halaman Home agar nama terhapus secara real-time
        if (Get.isRegistered<ContactController>()) {
          Get.find<ContactController>().loadContacts();
        }

        // Kembali ke halaman Home. Menggunakan pushAndRemoveUntil agar memastikan tumpukan ChatPage juga tertutup
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false,
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal: ${result['message']}')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    } finally {
      isLoading = false;
      update();
    }
  }

  /// Meminta Konfirmasi lalu memblokir teman
  void handleBlock(BuildContext context, int friendId) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Konfirmasi Blokir',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin memblokir kontak ini? Anda tidak akan bisa bertukar pesan lagi.',
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black54,
            fontSize: 15,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Tombol Batal (Outlined Oranye)
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orange),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    "BATAL",
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                ),
                // Tombol Blokir (Solid Merah)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    Navigator.pop(dialogContext); // Tutup dialog konfirmasi
                    await _executeBlock(context, friendId);
                  },
                  child: const Text(
                    "Blokir",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

  /// Eksekusi logika pemblokiran (Private)
  Future<void> _executeBlock(BuildContext context, int friendId) async {
    isLoading = true;
    update();

    try {
      final prefs = await SharedPreferences.getInstance();
      final myId = prefs.getInt('user_id');

      if (myId == null) {
        throw Exception("User ID tidak ditemukan");
      }

      final result = await _contactService.blockFriend(myId, friendId);

      if (result['status'] == 'success') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berhasil memblokir teman')),
          );
        }

        // Refresh daftar kontak di halaman Home agar nama hilang secara real-time
        if (Get.isRegistered<ContactController>()) {
          Get.find<ContactController>().loadContacts();
        }

        // Kembali ke halaman Home dan buang sisa tumpukan page
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false,
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal: ${result['message']}')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    } finally {
      isLoading = false;
      update();
    }
  }
}

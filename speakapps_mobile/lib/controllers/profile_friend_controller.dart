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
          Get.find<ContactController>().loadFriends();
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
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Blokir'),
          content: const Text('Apakah Anda yakin ingin memblokir kontak ini? Anda tidak akan bisa bertukar pesan lagi.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), // Tutup dialog
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // Tutup dialog konfirmasi
                await _executeBlock(context, friendId);
              },
              child: const Text(
                'Blokir',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
          Get.find<ContactController>().loadFriends();
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

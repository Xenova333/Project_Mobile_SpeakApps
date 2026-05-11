import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../contact_service.dart';
import '../models/contact_model.dart';
import 'contact_controller.dart';

class AddContactController extends GetxController {
  final TextEditingController nimController = TextEditingController();
  
  List<ContactModel> pendingRequests = [];
  bool isLoading = false;
  bool isPageLoading = false; 

  final ContactService _contactService = ContactService();

  @override
  void onInit() {
    super.onInit();
    loadIncomingRequests(); // Memuat request saat controller diinisialisasi
  }

  /// Fungsi untuk memuat daftar permintaan pertemanan masuk
  Future<void> loadIncomingRequests() async {
    isPageLoading = true;
    update();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId != null) {
        pendingRequests = await _contactService.getPendingRequests(userId);
      } else {
        print("UserId tidak ditemukan di SharedPreferences");
      }
    } catch (e) {
      print("Error memuat pending requests: $e");
    } finally {
      isPageLoading = false;
      update();
    }
  }

  /// Fungsi untuk menambahkan teman baru menggunakan NIM
  Future<void> submitAdd(BuildContext context) async {
    final inputNim = nimController.text.trim();
    if (inputNim.isEmpty) {
      _showSnackBar(context, 'NIM tidak boleh kosong', isError: true);
      return;
    }

    isLoading = true;
    update();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        _showSnackBar(context, 'Sesi login tidak valid', isError: true);
        return;
      }

      // Memanggil fungsi service yang sudah diperbarui namanya
      final result = await _contactService.sendFriendRequest(userId, inputNim);

      if (result['status'] == 'success') {
        _showSnackBar(context, 'Permintaan pertemanan berhasil dikirim', isError: false);
        nimController.clear();
      } else {
        _showSnackBar(context, result['message'] ?? 'Gagal menambahkan teman', isError: true);
      }
    } catch (e) {
      _showSnackBar(context, 'Terjadi kesalahan sistem', isError: true);
    } finally {
      isLoading = false;
      update();
    }
  }

  /// Fungsi untuk menerima request pertemanan
  Future<void> handleAccept(BuildContext context, int requestId) async {
    isLoading = true;
    update();

    try {
      final result = await _contactService.acceptRequest(requestId);

      if (result['status'] == 'success') {
        _showSnackBar(context, 'Permintaan pertemanan diterima', isError: false);
        
        // Refresh daftar request masuk
        await loadIncomingRequests();
        
        // Refresh daftar kontak di halaman utama jika ada
        if (Get.isRegistered<ContactController>()) {
          Get.find<ContactController>().loadContacts();
        }
      } else {
        _showSnackBar(context, result['message'] ?? 'Gagal menerima pertemanan', isError: true);
      }
    } catch (e) {
      _showSnackBar(context, 'Terjadi kesalahan sistem', isError: true);
    } finally {
      isLoading = false;
      update();
    }
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void onClose() {
    nimController.dispose();
    super.onClose();
  }
}

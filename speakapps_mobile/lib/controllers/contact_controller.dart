import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../contact_service.dart';
import '../models/contact_model.dart';

class ContactController extends GetxController {
  List<ContactModel> contacts = [];
  List<ContactModel> acceptedFriends = [];
  List<ContactModel> filteredFriends = [];
  bool isLoading = true;
  bool isSearching = false;
  Timer? _debounce;

  final ContactService _contactService = ContactService();
  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    // loadContacts();
    startRefreshTimer();
  }

  void startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      loadContacts();
    });
  }

  @override
  void onClose() {
    _debounce?.cancel();
    _refreshTimer?.cancel();
    super.onClose();
  }

  Future<void> loadContacts() async {
    isLoading = true;
    update(); 

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id'); 

      if (userId != null) {
        // Clear list agar data tidak tertukar jika user logout & login akun lain
        contacts.clear();
        filteredFriends.clear();

        // Ambil data kontak yang sudah ada chat-nya (untuk chat list)
        contacts = await _contactService.fetchContacts(userId);
        
        // Ambil data semua teman (tanpa chat) jika diperlukan
        final allFriends = await _contactService.fetchFriends(userId);
        
        if (!isSearching) {
          // Defaultnya tampilkan daftar chat terakhir
          filteredFriends = List.from(contacts);
        }
      } else {
        print("User ID tidak ditemukan di SharedPreferences.");
      }
    } catch (e) {
      print("Error memuat kontak: $e");
    } finally {
      isLoading = false;
      update(); 
    }
  }

  Future<void> loadFriends() async {
    isLoading = true;
    update();

    try {
      final prefs = await SharedPreferences.getInstance();
      final myId = prefs.getInt('user_id');

      if (myId != null) {
        // Kosongkan list agar data tidak tertukar (untuk skenario logout & ganti akun)
        acceptedFriends.clear();

        // Panggil API
        final result = await _contactService.fetchFriends(myId);
        
        // Simpan ke list
        acceptedFriends = result;
      } else {
        print("User ID tidak ditemukan saat loadFriends.");
      }
    } catch (e) {
      print("Error loadFriends: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> searchFriend(String text) async {
    final keyword = text.trim();
    
    // Batalkan timer lama jika pengguna masih mengetik
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    // Pastikan jika kosong, kembali ke daftar semua teman (Default State)
    if (keyword.isEmpty) {
      isSearching = false;
      filteredFriends = List.from(acceptedFriends);
      update();
      return;
    }

    isSearching = true;
    isLoading = true;
    update();

    // Tunggu 500ms setelah user berhenti mengetik sebelum memanggil API (Debounce)
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getInt('user_id');

        if (userId != null) {
          filteredFriends = await _contactService.searchAcceptedFriends(userId, keyword);
        }
      } catch (e) {
        print("Error mencari kontak: $e");
        filteredFriends = [];
      } finally {
        isLoading = false;
        update();
      }
    });
  }
}

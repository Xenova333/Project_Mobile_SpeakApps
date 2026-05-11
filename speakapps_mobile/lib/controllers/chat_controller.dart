import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../chat_service.dart';
import '../models/chat_model.dart';

class ChatController extends GetxController {
  // ─── State ──────────────────────────────────────────────────
  RxList<ChatModel> messages = <ChatModel>[].obs;
  RxBool isLoading  = false.obs;
  RxBool isSending  = false.obs;

  // ─── Timer untuk Auto-update ────────────────────────────────
  Timer? _timer;

  // ─── TextField controller ────────────────────────────────────
  final TextEditingController chatController = TextEditingController();

  // ─── Scroll controller ───────────────────────────────────────
  final ScrollController scrollController = ScrollController();

  // ─── Service ────────────────────────────────────────────────
  final ChatService _chatService = ChatService();

  // ─── My user ID (dibaca dari SharedPreferences) ───────────────
  int? myId;

  @override
  void onInit() {
    super.onInit();
    _loadMyId();
  }

  @override
  void onClose() {
    _timer?.cancel();
    chatController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // ─── Ambil user ID dari session ──────────────────────────────
  Future<void> _loadMyId() async {
    final prefs = await SharedPreferences.getInstance();
    myId = prefs.getInt('user_id');
  }

  // ─────────────────────────────────────────────────────────────
  //  loadChat(friendId)
  //  Memuat riwayat chat antara myId dan friendId
  // ─────────────────────────────────────────────────────────────
  Future<void> loadChat(int friendId) async {
    if (myId == null) await _loadMyId();
    if (myId == null) {
      print('ChatController: myId null, tidak bisa memuat chat.');
      return;
    }

    isLoading.value = true;

    try {
      final fetched = await _chatService.fetchMessages(myId!, friendId);
      print('=== DEBUG CHAT (INIT) ===');
      print('Friend ID: $friendId');
      print('My ID: $myId');
      print('Total Pesan Ditarik: ${fetched.length}');
      print('Raw Data Pesan: $fetched'); // print list of objects
      
      messages.assignAll(fetched);
      
      print('Isi messages di RxList: ${messages.length}');
      print('=========================');
    } catch (e) {
      print('ChatController.loadChat error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  startChat(friendId)
  //  Memulai chat dan menjalankan timer untuk update otomatis
  // ─────────────────────────────────────────────────────────────
  Future<void> startChat(int friendId) async {
    // 1. Muat chat awal
    await loadChat(friendId);

    // 2. Batalkan timer lama jika ada
    _timer?.cancel();

    // 3. Mulai timer periodic setiap 2 detik
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      fetchNewMessages(friendId);
    });
  }

  // ─────────────────────────────────────────────────────────────
  //  fetchNewMessages(friendId)
  //  Menarik data dari server dan mengecek apakah ada pesan baru
  // ─────────────────────────────────────────────────────────────
  Future<void> fetchNewMessages(int friendId) async {
    if (myId == null) return;
    try {
      int? lastMessageId;
      if (messages.isNotEmpty) {
        // Ambil ID dari pesan terakhir di lokal untuk optimasi query
        lastMessageId = messages.last.id;
      }

      final fetchedMessages = await _chatService.fetchMessages(myId!, friendId, lastId: lastMessageId);
      
      // Karena server hanya mengirim pesan baru berkat lastId,
      // kita cukup mengecek apakah fetchedMessages tidak kosong
      if (fetchedMessages.isNotEmpty) {
        print('=== DEBUG CHAT (TIMER) ===');
        print('Ditemukan ${fetchedMessages.length} pesan baru dari server.');
        print('Raw Data: $fetchedMessages');
        print('==========================');
        
        bool hasNewMessage = false;
        
        for (var newMsg in fetchedMessages) {
          if (!messages.any((msg) => msg.id == newMsg.id)) {
            messages.add(newMsg);
            hasNewMessage = true;
          }
        }
        
        if (hasNewMessage) {
          // Tidak perlu update() karena sudah Obx
          Future.delayed(const Duration(milliseconds: 100), () => scrollToBottom());
        }
      }
    } catch (e) {
      print('ChatController.fetchNewMessages error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  scrollToBottom()
  //  Scroll layar ke pesan paling bawah
  // ─────────────────────────────────────────────────────────────
  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  sendChat(friendId)
  //  Kirim pesan, tambahkan secara lokal jika sukses, kosongkan field
  // ─────────────────────────────────────────────────────────────
  Future<void> sendChat(int friendId) async {
    final text = chatController.text.trim();
    if (text.isEmpty) return;

    if (myId == null) await _loadMyId();
    if (myId == null) {
      print('ChatController: myId null, tidak bisa mengirim pesan.');
      return;
    }

    isSending.value = true;

    try {
      final result = await _chatService.postMessage({
        'sender_id'  : myId,
        'receiver_id': friendId,
        'message'    : text,
      });

      if (result['status'] == 'success') {
        // ✅ Tambahkan pesan ke list secara lokal (instan, tanpa harus reload)
        final now = DateTime.now();
        final newMsg = ChatModel(
          id        : result['data']?['id'] ?? now.millisecondsSinceEpoch,
          senderId  : myId!,
          receiverId: friendId,
          message   : text,
          isRead    : false,
          createdAt : '${now.year}-${_pad(now.month)}-${_pad(now.day)} '
                      '${_pad(now.hour)}:${_pad(now.minute)}:${_pad(now.second)}',
        );

        messages.add(newMsg);

        // Kosongkan TextField
        chatController.clear();
        
        // Scroll otomatis
        scrollToBottom();
      } else {
        print('Gagal kirim pesan: ${result['message']}');
        Get.snackbar(
          'Gagal',
          result['message'] ?? 'Pesan tidak terkirim.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE53935),
          colorText: const Color(0xFFFFFFFF),
        );
      }
    } catch (e) {
      print('ChatController.sendChat error: $e');
    } finally {
      isSending.value = false;
    }
  }

  // ─── Helper: padding angka jadi 2 digit ─────────────────────
  String _pad(int n) => n.toString().padLeft(2, '0');

  // ─────────────────────────────────────────────────────────────
  //  [Legacy] loadUserChats() — dipertahankan untuk kompatibilitas
  // ─────────────────────────────────────────────────────────────
  Future<void> loadUserChats() async {
    if (myId == null) await _loadMyId();
    isLoading.value = true;
    try {
      if (myId != null) {
        final chats = await _chatService.fetchChats(myId!);
        messages.assignAll(chats);
      }
    } catch (e) {
      print('loadUserChats error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

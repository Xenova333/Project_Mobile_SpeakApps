import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/chat_model.dart';
import 'package:speakapps_mobile/api_services.dart';

class ChatService {
  // ─────────────────────────────────────────────────────────────
  //  GET /api/chat/{myId}/{friendId}
  //  Mengambil riwayat chat antara dua user
  // ─────────────────────────────────────────────────────────────
  Future<List<ChatModel>> fetchMessages(int myId, int friendId, {int? lastId}) async {
    try {
      String url = '${ApiConfig.baseUrl}/chat/$myId/$friendId';
      if (lastId != null) {
        url += '?last_id=$lastId';
      }
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded['status'] == 'success') {
          final List<dynamic> dataList = decoded['data'] ?? [];
          return dataList.map((item) => ChatModel.fromJson(item)).toList();
        } else {
          throw Exception(decoded['message'] ?? 'Gagal mengambil pesan');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetchMessages: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  POST /api/chat/send
  //  Mengirim pesan baru ke backend
  // ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> postMessage(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/chat/send'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      );

      final decoded = json.decode(response.body);

      if (response.statusCode == 201) {
        return {'status': 'success', 'data': decoded['data']};
      } else {
        return {
          'status': 'error',
          'message': decoded['message'] ?? 'Gagal mengirim pesan.',
        };
      }
    } catch (e) {
      print('Error postMessage: $e');
      return {
        'status': 'error',
        'message': 'Koneksi terputus: $e',
      };
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  [Legacy] GET /api/chat/{userId}
  //  Dipertahankan untuk kompatibilitas jika masih dipakai
  // ─────────────────────────────────────────────────────────────
  Future<List<ChatModel>> fetchChats(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/chat/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData['status'] == 'success') {
          final List<dynamic> dataList = decodedData['data'] ?? [];
          return dataList.map((item) => ChatModel.fromJson(item)).toList();
        } else {
          throw Exception(decodedData['message'] ?? 'Gagal mengambil data pesan');
        }
      } else {
        throw Exception('Failed to load chats. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetchChats: $e');
      return [];
    }
  }
}

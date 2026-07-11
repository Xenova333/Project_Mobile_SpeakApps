import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/contact_model.dart';
import 'package:speakapps_mobile/api_services.dart';

class ContactService {
  /// Fungsi untuk mengambil daftar kontak/teman berdasarkan userId (dengan chat terakhir)
  Future<List<ContactModel>> fetchContacts(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/kontak/$userId"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData['status'] == 'success') {
          final List<dynamic> dataList = decodedData['data'] ?? [];
          return dataList.map((json) => ContactModel.fromJson(json)).toList();
        } else {
          throw Exception(decodedData['message'] ?? 'Gagal mengambil data kontak');
        }
      } else {
        throw Exception('Server error. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching contacts: $e");
      return [];
    }
  }

  /// Fungsi untuk mengambil DAFTAR TEMAN SAJA (tanpa chat history)
  Future<List<ContactModel>> fetchFriends(int myId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.acceptedFriendsUrl(myId)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData['status'] == 'success') {
          final List<dynamic> dataList = decodedData['data'] ?? [];
          return dataList.map((json) => ContactModel.fromJson(json)).toList();
        } else {
          throw Exception(decodedData['message'] ?? 'Gagal mengambil daftar teman');
        }
      } else {
        throw Exception('Server error. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching friends list: $e");
      return [];
    }
  }

  /// Fungsi untuk mengambil permintaan pertemanan yang masuk (pending)
  Future<List<ContactModel>> getPendingRequests(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/friends/pending/$userId"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData['status'] == 'success') {
          final List<dynamic> dataList = decodedData['data'] ?? [];
          return dataList.map((json) => ContactModel.fromJson(json)).toList();
        } else {
          throw Exception(decodedData['message'] ?? 'Gagal mengambil data permintaan');
        }
      } else {
        throw Exception('Server error. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching pending requests: $e");
      return [];
    }
  }

  /// Fungsi untuk mengambil permintaan pertemanan yang sudah DIKIRIM user (status pending)
  Future<List<ContactModel>> getSentRequests(int userId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.sentRequestsUrl(userId)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData['status'] == 'success') {
          final List<dynamic> dataList = decodedData['data'] ?? [];
          return dataList.map((json) => ContactModel.fromJson(json)).toList();
        } else {
          throw Exception(decodedData['message'] ?? 'Gagal mengambil permintaan terkirim');
        }
      } else {
        throw Exception('Server error. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching sent requests: $e");
      return [];
    }
  }

  /// Fungsi untuk menambahkan teman baru (berdasarkan NIM)
  Future<Map<String, dynamic>> sendFriendRequest(int userId, String nim) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/friends/add"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'user_id': userId,
          'nim': nim,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      print("Error sending friend request: $e");
      return {
        'status': 'error',
        'message': 'Gagal terhubung ke server: $e',
      };
    }
  }

  /// Fungsi untuk menerima pertemanan (mengubah status)
  Future<Map<String, dynamic>> acceptRequest(int requestId) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/friends/status"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'request_id': requestId,
          'new_status': 'accepted',
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      print("Error accepting friend request: $e");
      return {
        'status': 'error',
        'message': 'Gagal terhubung ke server: $e',
      };
    }
  }

  /// Fungsi untuk mencari daftar teman yang sudah berteman
  Future<List<ContactModel>> searchAcceptedFriends(int myId, String query) async {
    try {
      // Pastikan string query di-encode URL agar spasi dan karakter khusus aman
      final encodedQuery = Uri.encodeComponent(query);
      
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/my-friends/search/$myId/$encodedQuery"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData['status'] == 'success') {
          final List<dynamic> dataList = decodedData['data'] ?? [];
          return dataList.map((json) => ContactModel.fromJson(json)).toList();
        } else {
          throw Exception(decodedData['message'] ?? 'Gagal melakukan pencarian kontak');
        }
      } else {
        throw Exception('Server error. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error searching contacts: $e");
      return [];
    }
  }

  /// Fungsi untuk menghapus pertemanan
  Future<Map<String, dynamic>> deleteFriendship(int myId, int friendId) async {
    try {
      final response = await http.delete(
        Uri.parse("${ApiConfig.baseUrl}/friends/delete/$myId/$friendId"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      return json.decode(response.body);
    } catch (e) {
      print("Error deleting friend: $e");
      return {
        'status': 'error',
        'message': 'Gagal terhubung ke server: $e',
      };
    }
  }

  /// Fungsi untuk memblokir teman
  Future<Map<String, dynamic>> blockFriend(int myId, int friendId) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/friends/block"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'user_id': myId,
          'friend_id': friendId,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      print("Error blocking friend: $e");
      return {
        'status': 'error',
        'message': 'Gagal terhubung ke server: $e',
      };
    }
  }

  /// Fungsi untuk mengambil daftar user yang diblokir
  Future<List<ContactModel>> getBlockedUsers(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/friends/blocked/$userId"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData['status'] == 'success') {
          final List<dynamic> dataList = decodedData['data'] ?? [];
          return dataList.map((json) => ContactModel.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print("Error fetching blocked users: $e");
      return [];
    }
  }

  /// Fungsi untuk membuka blokir teman
  Future<Map<String, dynamic>> unblockFriend(int myId, int friendId) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/friends/unblock"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'user_id': myId,
          'friend_id': friendId,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      print("Error unblocking friend: $e");
      return {
        'status': 'error',
        'message': 'Gagal terhubung ke server: $e',
      };
    }
  }

  /// Fungsi untuk menghapus akun user
  Future<Map<String, dynamic>> deleteUser(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse("${ApiConfig.baseUrl}/user/$userId"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      return json.decode(response.body);
    } catch (e) {
      print("Error deleting user: $e");
      return {
        'status': 'error',
        'message': 'Gagal terhubung ke server: $e',
      };
    }
  }
}

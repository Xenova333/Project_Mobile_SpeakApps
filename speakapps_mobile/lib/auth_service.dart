import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speakapps_mobile/api_services.dart';

class AuthService {
  /// 1. FUNGSI LOGIN
  Future<Map<String, dynamic>> login(String nim, String password) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/login"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'nim': nim,
          'password': password,
        }),
      );

      // Mengambil data response dari CI4
      return json.decode(response.body);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Gagal terhubung ke server. Pastikan ADB Reverse aktif dan CI4 berjalan.',
      };
    }
  }

  /// 2. FUNGSI REGISTER
  Future<Map<String, dynamic>> register({
    required String nim,
    required String name,
    required String password,
    required String semester,
    required String gender,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/register"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'nim': nim,
          'name': name,
          'password': password,
          'semester': semester,
          'gender': gender,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Koneksi terputus: $e',
      };
    }
  }

  /// 3. FUNGSI AMBIL PROFIL USER
  Future<Map<String, dynamic>> getUserProfile(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/user/$userId"),
        headers: {'Content-Type': 'application/json'},
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Gagal mengambil data profil.',
      };
    }
  }

  /// 4. FUNGSI AMBIL BERITA (NEWS)
  Future<List<dynamic>> getNews() async {
    try {
      // Perhatikan URL diganti jika memang berada di bawah '/api',
      // Jika ternyata '/news' tidak ada dalam '/api', ubah kembali ini sesuai dengan routing CI4.
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl.replaceAll('/api', '')}/news"),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal mengambil data');
      }
    } catch (e) {
      print("Error News: $e");
      return []; // Mengembalikan list kosong jika error
    }
  }
}

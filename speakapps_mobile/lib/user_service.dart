import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_services.dart';

class UserService {
  static String get _baseUrl => ApiConfig.baseUrl;
  static String get profilePicBaseUrl => ApiConfig.baseUrl.replaceAll('/api', '/uploads/profile/');

  /// Mengirim data pembaruan profil ke backend CI4.
  /// Menggunakan [http.MultipartRequest] karena ada kemungkinan upload file gambar.
  ///
  /// - [userId]    : ID user yang sedang login (dari SharedPreferences)
  /// - [body]      : Map berisi field teks: 'name', 'semester', 'gender'
  /// - [imageFile] : File gambar baru (nullable). Jika null, foto lama tetap dipakai.
  Future<Map<String, dynamic>> updateProfile(
    int userId,
    Map<String, String> body,
    File? imageFile,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl/user/update/$userId');

      // Buat MultipartRequest agar bisa mengirim field teks + file sekaligus
      final request = http.MultipartRequest('POST', uri);

      // Tambahkan header (opsional, tapi disarankan)
      request.headers.addAll({
        'Accept': 'application/json',
      });

      // Tambahkan field teks (name, semester, gender)
      request.fields.addAll(body);

      // Jika ada file gambar baru yang dipilih, lampirkan sebagai multipart
      if (imageFile != null) {
        final multipartFile = await http.MultipartFile.fromPath(
          'profile_pic',       // harus sama dengan nama field di CI4 backend
          imageFile.path,
        );
        request.files.add(multipartFile);
      }

      // Kirim request dan tunggu response dengan timeout 10 detik
      final streamedResponse = await request.send().timeout(const Duration(seconds: 10));
      final responseBody = await streamedResponse.stream.bytesToString().timeout(const Duration(seconds: 10));

      // Decode JSON response dari CI4
      return json.decode(responseBody) as Map<String, dynamic>;
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Gagal terhubung ke server: $e',
      };
    }
  }
}

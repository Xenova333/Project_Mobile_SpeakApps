import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'api_services.dart';

class UserService {
  static String get _baseUrl => ApiConfig.baseUrl;

  /// URL dasar untuk menampilkan foto profil dari server CI4.
  /// Contoh hasil: http://192.168.1.6:8080/uploads/profile/foto.jpg
  static String get profilePicBaseUrl =>
      ApiConfig.baseUrl.replaceAll('/api', '/uploads/profile/');

  // ─────────────────────────────────────────────────────────────────────────
  //  updateProfile()
  //
  //  Mengirim pembaruan profil ke CI4 via HTTP MultipartRequest.
  //
  //  Catatan desain: parameter gambar sengaja TIDAK menggunakan class File
  //  dari dart:io agar file ini aman dicompile di platform Web (Chrome).
  //  Class File tidak tersedia di Web — maka:
  //   • Android → terima String path → http package yang baca file-nya
  //   • Web     → terima Uint8List bytes → langsung kirim via fromBytes()
  //
  //  Parameters:
  //  • [userId]    : ID user yang sedang login
  //  • [body]      : Map berisi 'name', 'semester', 'gender'
  //  • [imagePath] : Path file gambar di Android. Null = tidak ganti foto.
  //  • [webImage]  : Bytes gambar dari Web picker. Null = tidak ganti foto.
  // ─────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> updateProfile(
    int userId,
    Map<String, String> body,
    String? imagePath,    // path untuk Android (String saja, bukan File)
    Uint8List? webImage,  // bytes untuk Web
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl/user/update/$userId');

      // MultipartRequest agar field teks + file gambar bisa dikirim bersamaan
      final request = http.MultipartRequest('POST', uri);
      request.headers['Accept'] = 'application/json';

      // ── Field teks (NIM tidak dikirim — read-only di UI) ─────────────
      request.fields.addAll(body);

      // ── Sisipkan file gambar hanya jika user memilih foto baru ───────
      if (kIsWeb && webImage != null) {
        // ── Web (Chrome): gunakan fromBytes() karena tidak ada path file ─
        request.files.add(
          http.MultipartFile.fromBytes(
            'profile_pic',
            webImage,
            filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        );
      } else if (!kIsWeb && imagePath != null && imagePath.isNotEmpty) {
        // ── Android / iOS: baca file dari path via fromPath() ─────────
        // http.MultipartFile.fromPath() membaca dart:io.File secara internal
        // sehingga kita tidak perlu import dart:io di sini
        final multipartFile = await http.MultipartFile.fromPath(
          'profile_pic', // nama field harus sama dengan yang diharapkan CI4
          imagePath,
        );
        request.files.add(multipartFile);
      }
      // Jika keduanya null → request tetap dikirim tanpa file gambar
      // CI4 akan mempertahankan foto lama yang ada di database

      // ── Kirim request + baca response (timeout 20 detik untuk upload) ─
      final streamedResponse = await request.send()
          .timeout(const Duration(seconds: 20));
      final responseBody = await streamedResponse.stream
          .bytesToString()
          .timeout(const Duration(seconds: 20));

      // ── Decode JSON response dari CI4 ─────────────────────────────────
      final decoded = json.decode(responseBody);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {
        'status': 'error',
        'message': 'Format response tidak dikenal: $responseBody',
      };
    } on FormatException catch (e) {
      // CI4 mengembalikan HTML (misal: error 500) bukan JSON
      return {
        'status': 'error',
        'message': 'Server mengembalikan bukan JSON. Detail: $e',
      };
    } catch (e) {
      // Error jaringan, timeout, permission, dll.
      return {
        'status': 'error',
        'message': 'Gagal terhubung ke server: $e',
      };
    }
  }
}

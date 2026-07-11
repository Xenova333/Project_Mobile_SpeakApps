import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../api_services.dart';

class EventService {
  /// GET /api/events — Ambil semua event
  Future<List<dynamic>> fetchEvents() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/events"),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['data'] ?? [];
      } else {
        throw Exception('Gagal mengambil data event');
      }
    } catch (e) {
      print("Error fetchEvents: $e");
      return [];
    }
  }

  /// GET /api/events/{id} — Ambil detail event
  Future<Map<String, dynamic>?> fetchEvent(int id) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/events/$id"),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['data'];
      } else {
        throw Exception('Gagal mengambil detail event');
      }
    } catch (e) {
      print("Error fetchEvent: $e");
      return null;
    }
  }

  /// POST /api/events — Buat event baru (admin only)
  Future<Map<String, dynamic>> createEvent({
    required String title,
    required String description,
    required String eventDate,
    String? eventLink,
    String? imagePath,
    Uint8List? imageBytes,
    required int createdBy,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${ApiConfig.baseUrl}/events"),
      );

      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['event_date'] = eventDate;
      request.fields['event_link'] = eventLink ?? '';
      request.fields['created_by'] = createdBy.toString();

      if (imageBytes != null) {
        request.files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: 'event_image.jpg'));
      } else if (imagePath != null && imagePath.isNotEmpty) {
        final file = File(imagePath);
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath('image', imagePath),
          );
        }
      }

      request.headers['Accept'] = 'application/json';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return json.decode(response.body);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Gagal terhubung ke server: $e',
      };
    }
  }

  /// POST /api/events/update/{id} — Update event (admin only)
  Future<Map<String, dynamic>> updateEvent({
    required int id,
    required String title,
    required String description,
    required String eventDate,
    String? eventLink,
    String? imagePath,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${ApiConfig.baseUrl}/events/update/$id"),
      );

      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['event_date'] = eventDate;
      request.fields['event_link'] = eventLink ?? '';

      if (imagePath != null && imagePath.isNotEmpty) {
        if (!kIsWeb) {
          final file = File(imagePath);
          if (await file.exists()) {
            request.files.add(
              await http.MultipartFile.fromPath('image', imagePath),
            );
          }
        }
      }

      request.headers['Accept'] = 'application/json';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return json.decode(response.body);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Gagal terhubung ke server: $e',
      };
    }
  }

  /// DELETE /api/events/{id} — Hapus event
  Future<Map<String, dynamic>> deleteEvent(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("${ApiConfig.baseUrl}/events/$id"),
        headers: {'Accept': 'application/json'},
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Gagal terhubung ke server: $e',
      };
    }
  }
}

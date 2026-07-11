import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http_parser/http_parser.dart';
import '../api_services.dart';
import '../models/event_model.dart';

class EventController extends GetxController {
  var events = <EventModel>[].obs;
  var mainEvent = Rxn<EventModel>();
  var isLoading = false.obs;
  var isAdmin = false.obs;
  var isDeleteMode = false.obs;
  var userRole = ''.obs;
  int? currentMonth;
  final RxString searchQuery = ''.obs;

  List<EventModel> get filteredEvents {
    if (searchQuery.value.isEmpty) return events;
    final q = searchQuery.value.toLowerCase();
    return events.where((e) =>
      e.title.toLowerCase().contains(q) ||
      (e.description.toLowerCase().contains(q))
    ).toList();
  }

  EventModel? get latestEvent {
    if (events.isEmpty) return null;
    return events.first;
  }

  @override
  void onInit() {
    super.onInit();
    checkRole();
    fetchEvents();
    fetchMainEvent();
  }

  Future<void> checkRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role') ?? 'user';
    userRole.value = role;
    isAdmin.value = (role.trim().toLowerCase() == 'admin');
  }

  void toggleDeleteMode() {
    isDeleteMode.value = !isDeleteMode.value;
  }

  void searchEvent(String query) {
    searchQuery.value = query;
  }

  Future<void> loadEvents() async {
    await fetchEvents();
  }

  Future<void> fetchEvents() async {
    final activeMonth = currentMonth;

    isLoading.value = true;
    try {
      final Uri url = activeMonth != null
          ? Uri.parse('${ApiConfig.eventsUrl}/month/$activeMonth')
          : Uri.parse(ApiConfig.eventsUrl);

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'success') {
          final List<dynamic> eventsJson = data['data'];
          events.value = eventsJson.map((json) => EventModel.fromJson(json)).toList();
        }
      } else {
        Get.snackbar('Error', 'Gagal memuat daftar event');
      }
    } catch (e) {
      Get.snackbar('Error', 'Koneksi terputus: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMainEvent() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.eventsUrl}/main-active'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        mainEvent.value = EventModel.fromJson(data);
      } else {
        mainEvent.value = null;
      }
    } catch (e) {
      mainEvent.value = null;
    }
  }

  /// Buat event baru. Return Map {'status': 'success'/'error', 'message': '...'}
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
      var request = http.MultipartRequest('POST', Uri.parse(ApiConfig.eventsUrl));
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['event_date'] = eventDate;
      request.fields['event_link'] = eventLink ?? '';
      request.fields['created_by'] = createdBy.toString();

      if (imageBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'image.jpg',
          contentType: MediaType('image', 'jpeg'),
        ));
      } else if (imagePath != null && !kIsWeb) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }

      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();
      final data = json.decode(body);

      if (streamed.statusCode == 201 || streamed.statusCode == 200) {
        await fetchEvents();
        await fetchMainEvent();
        return {'status': 'success', 'message': 'Event berhasil dibuat', 'data': data['data']};
      }
      return {'status': 'error', 'message': data['message'] ?? 'Gagal membuat event'};
    } catch (e) {
      return {'status': 'error', 'message': 'Koneksi terputus: $e'};
    }
  }

  /// Update event. Return Map {'status': 'success'/'error', 'message': '...'}
  Future<Map<String, dynamic>> updateEvent({
    required int id,
    required String title,
    required String description,
    required String eventDate,
    String? eventLink,
    String? imagePath,
    Uint8List? imageBytes,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.eventsUrl}/update/$id'));
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['event_date'] = eventDate;
      request.fields['event_link'] = eventLink ?? '';
      request.fields['_method'] = 'PUT';

      if (imageBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'image.jpg',
          contentType: MediaType('image', 'jpeg'),
        ));
      } else if (imagePath != null && !kIsWeb) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }

      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();
      final data = json.decode(body);

      if (streamed.statusCode == 200) {
        await fetchEvents();
        await fetchMainEvent();
        return {'status': 'success', 'message': 'Event berhasil diperbarui', 'data': data['data']};
      }
      return {'status': 'error', 'message': data['message'] ?? 'Gagal memperbarui event'};
    } catch (e) {
      return {'status': 'error', 'message': 'Koneksi terputus: $e'};
    }
  }

  /// Hapus event. Return Map {'status': 'success'/'error', 'message': '...'}
  Future<Map<String, dynamic>> deleteEvent(int id) async {
    try {
      final response = await http.delete(Uri.parse('${ApiConfig.eventsUrl}/$id'));
      final data = json.decode(response.body);

      if (response.statusCode == 200 || data['status'] == 'success') {
        await fetchEvents();
        await fetchMainEvent();
        return {'status': 'success', 'message': 'Event berhasil dihapus'};
      }
      return {'status': 'error', 'message': data['message'] ?? 'Gagal menghapus event'};
    } catch (e) {
      return {'status': 'error', 'message': 'Koneksi terputus: $e'};
    }
  }

  /// Set main event. Return true/false untuk kompatibilitas dengan event_detail_page
  Future<bool> setMainEvent(int id) async {
    try {
      final response = await http.post(Uri.parse('${ApiConfig.eventsUrl}/main/$id'));
      final data = json.decode(response.body);

      if (response.statusCode == 200 || data['status'] == 'success') {
        await fetchEvents();
        await fetchMainEvent();
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Koneksi terputus: $e');
      return false;
    }
  }
}

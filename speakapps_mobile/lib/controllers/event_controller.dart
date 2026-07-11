import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
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
      (e.description?.toLowerCase().contains(q) ?? false)
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

  Future<void> loadEvents() async {
    fetchEvents();
  }
  Future<void> fetchMainEvent() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.eventsUrl}/main-active'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // CodeIgniter is returning the object directly since it's $this->respond($mainEvent)
        // Wait, CodeIgniter respond() might return the object directly or wrap it.
        // Let's assume it returns the object directly.
        mainEvent.value = EventModel.fromJson(data);
      } else {
        mainEvent.value = null;
      }
    } catch (e) {
      mainEvent.value = null;
    }
  }

  Future<bool> createEvent(String title, String description, String eventDate, String eventLink, {XFile? imageFile}) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(ApiConfig.eventsUrl));
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['event_date'] = eventDate;
      request.fields['event_link'] = eventLink;

      if (imageFile != null) {
        if (kIsWeb) {
          final bytes = await imageFile.readAsBytes();
          final ext = imageFile.name.split('.').last.toLowerCase();
          request.files.add(http.MultipartFile.fromBytes(
            'image', 
            bytes, 
            filename: imageFile.name,
            contentType: MediaType('image', ext == 'jpg' ? 'jpeg' : ext),
          ));
        } else {
          request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
        }
      }

      var response = await request.send();
      if (response.statusCode == 201 || response.statusCode == 200) {
        fetchEvents();
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Koneksi terputus: $e');
      return false;
    }
  }

  Future<bool> updateEvent(int id, String title, String description, String eventDate, String eventLink, {XFile? imageFile}) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.eventsUrl}/$id'));
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['event_date'] = eventDate;
      request.fields['event_link'] = eventLink;
      
      // Mengakali PUT request di CI4
      request.fields['_method'] = 'PUT';

      if (imageFile != null) {
        if (kIsWeb) {
          final bytes = await imageFile.readAsBytes();
          final ext = imageFile.name.split('.').last.toLowerCase();
          request.files.add(http.MultipartFile.fromBytes(
            'image', 
            bytes, 
            filename: imageFile.name,
            contentType: MediaType('image', ext == 'jpg' ? 'jpeg' : ext),
          ));
        } else {
          request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
        }
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        fetchEvents();
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Koneksi terputus: $e');
      return false;
    }
  }

  Future<bool> deleteEvent(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.eventsUrl}/$id'),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 || data['status'] == 'success') {
        fetchEvents();
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Koneksi terputus: $e');
      return false;
    }
  }

  Future<bool> setMainEvent(int id) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.eventsUrl}/main/$id'),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 || data['status'] == 'success') {
        fetchEvents();
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Koneksi terputus: $e');
      return false;
    }
  void searchEvent(String query) {
    searchQuery.value = query;
  }
  }
}

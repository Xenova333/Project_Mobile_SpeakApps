import 'dart:typed_data';
import 'package:get/get.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

class EventController extends GetxController {
  final EventService _eventService = EventService();

  final RxList<EventModel> events = <EventModel>[].obs;
  final RxBool isLoading = false.obs;
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
    loadEvents();
  }

  Future<void> loadEvents() async {
    isLoading.value = true;
    try {
      final data = await _eventService.fetchEvents();
      events.value = data.map((e) => EventModel.fromJson(e)).toList();
    } catch (e) {
      print("Error loadEvents: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void searchEvent(String query) {
    searchQuery.value = query;
  }

  Future<Map<String, dynamic>> createEvent({
    required String title,
    required String description,
    required String eventDate,
    String? eventLink,
    String? imagePath,
    Uint8List? imageBytes,
    required int createdBy,
  }) async {
    final result = await _eventService.createEvent(
      title: title,
      description: description,
      eventDate: eventDate,
      eventLink: eventLink,
      imagePath: imagePath,
      imageBytes: imageBytes,
      createdBy: createdBy,
    );

    if (result['status'] == 'success') {
      await loadEvents();
    }

    return result;
  }

  Future<Map<String, dynamic>> updateEvent({
    required int id,
    required String title,
    required String description,
    required String eventDate,
    String? eventLink,
    String? imagePath,
  }) async {
    final result = await _eventService.updateEvent(
      id: id,
      title: title,
      description: description,
      eventDate: eventDate,
      eventLink: eventLink,
      imagePath: imagePath,
    );

    if (result['status'] == 'success') {
      await loadEvents();
    }

    return result;
  }

  Future<Map<String, dynamic>> deleteEvent(int id) async {
    final result = await _eventService.deleteEvent(id);

    if (result['status'] == 'success') {
      await loadEvents();
    }

    return result;
  }
}

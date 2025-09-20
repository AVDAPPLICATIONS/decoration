import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import 'api_provider.dart';

final eventServiceProvider = Provider<EventService>((ref) {
  final api = ref.read(apiServiceProvider);
  return EventService(api);
});

final eventProvider = StateNotifierProvider<EventNotifier, List<EventModel>>((ref) {
  final service = ref.read(eventServiceProvider);
  return EventNotifier(ref, service);
});

class EventNotifier extends StateNotifier<List<EventModel>> {
  final Ref ref;
  final EventService service;

  EventNotifier(this.ref, this.service) : super([]);

  Future<void> fetchEvents() async {
    try {
      final events = await service.fetchEvents();
      state = events;
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  Future<List<EventModel>> getAllEvents() async {
    try {
      final events = await service.getAllEvents();
      return events;
    } catch (e) {
      print('Error fetching all events: $e');
      return [];
    }
  }

  Future<List<EventModel>> fetchEventsByYear(int yearId) async {
    try {
      final events = await service.fetchEventsByYear(yearId);
      return events;
    } catch (e) {
      print('Error fetching events by year: $e');
      return [];
    }
  }

  Future<void> addEvent(EventModel event) async {
    try {
      await service.createEvent(event);
      await fetchEvents();
    } catch (e) {
      print('Error adding event: $e');
    }
  }

  Future<void> updateEvent(int id, EventModel event) async {
    try {
      await service.updateEvent(id, event);
      await fetchEvents();
    } catch (e) {
      print('Error updating event: $e');
    }
  }

  Future<void> deleteEvent(int id) async {
    try {
      await service.deleteEvent(id);
      await fetchEvents();
    } catch (e) {
      print('Error deleting event: $e');
    }
  }
}

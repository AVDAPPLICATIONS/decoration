import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import 'api_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../data/repositories/event_repository.dart';

final eventServiceProvider = Provider<EventService>((ref) {
  final api = ref.read(apiServiceProvider);
  return EventService(api);
});

final eventProvider =
    StateNotifierProvider<EventNotifier, List<EventModel>>((ref) {
  final service = ref.read(eventServiceProvider);
  final repo = EventRepository(
    service: service,
    connectivity: Connectivity(),
    offline: ref.read(offlineCacheProvider),
  );
  return EventNotifier(ref, service, repo);
});

// Loading state provider for events
final eventLoadingProvider = StateProvider<bool>((ref) => false);

class EventNotifier extends StateNotifier<List<EventModel>> {
  final Ref ref;
  final EventService service;
  final EventRepository repo;

  EventNotifier(this.ref, this.service, this.repo) : super([]);

  Future<void> fetchEvents() async {
    try {
      ref.read(eventLoadingProvider.notifier).state = true;
      final events = await service.fetchEvents();
      state = events;
    } finally {
      ref.read(eventLoadingProvider.notifier).state = false;
    }
  }

  Future<List<EventModel>> getAllEvents() async {
    try {
      final events = await repo.getAllEvents();
      return events;
    } catch (e) {
      return [];
    }
  }

  Future<List<EventModel>> fetchEventsByYear(int yearId) async {
    try {
      final events = await repo.fetchEventsByYear(yearId);
      return events;
    } catch (e) {
      return [];
    }
  }

  Future<void> addEvent(EventModel event) async {
    try {
      await service.createEvent(event);
      await fetchEvents();
    } catch (e) {}
  }

  Future<void> updateEvent(int id, EventModel event) async {
    try {
      await service.updateEvent(id, event);
      await fetchEvents();
    } catch (e) {}
  }

  Future<void> deleteEvent(int id) async {
    try {
      await service.deleteEvent(id);
      await fetchEvents();
    } catch (e) {}
  }
}

import 'package:connectivity_plus/connectivity_plus.dart';

import '../../models/event_model.dart';
import '../../services/event_service.dart';
import 'offline_cache_repository.dart';

class EventRepository {
  static const String _eventsAllKey = 'events_all_v1';
  static const String _eventsByYearKeyPrefix = 'events_year_';

  final EventService service;
  final Connectivity connectivity;
  final OfflineCacheRepository? offline;

  EventRepository({
    required this.service,
    required this.connectivity,
    this.offline,
  });

  Future<bool> _isOnline() async {
    final res = await connectivity.checkConnectivity();
    return res.contains(ConnectivityResult.mobile) ||
        res.contains(ConnectivityResult.wifi) ||
        res.contains(ConnectivityResult.ethernet);
  }

  Future<List<EventModel>> getAllEvents() async {
    if (!await _isOnline() && offline != null) {
      final cached = await offline!.readJson<List<EventModel>>(
        _eventsAllKey,
        (obj) {
          if (obj is List) {
            return obj.map((e) => EventModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
          }
          return <EventModel>[];
        },
      );
      if (cached != null && cached.isNotEmpty) return cached;
    }

    final events = await service.getAllEvents();
    if (offline != null) {
      await offline!.saveJson(_eventsAllKey, events.map((e) => e.toJson()).toList());
    }
    return events;
  }

  Future<List<EventModel>> fetchEventsByYear(int yearId) async {
    final cacheKey = '$_eventsByYearKeyPrefix$yearId';
    if (!await _isOnline() && offline != null) {
      final cached = await offline!.readJson<List<EventModel>>(
        cacheKey,
        (obj) {
          if (obj is List) {
            return obj.map((e) => EventModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
          }
          return <EventModel>[];
        },
      );
      if (cached != null && cached.isNotEmpty) return cached;
    }

    final events = await service.fetchEventsByYear(yearId);
    if (offline != null) {
      await offline!.saveJson(cacheKey, events.map((e) => e.toJson()).toList());
    }
    return events;
  }

  Future<Map<String, dynamic>?> getEventDetails({
    required int templateId,
    required int yearId,
  }) async {
    final cacheKey = 'event_details_${templateId}_$yearId';
    
    if (!await _isOnline() && offline != null) {
      final cached = await offline!.readJson<Map<String, dynamic>>(
        cacheKey,
        (obj) {
          if (obj is Map) {
            return Map<String, dynamic>.from(obj);
          }
          return <String, dynamic>{};
        },
      );
      if (cached != null) {
        print('📱 Using cached event details for template $templateId, year $yearId');
        return cached;
      }
    }

    try {
      final eventDetails = await service.getEventDetails(
        templateId: templateId,
        yearId: yearId,
      );
      
      if (offline != null && eventDetails != null) {
        await offline!.saveJson(cacheKey, eventDetails);
        print('💾 Cached event details for template $templateId, year $yearId');
      }
      
      return eventDetails;
    } catch (e) {
      print('❌ Error fetching event details: $e');
      
      // Try to return cached data even if online but request failed
      if (offline != null) {
        final cached = await offline!.readJson<Map<String, dynamic>>(
          cacheKey,
          (obj) {
            if (obj is Map) {
              return Map<String, dynamic>.from(obj);
            }
            return <String, dynamic>{};
          },
        );
        if (cached != null) {
          print('📱 Using cached event details after error for template $templateId, year $yearId');
          return cached;
        }
      }
      
      rethrow;
    }
  }
}



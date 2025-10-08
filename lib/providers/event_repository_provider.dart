import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../data/repositories/event_repository.dart';
import '../services/event_service.dart';
import 'api_provider.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  final api = ref.read(apiServiceProvider);
  final service = EventService(api);
  return EventRepository(
    service: service,
    connectivity: Connectivity(),
    offline: ref.read(offlineCacheProvider),
  );
});

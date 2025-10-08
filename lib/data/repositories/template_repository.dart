import 'package:connectivity_plus/connectivity_plus.dart';

import '../../models/event_template_model.dart';
import '../../services/event_template_service.dart';
import 'offline_cache_repository.dart';

class TemplateRepository {
  static const String _templatesKey = 'event_templates_all_v1';

  final EventTemplateService service;
  final Connectivity connectivity;
  final OfflineCacheRepository? offline;

  TemplateRepository({
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

  Future<List<EventTemplateModel>> fetchTemplates() async {
    if (!await _isOnline() && offline != null) {
      final cached = await offline!.readJson<List<EventTemplateModel>>(
        _templatesKey,
        (obj) {
          if (obj is List) {
            return obj
                .map((e) => EventTemplateModel.fromJson(
                    Map<String, dynamic>.from(e as Map)))
                .toList();
          }
          return <EventTemplateModel>[];
        },
      );
      if (cached != null && cached.isNotEmpty) return cached;
    }

    final templates = await service.fetchTemplates();
    if (offline != null) {
      await offline!.saveJson(
        _templatesKey,
        templates
            .map((t) => {
                  'id': t.id,
                  'name': t.name,
                  'created_at': t.createdAt.toIso8601String(),
                })
            .toList(),
      );
    }
    return templates;
  }
}



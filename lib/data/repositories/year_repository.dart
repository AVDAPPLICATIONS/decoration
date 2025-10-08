import 'package:connectivity_plus/connectivity_plus.dart';

import '../../models/year_model.dart';
import '../../services/year_service.dart';
import 'offline_cache_repository.dart';

class YearRepository {
  static const String _yearsKey = 'years_all_v1';
  static const String _yearsByTemplateKey = 'years_by_template_v1';

  final YearService service;
  final Connectivity connectivity;
  final OfflineCacheRepository? offline;

  YearRepository({
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

  Future<List<YearModel>> fetchYears({int? templateId}) async {
    final cacheKey = templateId != null 
        ? '${_yearsByTemplateKey}_$templateId' 
        : _yearsKey;

    if (!await _isOnline() && offline != null) {
      final cached = await offline!.readJson<List<YearModel>>(
        cacheKey,
        (obj) {
          if (obj is List) {
            return obj
                .map((e) => YearModel.fromJson(
                    Map<String, dynamic>.from(e as Map)))
                .toList();
          }
          return <YearModel>[];
        },
      );
      if (cached != null && cached.isNotEmpty) return cached;
    }

    final years = await service.fetchYears(templateId: templateId);
    if (offline != null) {
      await offline!.saveJson(
        cacheKey,
        years
            .map((y) => {
                  'id': y.id,
                  'year_name': y.yearName,
                  'event_template_id': y.templateId,
                  'created_at': y.createdAt.toIso8601String(),
                  'template_name': y.templateName,
                })
            .toList(),
      );
    }
    return years;
  }

  Future<YearModel> createYear(YearModel year) async {
    final createdYear = await service.createYear(year);
    
    // Update cache if offline storage is available
    if (offline != null) {
      // Add to the appropriate cache
      final cacheKey = '${_yearsByTemplateKey}_${year.templateId}';
      final cached = await offline!.readJson<List<YearModel>>(
        cacheKey,
        (obj) {
          if (obj is List) {
            return obj
                .map((e) => YearModel.fromJson(
                    Map<String, dynamic>.from(e as Map)))
                .toList();
          }
          return <YearModel>[];
        },
      );
      
      if (cached != null) {
        cached.add(createdYear);
        await offline!.saveJson(
          cacheKey,
          cached
              .map((y) => {
                    'id': y.id,
                    'year_name': y.yearName,
                    'event_template_id': y.templateId,
                    'created_at': y.createdAt.toIso8601String(),
                    'template_name': y.templateName,
                  })
              .toList(),
        );
      }
    }
    
    return createdYear;
  }

  Future<void> deleteYear(int id) async {
    await service.deleteYear(id);
    
    // Remove from cache if offline storage is available
    if (offline != null) {
      // We need to find which cache contains this year and remove it
      // This is a simplified approach - in a real app you might want to track this better
      final allCachedKeys = await _getAllYearCacheKeys();
      for (final key in allCachedKeys) {
        final cached = await offline!.readJson<List<YearModel>>(
          key,
          (obj) {
            if (obj is List) {
              return obj
                  .map((e) => YearModel.fromJson(
                      Map<String, dynamic>.from(e as Map)))
                  .toList();
            }
            return <YearModel>[];
          },
        );
        
        if (cached != null) {
          final updated = cached.where((y) => y.id != id).toList();
          if (updated.length != cached.length) {
            await offline!.saveJson(
              key,
              updated
                  .map((y) => {
                        'id': y.id,
                        'year_name': y.yearName,
                        'event_template_id': y.templateId,
                        'created_at': y.createdAt.toIso8601String(),
                        'template_name': y.templateName,
                      })
                  .toList(),
            );
            break;
          }
        }
      }
    }
  }

  Future<List<String>> _getAllYearCacheKeys() async {
    // This is a simplified implementation
    // In a real app, you might want to maintain a list of cache keys
    return [_yearsKey];
  }
}

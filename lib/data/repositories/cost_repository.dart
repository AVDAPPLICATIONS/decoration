import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../../models/cost_model.dart';
import '../../services/cost_service.dart';
import 'offline_cache_repository.dart';

class CostRepository {
  static const String _costsByEventPrefix = 'costs_event_';

  final CostService service;
  final Connectivity connectivity;
  final OfflineCacheRepository? offline;

  CostRepository({
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

  Future<List<CostModel>> getEventCosts(int eventId) async {
    final cacheKey = '$_costsByEventPrefix$eventId';
    if (!await _isOnline() && offline != null) {
      final cached = await offline!.readJson<List<CostModel>>(
        cacheKey,
        (obj) {
          if (obj is List) {
            return obj.map((e) => CostModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
          }
          return <CostModel>[];
        },
      );
      if (cached != null && cached.isNotEmpty) return cached;
    }

    final response = await service.getEventCosts(eventId);
    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> costData = jsonDecode(response['data']);
      final costs = costData.map((json) => CostModel.fromJson(json)).toList();
      if (offline != null) {
        await offline!.saveJson(cacheKey, costs.map((c) => c.toJson()).toList());
      }
      return costs;
    }
    return <CostModel>[];
  }
}



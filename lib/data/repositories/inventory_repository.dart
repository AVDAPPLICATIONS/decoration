import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/inventory_service.dart';
import 'offline_cache_repository.dart';

class InventoryRepository {
  static const String _itemsCacheKey = 'inv_items_cache_v1';
  static const String _categoriesCacheKey = 'inv_categories_cache_v1';

  final InventoryService service;
  final Connectivity connectivity;
  final OfflineCacheRepository? offline;

  InventoryRepository({required this.service, required this.connectivity, this.offline});

  Future<bool> _isOnline() async {
    final res = await connectivity.checkConnectivity();
    return res.contains(ConnectivityResult.mobile) ||
        res.contains(ConnectivityResult.wifi) ||
        res.contains(ConnectivityResult.ethernet);
  }

  Future<List<Map<String, dynamic>>> getAllItems() async {
    final prefs = await SharedPreferences.getInstance();
    if (!await _isOnline()) {
      final cached = await (offline?.readJson<String>(_itemsCacheKey, (o) => o as String)) ?? prefs.getString(_itemsCacheKey);
      if (cached != null) {
        final list = jsonDecode(cached);
        if (list is List) {
          return list
              .where((e) => e is Map)
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    }

    final resp = await service.getAllItems();
    final data = (resp['data'] as List?) ?? const [];
    // cache
    await prefs.setString(_itemsCacheKey, jsonEncode(data));
    if (offline != null) {
      await offline!.saveJson(_itemsCacheKey, data);
    }
    return data
        .where((e) => e is Map)
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final prefs = await SharedPreferences.getInstance();
    if (!await _isOnline()) {
      final cached = await (offline?.readJson<String>(_categoriesCacheKey, (o) => o as String)) ?? prefs.getString(_categoriesCacheKey);
      if (cached != null) {
        final list = jsonDecode(cached);
        if (list is List) {
          return list
              .where((e) => e is Map)
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    }

    final resp = await service.getAllCategories();
    final data = (resp['data'] as List?) ?? const [];
    await prefs.setString(_categoriesCacheKey, jsonEncode(data));
    if (offline != null) {
      await offline!.saveJson(_categoriesCacheKey, data);
    }
    return data
        .where((e) => e is Map)
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }
}



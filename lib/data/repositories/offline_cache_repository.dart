import 'dart:convert';

import '../db/database.dart';

class OfflineCacheRepository {
  final AppDatabase db;
  OfflineCacheRepository(this.db);

  Future<void> saveJson(String key, Object? value) async {
    await db.upsertCache(key, jsonEncode(value));
  }

  Future<T?> readJson<T>(String key, T Function(Object? json) map) async {
    final raw = await db.readCache(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      return map(decoded);
    } catch (_) {
      return null;
    }
  }
}



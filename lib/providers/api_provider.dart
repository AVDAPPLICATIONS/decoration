import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../data/db/database.dart';
import '../services/image_cache_service.dart';
import '../data/repositories/offline_cache_repository.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(apiBaseUrl); // 👈 Uses value from constants.dart
});

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final offlineCacheProvider = Provider<OfflineCacheRepository>((ref) {
  return OfflineCacheRepository(ref.read(databaseProvider));
});

final imageCacheServiceProvider = Provider<ImageCacheService>((ref) {
  return ImageCacheService(ref.read(databaseProvider));
});

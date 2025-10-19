import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/db/database.dart';
import '../utils/constants.dart';

class ImageCacheService {
  final AppDatabase db;
  final Dio _dio;

  // In-memory short-lived cache to avoid repeated disk lookups
  final Map<String, String> _inMemoryPathByUrl = {};
  final Map<String, Future<File?>> _inflightDownloads = {};

  ImageCacheService(this.db, {Dio? dio}) : _dio = dio ?? Dio();

  Future<String?> getCachedPath(String url) async {
    if (_inMemoryPathByUrl.containsKey(url)) {
      final path = _inMemoryPathByUrl[url]!;
      if (await File(path).exists()) return path;
      // If file is missing, fallthrough to DB lookup
    }
    final fromDb = await db.readImageLocalPath(url);
    if (fromDb != null && await File(fromDb).exists()) {
      _inMemoryPathByUrl[url] = fromDb;
      return fromDb;
    }
    return null;
  }

  Future<void> ensureCached(String url) async {
    if (url.isEmpty) return;
    if (await getCachedPath(url) != null) return;
    // Deduplicate concurrent downloads
    if (_inflightDownloads.containsKey(url)) {
      await _inflightDownloads[url];
      return;
    }
    final future = _downloadAndStore(url);
    _inflightDownloads[url] = future;
    try {
      await future;
    } finally {
      _inflightDownloads.remove(url);
    }
  }

  Future<File?> getImageFile(String url) async {
    final path = await getCachedPath(url);
    if (path != null) return File(path);
    return await _downloadAndStore(url);
  }

  /// Check if an image exists on the server without downloading it
  Future<bool> imageExists(String url) async {
    try {
      String fullUrl = url;
      if (url.startsWith('/')) {
        fullUrl = '$apiBaseUrl$url';
      }
      
      await _dio.head(fullUrl);
      return true;
    } catch (e) {
      print('Image does not exist: $url - $e');
      return false;
    }
  }

  Future<File?> _downloadAndStore(String url) async {
    try {
      // Handle relative URLs by prepending the base URL
      String fullUrl = url;
      if (url.startsWith('/')) {
        fullUrl = '$apiBaseUrl$url';
        print('🔄 ImageCache: Converting relative URL to full URL: $url -> $fullUrl');
      } else {
        print('🔄 ImageCache: Using full URL: $url');
      }
      
      // First, check if the image exists with a HEAD request
      print('🔄 ImageCache: Checking if image exists at: $fullUrl');
      try {
        await _dio.head(fullUrl);
        print('✅ ImageCache: Image exists, proceeding with download');
      } catch (e) {
        print('❌ ImageCache: Image does not exist (404 or other error): $e');
        return null;
      }
      
      print('🔄 ImageCache: Attempting to download from: $fullUrl');
      final bytes = await _dio.get<List<int>>(fullUrl,
          options: Options(responseType: ResponseType.bytes));
      final dir = await getApplicationDocumentsDirectory();
      final parsed = Uri.parse(fullUrl);
      final tail = parsed.pathSegments.isNotEmpty ? parsed.pathSegments.last : 'img';
      final safeName = '${tail}_${url.hashCode}.bin';
      final localPath = p.join(dir.path, 'image_cache', safeName);
      final localFile = File(localPath);
      await localFile.parent.create(recursive: true);
      await localFile.writeAsBytes(bytes.data!);
      await db.upsertImage(url, localPath);
      _inMemoryPathByUrl[url] = localPath;
      print('✅ ImageCache: Successfully downloaded and cached image: $url -> $localPath');
      return localFile;
    } catch (e) {
      print('Error downloading and storing image: $e');
      return null;
    }
  }
}



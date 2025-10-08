import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';


class KeyValueCaches extends Table {
  TextColumn get cacheKey => text()();
  TextColumn get jsonValue => text()();
  IntColumn get updatedAtMillis => integer()();

  @override
  Set<Column> get primaryKey => {cacheKey};
}

class ImageCacheEntries extends Table {
  TextColumn get url => text()();
  TextColumn get localPath => text()();
  IntColumn get lastAccessedMillis => integer()();

  @override
  Set<Column> get primaryKey => {url};
}

@DriftDatabase(tables: [KeyValueCaches, ImageCacheEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Key-Value cache helpers
  Future<void> upsertCache(String key, String json) async {
    final millis = DateTime.now().millisecondsSinceEpoch;
    await into(keyValueCaches).insertOnConflictUpdate(
      KeyValueCachesCompanion(
        cacheKey: Value(key),
        jsonValue: Value(json),
        updatedAtMillis: Value(millis),
      ),
    );
  }

  Future<String?> readCache(String key) async {
    final row = await (select(keyValueCaches)
          ..where((tbl) => tbl.cacheKey.equals(key)))
        .getSingleOrNull();
    return row?.jsonValue;
  }

  // Image cache helpers
  Future<void> upsertImage(String url, String localPath) async {
    final millis = DateTime.now().millisecondsSinceEpoch;
    await into(imageCacheEntries).insertOnConflictUpdate(
      ImageCacheEntriesCompanion(
        url: Value(url),
        localPath: Value(localPath),
        lastAccessedMillis: Value(millis),
      ),
    );
  }

  Future<String?> readImageLocalPath(String url) async {
    final row = await (select(imageCacheEntries)
          ..where((tbl) => tbl.url.equals(url)))
        .getSingleOrNull();
    return row?.localPath;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'app_cache.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}



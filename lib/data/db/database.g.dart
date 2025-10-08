// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $KeyValueCachesTable extends KeyValueCaches
    with TableInfo<$KeyValueCachesTable, KeyValueCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KeyValueCachesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cacheKeyMeta =
      const VerificationMeta('cacheKey');
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
      'cache_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _jsonValueMeta =
      const VerificationMeta('jsonValue');
  @override
  late final GeneratedColumn<String> jsonValue = GeneratedColumn<String>(
      'json_value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMillisMeta =
      const VerificationMeta('updatedAtMillis');
  @override
  late final GeneratedColumn<int> updatedAtMillis = GeneratedColumn<int>(
      'updated_at_millis', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [cacheKey, jsonValue, updatedAtMillis];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'key_value_caches';
  @override
  VerificationContext validateIntegrity(Insertable<KeyValueCache> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cache_key')) {
      context.handle(_cacheKeyMeta,
          cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta));
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('json_value')) {
      context.handle(_jsonValueMeta,
          jsonValue.isAcceptableOrUnknown(data['json_value']!, _jsonValueMeta));
    } else if (isInserting) {
      context.missing(_jsonValueMeta);
    }
    if (data.containsKey('updated_at_millis')) {
      context.handle(
          _updatedAtMillisMeta,
          updatedAtMillis.isAcceptableOrUnknown(
              data['updated_at_millis']!, _updatedAtMillisMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMillisMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cacheKey};
  @override
  KeyValueCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KeyValueCache(
      cacheKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cache_key'])!,
      jsonValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}json_value'])!,
      updatedAtMillis: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at_millis'])!,
    );
  }

  @override
  $KeyValueCachesTable createAlias(String alias) {
    return $KeyValueCachesTable(attachedDatabase, alias);
  }
}

class KeyValueCache extends DataClass implements Insertable<KeyValueCache> {
  final String cacheKey;
  final String jsonValue;
  final int updatedAtMillis;
  const KeyValueCache(
      {required this.cacheKey,
      required this.jsonValue,
      required this.updatedAtMillis});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cache_key'] = Variable<String>(cacheKey);
    map['json_value'] = Variable<String>(jsonValue);
    map['updated_at_millis'] = Variable<int>(updatedAtMillis);
    return map;
  }

  KeyValueCachesCompanion toCompanion(bool nullToAbsent) {
    return KeyValueCachesCompanion(
      cacheKey: Value(cacheKey),
      jsonValue: Value(jsonValue),
      updatedAtMillis: Value(updatedAtMillis),
    );
  }

  factory KeyValueCache.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KeyValueCache(
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      jsonValue: serializer.fromJson<String>(json['jsonValue']),
      updatedAtMillis: serializer.fromJson<int>(json['updatedAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cacheKey': serializer.toJson<String>(cacheKey),
      'jsonValue': serializer.toJson<String>(jsonValue),
      'updatedAtMillis': serializer.toJson<int>(updatedAtMillis),
    };
  }

  KeyValueCache copyWith(
          {String? cacheKey, String? jsonValue, int? updatedAtMillis}) =>
      KeyValueCache(
        cacheKey: cacheKey ?? this.cacheKey,
        jsonValue: jsonValue ?? this.jsonValue,
        updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
      );
  KeyValueCache copyWithCompanion(KeyValueCachesCompanion data) {
    return KeyValueCache(
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      jsonValue: data.jsonValue.present ? data.jsonValue.value : this.jsonValue,
      updatedAtMillis: data.updatedAtMillis.present
          ? data.updatedAtMillis.value
          : this.updatedAtMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KeyValueCache(')
          ..write('cacheKey: $cacheKey, ')
          ..write('jsonValue: $jsonValue, ')
          ..write('updatedAtMillis: $updatedAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cacheKey, jsonValue, updatedAtMillis);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KeyValueCache &&
          other.cacheKey == this.cacheKey &&
          other.jsonValue == this.jsonValue &&
          other.updatedAtMillis == this.updatedAtMillis);
}

class KeyValueCachesCompanion extends UpdateCompanion<KeyValueCache> {
  final Value<String> cacheKey;
  final Value<String> jsonValue;
  final Value<int> updatedAtMillis;
  final Value<int> rowid;
  const KeyValueCachesCompanion({
    this.cacheKey = const Value.absent(),
    this.jsonValue = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KeyValueCachesCompanion.insert({
    required String cacheKey,
    required String jsonValue,
    required int updatedAtMillis,
    this.rowid = const Value.absent(),
  })  : cacheKey = Value(cacheKey),
        jsonValue = Value(jsonValue),
        updatedAtMillis = Value(updatedAtMillis);
  static Insertable<KeyValueCache> custom({
    Expression<String>? cacheKey,
    Expression<String>? jsonValue,
    Expression<int>? updatedAtMillis,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cacheKey != null) 'cache_key': cacheKey,
      if (jsonValue != null) 'json_value': jsonValue,
      if (updatedAtMillis != null) 'updated_at_millis': updatedAtMillis,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KeyValueCachesCompanion copyWith(
      {Value<String>? cacheKey,
      Value<String>? jsonValue,
      Value<int>? updatedAtMillis,
      Value<int>? rowid}) {
    return KeyValueCachesCompanion(
      cacheKey: cacheKey ?? this.cacheKey,
      jsonValue: jsonValue ?? this.jsonValue,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (jsonValue.present) {
      map['json_value'] = Variable<String>(jsonValue.value);
    }
    if (updatedAtMillis.present) {
      map['updated_at_millis'] = Variable<int>(updatedAtMillis.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KeyValueCachesCompanion(')
          ..write('cacheKey: $cacheKey, ')
          ..write('jsonValue: $jsonValue, ')
          ..write('updatedAtMillis: $updatedAtMillis, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImageCacheEntriesTable extends ImageCacheEntries
    with TableInfo<$ImageCacheEntriesTable, ImageCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImageCacheEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastAccessedMillisMeta =
      const VerificationMeta('lastAccessedMillis');
  @override
  late final GeneratedColumn<int> lastAccessedMillis = GeneratedColumn<int>(
      'last_accessed_millis', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [url, localPath, lastAccessedMillis];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'image_cache_entries';
  @override
  VerificationContext validateIntegrity(Insertable<ImageCacheEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('last_accessed_millis')) {
      context.handle(
          _lastAccessedMillisMeta,
          lastAccessedMillis.isAcceptableOrUnknown(
              data['last_accessed_millis']!, _lastAccessedMillisMeta));
    } else if (isInserting) {
      context.missing(_lastAccessedMillisMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {url};
  @override
  ImageCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImageCacheEntry(
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path'])!,
      lastAccessedMillis: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}last_accessed_millis'])!,
    );
  }

  @override
  $ImageCacheEntriesTable createAlias(String alias) {
    return $ImageCacheEntriesTable(attachedDatabase, alias);
  }
}

class ImageCacheEntry extends DataClass implements Insertable<ImageCacheEntry> {
  final String url;
  final String localPath;
  final int lastAccessedMillis;
  const ImageCacheEntry(
      {required this.url,
      required this.localPath,
      required this.lastAccessedMillis});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['url'] = Variable<String>(url);
    map['local_path'] = Variable<String>(localPath);
    map['last_accessed_millis'] = Variable<int>(lastAccessedMillis);
    return map;
  }

  ImageCacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return ImageCacheEntriesCompanion(
      url: Value(url),
      localPath: Value(localPath),
      lastAccessedMillis: Value(lastAccessedMillis),
    );
  }

  factory ImageCacheEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImageCacheEntry(
      url: serializer.fromJson<String>(json['url']),
      localPath: serializer.fromJson<String>(json['localPath']),
      lastAccessedMillis: serializer.fromJson<int>(json['lastAccessedMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'url': serializer.toJson<String>(url),
      'localPath': serializer.toJson<String>(localPath),
      'lastAccessedMillis': serializer.toJson<int>(lastAccessedMillis),
    };
  }

  ImageCacheEntry copyWith(
          {String? url, String? localPath, int? lastAccessedMillis}) =>
      ImageCacheEntry(
        url: url ?? this.url,
        localPath: localPath ?? this.localPath,
        lastAccessedMillis: lastAccessedMillis ?? this.lastAccessedMillis,
      );
  ImageCacheEntry copyWithCompanion(ImageCacheEntriesCompanion data) {
    return ImageCacheEntry(
      url: data.url.present ? data.url.value : this.url,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      lastAccessedMillis: data.lastAccessedMillis.present
          ? data.lastAccessedMillis.value
          : this.lastAccessedMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImageCacheEntry(')
          ..write('url: $url, ')
          ..write('localPath: $localPath, ')
          ..write('lastAccessedMillis: $lastAccessedMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(url, localPath, lastAccessedMillis);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImageCacheEntry &&
          other.url == this.url &&
          other.localPath == this.localPath &&
          other.lastAccessedMillis == this.lastAccessedMillis);
}

class ImageCacheEntriesCompanion extends UpdateCompanion<ImageCacheEntry> {
  final Value<String> url;
  final Value<String> localPath;
  final Value<int> lastAccessedMillis;
  final Value<int> rowid;
  const ImageCacheEntriesCompanion({
    this.url = const Value.absent(),
    this.localPath = const Value.absent(),
    this.lastAccessedMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImageCacheEntriesCompanion.insert({
    required String url,
    required String localPath,
    required int lastAccessedMillis,
    this.rowid = const Value.absent(),
  })  : url = Value(url),
        localPath = Value(localPath),
        lastAccessedMillis = Value(lastAccessedMillis);
  static Insertable<ImageCacheEntry> custom({
    Expression<String>? url,
    Expression<String>? localPath,
    Expression<int>? lastAccessedMillis,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (url != null) 'url': url,
      if (localPath != null) 'local_path': localPath,
      if (lastAccessedMillis != null)
        'last_accessed_millis': lastAccessedMillis,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImageCacheEntriesCompanion copyWith(
      {Value<String>? url,
      Value<String>? localPath,
      Value<int>? lastAccessedMillis,
      Value<int>? rowid}) {
    return ImageCacheEntriesCompanion(
      url: url ?? this.url,
      localPath: localPath ?? this.localPath,
      lastAccessedMillis: lastAccessedMillis ?? this.lastAccessedMillis,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (lastAccessedMillis.present) {
      map['last_accessed_millis'] = Variable<int>(lastAccessedMillis.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImageCacheEntriesCompanion(')
          ..write('url: $url, ')
          ..write('localPath: $localPath, ')
          ..write('lastAccessedMillis: $lastAccessedMillis, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $KeyValueCachesTable keyValueCaches = $KeyValueCachesTable(this);
  late final $ImageCacheEntriesTable imageCacheEntries =
      $ImageCacheEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [keyValueCaches, imageCacheEntries];
}

typedef $$KeyValueCachesTableCreateCompanionBuilder = KeyValueCachesCompanion
    Function({
  required String cacheKey,
  required String jsonValue,
  required int updatedAtMillis,
  Value<int> rowid,
});
typedef $$KeyValueCachesTableUpdateCompanionBuilder = KeyValueCachesCompanion
    Function({
  Value<String> cacheKey,
  Value<String> jsonValue,
  Value<int> updatedAtMillis,
  Value<int> rowid,
});

class $$KeyValueCachesTableFilterComposer
    extends Composer<_$AppDatabase, $KeyValueCachesTable> {
  $$KeyValueCachesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cacheKey => $composableBuilder(
      column: $table.cacheKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get jsonValue => $composableBuilder(
      column: $table.jsonValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAtMillis => $composableBuilder(
      column: $table.updatedAtMillis,
      builder: (column) => ColumnFilters(column));
}

class $$KeyValueCachesTableOrderingComposer
    extends Composer<_$AppDatabase, $KeyValueCachesTable> {
  $$KeyValueCachesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cacheKey => $composableBuilder(
      column: $table.cacheKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get jsonValue => $composableBuilder(
      column: $table.jsonValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAtMillis => $composableBuilder(
      column: $table.updatedAtMillis,
      builder: (column) => ColumnOrderings(column));
}

class $$KeyValueCachesTableAnnotationComposer
    extends Composer<_$AppDatabase, $KeyValueCachesTable> {
  $$KeyValueCachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get jsonValue =>
      $composableBuilder(column: $table.jsonValue, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMillis => $composableBuilder(
      column: $table.updatedAtMillis, builder: (column) => column);
}

class $$KeyValueCachesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $KeyValueCachesTable,
    KeyValueCache,
    $$KeyValueCachesTableFilterComposer,
    $$KeyValueCachesTableOrderingComposer,
    $$KeyValueCachesTableAnnotationComposer,
    $$KeyValueCachesTableCreateCompanionBuilder,
    $$KeyValueCachesTableUpdateCompanionBuilder,
    (
      KeyValueCache,
      BaseReferences<_$AppDatabase, $KeyValueCachesTable, KeyValueCache>
    ),
    KeyValueCache,
    PrefetchHooks Function()> {
  $$KeyValueCachesTableTableManager(
      _$AppDatabase db, $KeyValueCachesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KeyValueCachesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KeyValueCachesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KeyValueCachesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> cacheKey = const Value.absent(),
            Value<String> jsonValue = const Value.absent(),
            Value<int> updatedAtMillis = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              KeyValueCachesCompanion(
            cacheKey: cacheKey,
            jsonValue: jsonValue,
            updatedAtMillis: updatedAtMillis,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String cacheKey,
            required String jsonValue,
            required int updatedAtMillis,
            Value<int> rowid = const Value.absent(),
          }) =>
              KeyValueCachesCompanion.insert(
            cacheKey: cacheKey,
            jsonValue: jsonValue,
            updatedAtMillis: updatedAtMillis,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$KeyValueCachesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $KeyValueCachesTable,
    KeyValueCache,
    $$KeyValueCachesTableFilterComposer,
    $$KeyValueCachesTableOrderingComposer,
    $$KeyValueCachesTableAnnotationComposer,
    $$KeyValueCachesTableCreateCompanionBuilder,
    $$KeyValueCachesTableUpdateCompanionBuilder,
    (
      KeyValueCache,
      BaseReferences<_$AppDatabase, $KeyValueCachesTable, KeyValueCache>
    ),
    KeyValueCache,
    PrefetchHooks Function()>;
typedef $$ImageCacheEntriesTableCreateCompanionBuilder
    = ImageCacheEntriesCompanion Function({
  required String url,
  required String localPath,
  required int lastAccessedMillis,
  Value<int> rowid,
});
typedef $$ImageCacheEntriesTableUpdateCompanionBuilder
    = ImageCacheEntriesCompanion Function({
  Value<String> url,
  Value<String> localPath,
  Value<int> lastAccessedMillis,
  Value<int> rowid,
});

class $$ImageCacheEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ImageCacheEntriesTable> {
  $$ImageCacheEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastAccessedMillis => $composableBuilder(
      column: $table.lastAccessedMillis,
      builder: (column) => ColumnFilters(column));
}

class $$ImageCacheEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ImageCacheEntriesTable> {
  $$ImageCacheEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastAccessedMillis => $composableBuilder(
      column: $table.lastAccessedMillis,
      builder: (column) => ColumnOrderings(column));
}

class $$ImageCacheEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImageCacheEntriesTable> {
  $$ImageCacheEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<int> get lastAccessedMillis => $composableBuilder(
      column: $table.lastAccessedMillis, builder: (column) => column);
}

class $$ImageCacheEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ImageCacheEntriesTable,
    ImageCacheEntry,
    $$ImageCacheEntriesTableFilterComposer,
    $$ImageCacheEntriesTableOrderingComposer,
    $$ImageCacheEntriesTableAnnotationComposer,
    $$ImageCacheEntriesTableCreateCompanionBuilder,
    $$ImageCacheEntriesTableUpdateCompanionBuilder,
    (
      ImageCacheEntry,
      BaseReferences<_$AppDatabase, $ImageCacheEntriesTable, ImageCacheEntry>
    ),
    ImageCacheEntry,
    PrefetchHooks Function()> {
  $$ImageCacheEntriesTableTableManager(
      _$AppDatabase db, $ImageCacheEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImageCacheEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImageCacheEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImageCacheEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> url = const Value.absent(),
            Value<String> localPath = const Value.absent(),
            Value<int> lastAccessedMillis = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ImageCacheEntriesCompanion(
            url: url,
            localPath: localPath,
            lastAccessedMillis: lastAccessedMillis,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String url,
            required String localPath,
            required int lastAccessedMillis,
            Value<int> rowid = const Value.absent(),
          }) =>
              ImageCacheEntriesCompanion.insert(
            url: url,
            localPath: localPath,
            lastAccessedMillis: lastAccessedMillis,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ImageCacheEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ImageCacheEntriesTable,
    ImageCacheEntry,
    $$ImageCacheEntriesTableFilterComposer,
    $$ImageCacheEntriesTableOrderingComposer,
    $$ImageCacheEntriesTableAnnotationComposer,
    $$ImageCacheEntriesTableCreateCompanionBuilder,
    $$ImageCacheEntriesTableUpdateCompanionBuilder,
    (
      ImageCacheEntry,
      BaseReferences<_$AppDatabase, $ImageCacheEntriesTable, ImageCacheEntry>
    ),
    ImageCacheEntry,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$KeyValueCachesTableTableManager get keyValueCaches =>
      $$KeyValueCachesTableTableManager(_db, _db.keyValueCaches);
  $$ImageCacheEntriesTableTableManager get imageCacheEntries =>
      $$ImageCacheEntriesTableTableManager(_db, _db.imageCacheEntries);
}

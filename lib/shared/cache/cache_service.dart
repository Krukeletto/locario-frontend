import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CacheService {
  Database? _db;
  bool _initialized = false;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    await init();
    return _db!;
  }

  Future<void> init() async {
    if (_initialized) return;
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, 'locario_cache.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cache (
            key TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            hash INTEGER NOT NULL,
            fetched_at INTEGER NOT NULL
          )
        ''');
      },
    );
    _initialized = true;
  }

  Future<String?> getRaw(String key) async {
    final db = await _database;
    final rows = await db.query('cache', where: 'key = ?', whereArgs: [key]);
    if (rows.isEmpty) return null;
    return rows.first['data'] as String;
  }

  Future<T?> get<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final raw = await getRaw(key);
    if (raw == null) return null;
    try {
      return fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await invalidate(key);
      return null;
    }
  }

  Future<List<T>?> getList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final raw = await getRaw(key);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      await invalidate(key);
      return null;
    }
  }

  Future<void> setRaw(String key, String data, {int? hash}) async {
    final db = await _database;
    await db.insert('cache', {
      'key': key,
      'data': data,
      'hash': hash ?? data.hashCode,
      'fetched_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> set(String key, Map<String, dynamic> data, {int? hash}) async {
    final json = jsonEncode(data);
    await setRaw(key, json, hash: hash);
  }

  Future<void> setList(
    String key,
    List<Map<String, dynamic>> data, {
    int? hash,
  }) async {
    final json = jsonEncode(data);
    await setRaw(key, json, hash: hash);
  }

  Future<int?> getHash(String key) async {
    final db = await _database;
    final rows = await db.query(
      'cache',
      columns: ['hash'],
      where: 'key = ?',
      whereArgs: [key],
    );
    if (rows.isEmpty) return null;
    return rows.first['hash'] as int;
  }

  Future<void> invalidate(String key) async {
    final db = await _database;
    await db.delete('cache', where: 'key = ?', whereArgs: [key]);
  }

  Future<void> invalidateByPrefix(String prefix) async {
    final db = await _database;
    await db.delete('cache', where: 'key LIKE ?', whereArgs: ['$prefix%']);
  }

  Future<void> clear() async {
    final db = await _database;
    await db.delete('cache');
  }

  int computeHash(Object data) => jsonEncode(data).hashCode;

  Future<void> dispose() async {
    await _db?.close();
    _db = null;
    _initialized = false;
  }
}

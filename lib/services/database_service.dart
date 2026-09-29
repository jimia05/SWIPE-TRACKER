import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/swipe_entry.dart';
import 'tracker_store.dart';

/// Sqflite-backed [TrackerStore] — the app's real local persistence.
class DatabaseService implements TrackerStore {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();

  static const _dbName = 'swipe_tracker.db';
  static const _dbVersion = 1;

  Database? _db;

  Future<Database> get _database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            timestamp INTEGER NOT NULL,
            location TEXT,
            amount REAL,
            note TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE settings (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // --- Entries ---------------------------------------------------------

  @override
  Future<SwipeEntry> insertEntry(SwipeEntry entry) async {
    final db = await _database;
    final id = await db.insert('entries', entry.toMap()..remove('id'));
    return entry.copyWith(id: id);
  }

  @override
  Future<void> deleteEntry(int id) async {
    final db = await _database;
    await db.delete('entries', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<SwipeEntry>> allEntries() async {
    final db = await _database;
    final rows = await db.query('entries', orderBy: 'timestamp DESC');
    return rows.map(SwipeEntry.fromMap).toList();
  }

  Future<void> clearAllEntries() async {
    final db = await _database;
    await db.delete('entries');
  }

  // --- Settings ----------------------------------------------------------

  @override
  Future<String?> getSetting(String key) async {
    final db = await _database;
    final rows = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String;
  }

  @override
  Future<void> setSetting(String key, String value) async {
    final db = await _database;
    await db.insert('settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}

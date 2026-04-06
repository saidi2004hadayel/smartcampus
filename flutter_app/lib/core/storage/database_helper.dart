import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _dbName = 'smartcampus.db';
  static const _dbVersion = 1;
  Database? _db;

  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, _dbName),
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Database get db {
    if (_db == null) throw StateError('DB not initialized. Call init() first.');
    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE announcements (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        category TEXT,
        author TEXT,
        created_at TEXT,
        is_important INTEGER DEFAULT 0,
        cached_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE events (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        location TEXT,
        event_date TEXT,
        category TEXT,
        organizer TEXT,
        latitude REAL,
        longitude REAL,
        cached_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE timetable (
        id TEXT PRIMARY KEY,
        course_code TEXT,
        course_name TEXT,
        room TEXT,
        professor TEXT,
        day_of_week INTEGER,
        start_time TEXT,
        end_time TEXT,
        type TEXT,
        cached_at TEXT
      )
    ''');
  }

  // ── Announcements ──────────────────────────────────────────────────────────
  Future<void> upsertAnnouncements(List<Map<String, dynamic>> items) async {
    final batch = db.batch();
    for (final item in items) {
      batch.insert(
        'announcements',
        {...item, 'cached_at': DateTime.now().toIso8601String()},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedAnnouncements() =>
      db.query('announcements', orderBy: 'created_at DESC');

  // ── Events ─────────────────────────────────────────────────────────────────
  Future<void> upsertEvents(List<Map<String, dynamic>> items) async {
    final batch = db.batch();
    for (final item in items) {
      batch.insert(
        'events',
        {...item, 'cached_at': DateTime.now().toIso8601String()},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedEvents() =>
      db.query('events', orderBy: 'event_date ASC');

  // ── Timetable ──────────────────────────────────────────────────────────────
  Future<void> upsertTimetable(List<Map<String, dynamic>> items) async {
    await db.delete('timetable');
    final batch = db.batch();
    for (final item in items) {
      batch.insert(
        'timetable',
        {...item, 'cached_at': DateTime.now().toIso8601String()},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedTimetable({int? day}) {
    if (day != null) {
      return db.query(
        'timetable',
        where: 'day_of_week = ?',
        whereArgs: [day],
        orderBy: 'start_time ASC',
      );
    }
    return db.query('timetable', orderBy: 'day_of_week ASC, start_time ASC');
  }

  Future<void> close() async => _db?.close();
}

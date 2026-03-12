import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../features/schedule/models/subject.dart';
import '../../features/schedule/models/schedule_entry.dart';
import '../../features/notes/models/note.dart';

/// Singleton SQLite service for Aulens.
///
/// Tables:
/// - `subjects`
/// - `schedule`
/// - `notes`
///
/// Foreign keys use ON DELETE CASCADE so deleting a subject also deletes
/// related schedule entries and notes from the database.
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._();
  factory DatabaseService() => _instance;
  DatabaseService._();

  static const String _dbName = 'aulens.db';
  static const int _dbVersion = 2;

  static const String _subjectsTable = 'subjects';
  static const String _scheduleTable = 'schedule';
  static const String _legacyScheduleTable = 'schedule_entries';
  static const String _notesTable = 'notes';

  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  Future<Database> _open() async {
    final basePath = await getDatabasesPath();
    final dbPath = p.join(basePath, _dbName);

    return openDatabase(
      dbPath,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_subjectsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $_scheduleTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER NOT NULL
          REFERENCES $_subjectsTable(id) ON DELETE CASCADE,
        weekday INTEGER NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $_notesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER NOT NULL
          REFERENCES $_subjectsTable(id) ON DELETE CASCADE,
        image_path TEXT NOT NULL,
        ocr_text TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _migrateScheduleEntriesToSchedule(db);
    }

    // Safety migration for legacy DBs that may not have OCR storage yet.
    await _ensureNotesOcrColumn(db);
  }

  Future<void> _migrateScheduleEntriesToSchedule(Database db) async {
    final hasSchedule = await _tableExists(db, _scheduleTable);
    if (!hasSchedule) {
      await db.execute('''
        CREATE TABLE $_scheduleTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          subject_id INTEGER NOT NULL
            REFERENCES $_subjectsTable(id) ON DELETE CASCADE,
          weekday INTEGER NOT NULL,
          start_time TEXT NOT NULL,
          end_time TEXT NOT NULL
        )
      ''');
    }

    final hasLegacy = await _tableExists(db, _legacyScheduleTable);
    if (hasLegacy) {
      await db.execute('''
        INSERT INTO $_scheduleTable (id, subject_id, weekday, start_time, end_time)
        SELECT id, subject_id, weekday, start_time, end_time
        FROM $_legacyScheduleTable
      ''');
      await db.execute('DROP TABLE $_legacyScheduleTable');
    }
  }

  Future<bool> _tableExists(DatabaseExecutor db, String tableName) async {
    final rows = await db.query(
      'sqlite_master',
      columns: ['name'],
      where: 'type = ? AND name = ?',
      whereArgs: ['table', tableName],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> _ensureNotesOcrColumn(Database db) async {
    final columns = await db.rawQuery('PRAGMA table_info($_notesTable)');
    final hasOcr = columns.any((row) => row['name'] == 'ocr_text');
    if (!hasOcr) {
      await db.execute('ALTER TABLE $_notesTable ADD COLUMN ocr_text TEXT');
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db != null && db.isOpen) {
      await db.close();
    }
    _db = null;
  }

  // ── Subjects CRUD ──────────────────────────────────────────────────────────

  Future<int> insertSubject(Subject subject) async {
    final db = await database;
    return db.insert(_subjectsTable, subject.toMap());
  }

  Future<List<Subject>> getSubjects() async {
    final db = await database;
    final rows = await db.query(_subjectsTable, orderBy: 'name ASC');
    return rows.map(Subject.fromMap).toList();
  }

  Future<Subject?> getSubjectById(int id) async {
    final db = await database;
    final rows = await db.query(
      _subjectsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Subject.fromMap(rows.first);
  }

  Future<int> updateSubject(Subject subject) async {
    if (subject.id == null) {
      throw ArgumentError('Subject id is required for update');
    }
    final db = await database;
    return db.update(
      _subjectsTable,
      subject.toMap(),
      where: 'id = ?',
      whereArgs: [subject.id],
    );
  }

  Future<int> deleteSubject(int id) async {
    final db = await database;
    return db.delete(_subjectsTable, where: 'id = ?', whereArgs: [id]);
  }

  // ── Schedule CRUD ──────────────────────────────────────────────────────────

  Future<int> insertScheduleEntry(ScheduleEntry entry) async {
    final db = await database;
    return db.insert(_scheduleTable, entry.toMap());
  }

  Future<List<ScheduleEntry>> getScheduleEntries() async {
    final db = await database;
    final rows = await db.query(
      _scheduleTable,
      orderBy: 'weekday ASC, start_time ASC',
    );
    return rows.map(ScheduleEntry.fromMap).toList();
  }

  Future<List<ScheduleEntry>> getScheduleEntriesBySubject(int subjectId) async {
    final db = await database;
    final rows = await db.query(
      _scheduleTable,
      where: 'subject_id = ?',
      whereArgs: [subjectId],
      orderBy: 'weekday ASC, start_time ASC',
    );
    return rows.map(ScheduleEntry.fromMap).toList();
  }

  Future<ScheduleEntry?> getScheduleEntryById(int id) async {
    final db = await database;
    final rows = await db.query(
      _scheduleTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ScheduleEntry.fromMap(rows.first);
  }

  Future<int> updateScheduleEntry(ScheduleEntry entry) async {
    if (entry.id == null) {
      throw ArgumentError('ScheduleEntry id is required for update');
    }
    final db = await database;
    return db.update(
      _scheduleTable,
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteScheduleEntry(int id) async {
    final db = await database;
    return db.delete(_scheduleTable, where: 'id = ?', whereArgs: [id]);
  }

  // ── Notes CRUD ─────────────────────────────────────────────────────────────

  Future<int> insertNote(Note note) async {
    final db = await database;
    return db.insert(_notesTable, note.toMap());
  }

  Future<List<Note>> getNotes() async {
    final db = await database;
    final rows = await db.query(_notesTable, orderBy: 'created_at DESC');
    return rows.map(Note.fromMap).toList();
  }

  Future<List<Note>> getNotesBySubject(int subjectId) async {
    final db = await database;
    final rows = await db.query(
      _notesTable,
      where: 'subject_id = ?',
      whereArgs: [subjectId],
      orderBy: 'created_at DESC',
    );
    return rows.map(Note.fromMap).toList();
  }

  Future<Note?> getNoteById(int id) async {
    final db = await database;
    final rows = await db.query(
      _notesTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Note.fromMap(rows.first);
  }

  Future<int> updateNote(Note note) async {
    if (note.id == null) {
      throw ArgumentError('Note id is required for update');
    }
    final db = await database;
    return db.update(
      _notesTable,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return db.delete(_notesTable, where: 'id = ?', whereArgs: [id]);
  }
}

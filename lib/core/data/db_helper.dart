import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../features/home/models/journal_entry.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('embrace_journal_v7.db'); // VERSION 7
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String path;
    if (kIsWeb) {
      path = filePath;
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, filePath);
    }

    return await openDatabase(
      path,
      version: 7, // VERSION 7
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE journals (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      date TEXT NOT NULL,
      isDeleted INTEGER NOT NULL,
      image_base64 TEXT,
      mood TEXT,
      isFavorite INTEGER DEFAULT 0 
    )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 7) {
      try {
        await db.execute(
            "ALTER TABLE journals ADD COLUMN isFavorite INTEGER DEFAULT 0");
      } catch (e) {
        // Column might exist
      }
    }
  }

  // --- CRUD Operations (Same as before) ---
  Future<int> create(JournalEntry entry) async {
    final db = await instance.database;
    return await db.insert('journals', entry.toMap());
  }

  Future<List<JournalEntry>> readAllJournals() async {
    final db = await instance.database;
    final result = await db.query('journals',
        where: 'isDeleted = 0', orderBy: 'date DESC');
    return result.map((json) => JournalEntry.fromMap(json)).toList();
  }

  Future<List<JournalEntry>> readDeletedJournals() async {
    final db = await instance.database;
    final result = await db.query('journals',
        where: 'isDeleted = 1', orderBy: 'date DESC');
    return result.map((json) => JournalEntry.fromMap(json)).toList();
  }

  Future<int> update(JournalEntry entry) async {
    final db = await instance.database;
    return db.update('journals', entry.toMap(),
        where: 'id = ?', whereArgs: [entry.id]);
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return db.delete('journals', where: 'id = ?', whereArgs: [id]);
  }
}

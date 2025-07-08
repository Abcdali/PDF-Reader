import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'note.dart';
class DatabaseHelper {

  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();
  static Database? _database;
  static const String _databaseName = "notes_app.db";
  static const int _databaseVersion = 1;

  static const String tableNotes = 'notes';
  static const String columnId = 'id';
  static const String columnTitle = 'title';
  static const String columnContent = 'content';
  static const String columnCreatedAt = 'created_at';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableNotes (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitle TEXT NOT NULL,
        $columnContent TEXT NOT NULL,
        $columnCreatedAt TEXT NOT NULL
      )
    ''');
  }
  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert(
      tableNotes,
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Note>> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableNotes);
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  Future<Note?> getNoteById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableNotes,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Note.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      tableNotes,
      note.toMap(),
      where: '$columnId = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete(
      tableNotes,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<void> batchInsertNotes(List<Note> notes) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var note in notes) {
        await txn.insert(
          tableNotes,
          note.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}

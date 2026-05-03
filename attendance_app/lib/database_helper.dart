import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('attendance.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {

    await db.execute('''
    CREATE TABLE Students (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      student_name TEXT,
      roll_number TEXT,
      course_name TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE Absence (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date_time TEXT,
      student_id INTEGER,
      FOREIGN KEY(student_id) REFERENCES Students(id)
    )
    ''');
  }
}
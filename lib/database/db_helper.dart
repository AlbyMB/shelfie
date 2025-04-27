import 'package:shelfie/models/user_model.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper dbHelper = DBHelper._secretDBConstructor();
  static Database? _database;

  DBHelper._secretDBConstructor();

  Future<Database?> get dataBase async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'main_database.db');
    return openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  void _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        password TEXT,
        createdAt TEXT,
        isLoggedIn TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE foods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        name TEXT,
        categoryId INTEGER,
        imageUrl TEXT,
        description TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        quantity TEXT,
        unit TEXT
      )
    ''');
  }

Future<int> insertDb(Map<String, dynamic> row, String tablename) async {
  Database? db = await dataBase;
  return db!.insert(tablename, row);

}

Future<List<Map<String, dynamic>>> readDb(String tablename, {String? whereField, String? whereString, int? whereValue}) async {
    Database? db = await dataBase;
    if (whereField != null) {
      return db!.query(tablename, where: '$whereField = ?', whereArgs: whereValue != null ? [whereValue] : (whereString != null ? [whereString] : null));
    }
    return db!.query(tablename);
  }

  Future<int> updateDb(Map<String, dynamic> row, String tablename) async {
    Database? db = await dataBase;
    return db!.update(tablename, row,
        where: 'id = ?', whereArgs: [row['id']]);
  }

  Future<int> deleteDb(int id, String tablename) async {
    Database? db = await dataBase;
    return db!.delete(tablename, where: 'id = ?', whereArgs: [id]);
  }
}
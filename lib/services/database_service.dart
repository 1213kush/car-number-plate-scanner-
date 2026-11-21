import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {

  static Database? database;

  Future<Database> get db async {

    if (database != null) {
      return database!;
    }

    database = await initDatabase();

    return database!;
  }

  Future<Database> initDatabase() async {

    final dbPath = await getDatabasesPath();

    final path = join(dbPath, 'vehicles.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {

        await db.execute('''
          CREATE TABLE vehicles (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            vehicle_number TEXT NOT NULL,
            image_path TEXT NOT NULL,
            scanned_at TEXT NOT NULL
          )
        ''');

      },
    );
  }

  Future<int> insertVehicle(
      String number,
      String imagePath,
      ) async {

    final database = await db;

    return await database.insert(
      'vehicles',
      {
        'vehicle_number': number,
        'image_path': imagePath,
        'scanned_at': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<List<Map<String, dynamic>>> getVehicles() async {

    final database = await db;

    return await database.query(
      'vehicles',
      orderBy: 'id DESC',
    );
  }

  Future<int> deleteVehicle(int id) async {
    final database = await db;

    return await database.delete(
      'vehicles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
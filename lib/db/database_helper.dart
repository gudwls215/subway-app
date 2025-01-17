import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'subway.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE station_congestion (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        station_name TEXT,
        direction TEXT,
        time TEXT,
        congestion REAL
      )
    ''');
  }

  Future<void> insertData(String stationName, String direction, Map<String, double> congestionData) async {
    final db = await database;

    congestionData.forEach((time, congestion) async {
      await db.insert('station_congestion', {
        'station_name': stationName,
        'direction': direction,
        'time': time,
        'congestion': congestion,
      });
    });
  }

  Future<List<Map<String, dynamic>>> getCongestionData(String stationName) async {
    final db = await database;
    return await db.query(
      'station_congestion',
      where: 'station_name = ?',
      whereArgs: [stationName],
    );
  }
}

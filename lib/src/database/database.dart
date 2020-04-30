import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tutorial_flutter_sqflite/src/model/car_model.dart';

class CarDatabase {
  static final CarDatabase _instance = CarDatabase._();//Private Constructor
  static Database _database;

  CarDatabase._();

   factory CarDatabase() {//hna brg3 el CarDatabase instance Value Static
    return _instance; //A factory interface reports the type of the created objects.
  }

  Future<Database> get db async {
    if (_database != null) {
      return _database;
    }

    _database = await init();

    return _database;
  }

  Future<Database> init() async {
    Directory directory = await getApplicationDocumentsDirectory();//app folder on my device
    String dbPath = join(directory.path, 'database.db');//file eli hyb2a feh el data
    var database = openDatabase(dbPath, version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);

    return database;
  }

  void _onCreate(Database db, int version) {
    db.execute('''
      CREATE TABLE car(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        model TEXT,
        power INTEGER,
        top_speed INTEGER,
        is_electro INTEGER)
    ''');
    print("Database was created!");
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) {
    // Run migration according database versions
  }

  Future<int> addCar(Car car) async {
    var client = await db;
    return client.insert('car', car.toMapForDb(), conflictAlgorithm: ConflictAlgorithm.replace);//law fe 7aga bnfs el asm b3ml replace bl value bta3ty
  }

  Future<Car> fetchCar(int id) async {
    var client = await db;
    final Future<List<Map<String, dynamic>>> futureMaps = client.query('car', where: 'id = ?', whereArgs: [id]);
    var maps = await futureMaps;//List<Map<String, dynamic>>

    if (maps.length != 0) {
      return Car.fromDb(maps.first);
    }

    return null;
  }

  Future<List<Car>> fetchAll() async {
    var client = await db;
    var res = await client.query('car');

    if (res.isNotEmpty) {
      var cars = res.map((carMap) => Car.fromDb(carMap)).toList();
      return cars;
    }
    return [];
  }

  Future<int> updateCar(Car newCar) async {
    var client = await db;
    return client.update('car', newCar.toMapForDb(),
        where: 'id = ?', whereArgs: [newCar.id], conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeCar(int id) async {
    var client = await db;
    return client.delete('car', where: 'id = ?', whereArgs: [id]);
  }

  Future closeDb() async {
    var client = await db;
    client.close();
  }
}

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:apilocaldata/productmodel.dart';

class DatabaseHelper {
  static Database? _database;
  static const String tableName = 'products';

  Future<void> initializeDatabase() async {
    if (_database != null) return; // If database is already initialized, return

    try {
      // Get the database path
      String databasesPath = await getDatabasesPath();
      String path = join(databasesPath, 'products.db');

      // Open the database at the specified path
      _database = await openDatabase(
        path,
        onCreate: (db, version) {
          return db.execute('''
            CREATE TABLE $tableName (
              id INTEGER PRIMARY KEY,
              title TEXT,
              price REAL,
              description TEXT,
              category TEXT,
              image TEXT
            )
          ''');
        },
        version: 1,
      );
    } catch (e) {
      print('Error initializing database: $e');
      throw 'Could not initialize database';
    }
  }

  Future<Database> get database async {
    await initializeDatabase(); // Ensure the database is initialized
    return _database!;
  }

  Future<void> insertProducts(List<Product> products) async {
    final db = await database;
    Batch batch = db.batch();
    products.forEach((product) {
      batch.insert(
        tableName,
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace, // Use conflict algorithm to handle duplicate IDs
      );
    });
    await batch.commit();
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }
}

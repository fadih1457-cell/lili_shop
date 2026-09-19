import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('lili_shop.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS products');
          await _createDB(db, newVersion);
        }
      },
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        cost_price REAL NOT NULL,
        sell_price REAL NOT NULL,
        stock INTEGER NOT NULL,
        barcode TEXT UNIQUE
      )
    ''');
  }

  // إضافة منتج جديد للمخزن
  Future<int> insertProduct(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(
      'products',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // جلب كل المنتجات
  Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await database;
    return await db.query('products');
  }

  // جلب المنتجات التي نفدت (الكمية = 0)
  Future<List<Map<String, dynamic>>> getOutOfStockProducts() async {
    final db = await database;
    return await db.query('products', where: 'stock <= 0');
  }

  // البحث عن منتج بالباركود
  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    final db = await database;
    final results = await db.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  // تحديث كمية المنتج عند البيع أو التعديل
  Future<int> updateProduct(Map<String, dynamic> row) async {
    final db = await database;
    int id = row['id'];
    return await db.update('products', row, where: 'id = ?', whereArgs: [id]);
  }

  // حذف منتج
  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}

// حذف دين معين
Future<int> deleteDebt(int id) async {
  final db = await database;
  return await db.delete('debts', where: 'id = ?', whereArgs: [id]);
}

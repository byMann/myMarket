import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "cart.db";
  static const _databaseVersion = 1;
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
     CREATE TABLE cart  (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      produk_id INTEGER NOT NULL,
      nama TEXT NOT NULL,
      jumlah INTEGER NOT NULL,
      harga INTEGER NOT NULL,
     )
     ''');
  }

  Future<Map<String, dynamic>?> getCartItem(int produkId) async {
    final db = await database;
    final res = await db!.query(
      'cart',
      where: 'produk_id = ?',
      whereArgs: [produkId],
      limit: 1,
    );
    if (res.isNotEmpty) return res.first;
    return null;
  }

  Future<void> addCart(Map<String, dynamic> row) async {
    final db = await database;
    // cek kalau produk yg sama udah ada di cart
    var res = await db!.query(
      "cart",
      where: "produk_id = ?",
      whereArgs: [row['produk_id']],
    );

    if (res.isNotEmpty) {
      // kalau ada, tambah jumlah
      int jumlahLama = (res[0]["jumlah"] ?? 0) as int;
      await db.update(
        "cart",
        {"jumlah": jumlahLama + 1},
        where: "produk_id = ?",
        whereArgs: [row['produk_id']],
      );
    } else {
      // kalau belum ada, insert baru
      await db.insert("cart", row);
    }
  }

  Future<List<Map<String, dynamic>>?> viewCart() async {
    Database? db = await instance.database;
    return await db!.query('cart');
  }

  Future tambahJumlah(int produkId) async {
    final db = await database;
    await db?.execute(
      'UPDATE cart SET jumlah = jumlah + 1 WHERE produk_id = ?',
      [produkId],
    );
  }

  Future kurangJumlah(int produkId) async {
    final db = await database;
    await db?.execute(
      'UPDATE cart SET jumlah = jumlah - 1 WHERE produk_id = ?',
      [produkId],
    );
  }

  Future emptyCart() async {
    Database? db = await instance.database;
    await db?.execute('''
     DELETE FROM cart
     ''');
  }
}

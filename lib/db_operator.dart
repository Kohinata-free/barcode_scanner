import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

const String db_name = 'products_database.db';

// SQLiteデータベースの初期化
Future<Database> initDatabase() async {
  return openDatabase(
    join(await getDatabasesPath(), db_name),
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE products(barcode TEXT PRIMARY KEY, brandName TEXT, productName TEXT, countryName TEXT, quantity TEXT, imageUrl TEXT)",
      );
    },
    version: 1,
  );
}

// 商品情報をSQLiteデータベースに保存する
Future<void> insertProduct(Map<String, dynamic> productInfo) async {
  final Database db = await initDatabase();
  await db.insert(
    'products',
    productInfo,
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

// 商品情報をSQLiteデータベースから取得する
Future<List<Map<String, dynamic>>> retrieveProducts() async {
  final Database db = await initDatabase();
  return await db.query('products');
}

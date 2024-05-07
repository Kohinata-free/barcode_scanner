import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';

const String db_name = 'products_database.db';

// SQLiteデータベースの初期化
Future<Database> initDatabase() async {
  return await openDatabase(
    // join(await getDatabasesPath(), db_name),
    db_name,
    version: 1,
    onCreate: (db, version) async {
      return await db.execute(
        "CREATE TABLE IF NOT EXISTS products(barcode TEXT PRIMARY KEY, brandName TEXT, productName TEXT, countryName TEXT, quantity TEXT, imageUrl TEXT)",
      );
    },
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

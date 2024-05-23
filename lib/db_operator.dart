import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';

const String db_name = 'products_database.db';

// SQLiteデータベースの初期化
Future<Database> initDatabase() async {
  // DB削除
  // await deleteDatabase(db_name);

  return await openDatabase(
    // join(await getDatabasesPath(), db_name),
    db_name,
    version: 1,
    onCreate: (db, version) async {
      return await db.execute(
        "CREATE TABLE IF NOT EXISTS products(barcode TEXT PRIMARY KEY,  productName TEXT, makerName TEXT, brandName TEXT, countryName TEXT, quantity TEXT, storeName TEXT, comment TEXT, imageUrl TEXT)",
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

// 商品情報をSQLiteデータベースから取得する（barcodeを指定して1件取得）
Future<Map<String, dynamic>?> retrieveProductByBarcode(String barcode) async {
  final Database db = await initDatabase();
  List<Map<String, dynamic>> products = await db.query(
    'products',
    where: 'barcode = ?',
    whereArgs: [barcode],
    limit: 1, // 1件のみ取得する
  );
  if (products.isNotEmpty) {
    return products.first;
  } else {
    return null; // 該当する商品が見つからない場合はnullを返す
  }
}

// 商品情報をSQLiteデータベースから削除する
Future<void> deleteProduct(String barcode) async {
  final Database db = await initDatabase();
  await db.delete(
    'products',
    where: "barcode = ?",
    whereArgs: [barcode],
  );
}

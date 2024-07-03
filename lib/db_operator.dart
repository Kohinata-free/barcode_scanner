import 'package:sqflite/sqflite.dart';

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
      await db.execute(
        "CREATE TABLE IF NOT EXISTS products(code TEXT PRIMARY KEY,  name TEXT, maker TEXT, country TEXT, capacity TEXT, store TEXT, comment TEXT, imageUrl TEXT, favorit INTEGER)",
      );

      // トリガーの作成
      await db.execute(
        "CREATE TRIGGER IF NOT EXISTS limit_products_count "
        "BEFORE INSERT ON products "
        "WHEN (SELECT COUNT(*) FROM products) >= 100 "
        "BEGIN "
        "  SELECT RAISE(ABORT, 'Cannot insert more than 100 products'); "
        "END;",
      );
    },
    // バージョン更新時の処理を追加
    onUpgrade: (db, oldVersion, newVersion) async {
      //   if (oldVersion < 2) {
      //     // バージョンが1から2にアップグレードされる場合、countカラムを追加
      //     await db.execute(
      //       "ALTER TABLE products ADD COLUMN favorit INTEGER",
      //     );
      //   }
    },
  );
}

// 商品情報をSQLiteデータベースに保存する
Future<bool> insertProduct(Map<String, dynamic> productInfo) async {
  final Database db = await initDatabase();

  // 100件を超えていないかをチェックするクエリを実行
  final countResult =
      await db.rawQuery('SELECT COUNT(*) as count FROM products');
  final count = Sqflite.firstIntValue(countResult);

  // barcodeが存在するかチェック
  final existingProduct = await db
      .query('products', where: 'code = ?', whereArgs: [productInfo['code']]);

  if (existingProduct.isNotEmpty) {
    await db.update('products', productInfo,
        where: 'code = ?', whereArgs: [productInfo['code']]);
  } else if (count! < 100) {
    await db.insert(
      'products',
      productInfo,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  } else {
    return false;
  }

  return true;
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
    where: 'code = ?',
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
    where: "code = ?",
    whereArgs: [barcode],
  );
}

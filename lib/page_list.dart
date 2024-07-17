import 'dart:io';

import 'package:barcode_scanner/home.dart';
import 'package:barcode_scanner/page_camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'appbar_component_widget.dart';
import 'package:barcode_scanner/db_operator.dart';
import 'package:barcode_scanner/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path/path.dart' as path;

// ignore: must_be_immutable
class PageList extends ConsumerWidget {
  PageList({super.key});

  // AppBar
  final appBar = const AppBarComponentWidget();
  bool _initialized = false;

  // ◆初期化処理をしたい
  Future initialize(WidgetRef ref) async {
    // ref.read(Provider_progress.notifier).state = true;
    var products = await retrieveProducts();
    ref.read(Provider_Products_List.notifier).state = products;
    ref.read(Provider_progress.notifier).state = false;

    Set<String> localImagePaths = products
        .map<String>((product) => product['imageUrl'])
        .where((imageUrl) =>
            (!imageUrl.startsWith('http') && (imageUrl.isNotEmpty)))
        .toSet();

    for (String localpath in localImagePaths) {
      Set<FileSystemEntity> allFiles = {};

      File imageFile = File(localpath);

      if (await imageFile.exists()) {
        Directory directory = imageFile.parent;
        allFiles.addAll(directory.listSync());
      }

      // 取得したファイルの拡張子
      String fileExtension = path.extension(imageFile.path);

      for (FileSystemEntity file in allFiles) {
        if (file is File &&
            path.extension(file.path) == fileExtension &&
            !localImagePaths.contains(file.path)) {
          await file.delete();
          debugPrint('ファイルを削除しました: ${file.path}');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // メッセージ管理
    final l10n = L10n.of(context);

    // 商品情報リスト
    final productList = ref.watch(Provider_Products_List);

    // 進捗
    final progress = ref.watch(Provider_progress);

    if (_initialized == false) {
      initialize(ref);
      _initialized = true;
    }
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: appBar,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // タイトル
              Container(
                padding: const EdgeInsets.all(4),
                alignment: Alignment.center,
                child: Text(
                  l10n.itemList_title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, color: Colors.blue[800]),
                ),
              ),

              // ■並び替えラジオボタン
              // const Text('並び替えボタンを置くよ'),

              Flexible(
                // Expanded(
                child: ListView.builder(
                  itemCount: productList?.length ?? 0,
                  itemBuilder: (context, index) {
                    if (productList != null && index < productList.length) {
                      String subtext =
                          // productList[index]['barcode'] +
                          // '/' +
                          productList[index]['maker'] +
                              '/' +
                              // productList[index]['brandName'] +
                              // '/' +
                              productList[index]['country'] +
                              '/' +
                              productList[index]['capacity'] +
                              '/' +
                              productList[index]['store'];
                      // '/' +
                      // productList[index]['comment'];

                      return Dismissible(
                        key: UniqueKey(),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerLeft,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 20.0),
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) async {
                          // ◆削除を実行した際の処理
                          // ◆DBから削除
                          deleteProduct(productList[index]['code']);
                          // ◆リストを更新⇒DBから再取得しなくても、画面上は削除される
                          var products = await retrieveProducts();
                          ref.read(Provider_Products_List.notifier).state =
                              products;
                        },
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(l10n.itemList_delete_title),
                                content: Text(l10n.itemList_delete_message),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text(l10n.itemList_delete_btnYes),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text(l10n.itemList_delete_btnNo),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Card(
                          color: Colors.blue[100],
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.only(left: 8.0, right: 0.0),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        productList[index]['name'] ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(),
                                      ),
                                      ...List.generate(5, (i) {
                                        return Icon(
                                          Icons.favorite,
                                          size: 17,
                                          color:
                                              i < productList[index]['favorit']
                                                  ? Colors.pink
                                                  : Colors.grey,
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                                Text(
                                  productList[index]['code'] ?? '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              subtext,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                              // overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Container(
                              padding: EdgeInsets.all(0),
                              width: 40,
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                color: Colors.blue[900],
                                icon: const Icon(Icons.arrow_forward_ios),
                                onPressed: () {
                                  // ◆Riverpodで値を設定する(オブジェクトで持っちゃってるので詳細画面の作りも変える必要がある)
                                  // ◆詳細画面に遷移します
                                  final Map<String, dynamic> productInfo = {
                                    // 'product': {
                                    'code': productList[index]['code'],
                                    'name': productList[index]['name'],
                                    'maker': productList[index]['maker'],
                                    // 'brands': productList[index]['brandName'],
                                    'country': productList[index]['country'],
                                    'capacity': productList[index]['capacity'],
                                    'store': productList[index]['store'],
                                    'comment': productList[index]['comment'],
                                    'image_url': productList[index]['imageUrl'],
                                    'favorit': productList[index]['favorit'],
                                    // },
                                  };
                                  ref
                                      .read(Provider_Product_Info.notifier)
                                      .state = productInfo;

                                  pageDetail.initialized = false;
                                  Navigator.pushNamed(context, '/page_detail');
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return const Text('No Items');
                    }
                  },
                ),
              ),

              // 読み取り開始ボタン
              Container(
                margin: const EdgeInsets.all(8),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                      const Color.fromARGB(255, 244, 143, 177),
                    ),
                    minimumSize: WidgetStateProperty.all(
                        const Size(double.infinity, 55.0)),
                  ),
                  onPressed: () {
                    pageDetail.initialized = false;

                    Navigator.pushNamed(context, '/page_camera');
                  },
                  child: Text(
                    l10n.itemList_btnReadBarCode,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (progress)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

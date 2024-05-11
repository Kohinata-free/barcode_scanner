import 'package:barcode_scanner/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'appbar_component_widget.dart';
import 'package:barcode_scanner/db_operator.dart';

class PageList extends ConsumerWidget {
  const PageList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // AppBar
    final appBar = AppBarComponentWidget(
      title: '食品バーコードリーダー',
    );

    // 商品情報リスト
    final productList = ref.watch(Provider_Products_List);

    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: appBar,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          // タイトル
          Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.center,
            child: Text(
              '商品リスト',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
              ),
            ),
          ),

          // ■並び替えラジオボタン
          Text('並び替えボタンを置くよ'),

          // ■商品リスト
          Container(
            padding: EdgeInsets.all(8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4.0),
              ),
              onPressed: () async {
                var products = await retrieveProducts();
                ref.read(Provider_Products_List.notifier).state = products;
              },
              child: Text(
                '更　新',
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
            ),
          ),

          Flexible(
            child: ListView.builder(
              itemCount: productList?.length ?? 0,
              itemBuilder: (context, index) {
                if (productList != null && index < productList.length) {
                  String subtext = productList[index]['barcode'] +
                      '/' +
                      productList[index]['brandName'] +
                      '/' +
                      productList[index]['countryName'] +
                      '/' +
                      productList[index]['quantity'];
                  return Dismissible(
                    key: UniqueKey(),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 20.0),
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
                      deleteProduct(productList[index]['barcode']);
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
                            title: Text('Confirm'),
                            content: Text('Are you want to delete this item?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text('CANCEL'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text('DELETE'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Card(
                      color: Colors.blue[100],
                      child: ListTile(
                        title: Text(
                          productList[index]['productName'] ?? '',
                          style: TextStyle(fontSize: 20),
                        ),
                        subtitle: Text(
                          subtext,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                        trailing: Container(
                          width: 20,
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            color: Colors.black,
                            icon: Icon(Icons.arrow_forward_rounded),
                            onPressed: () {
                              // ◆Riverpodで値を設定する(オブジェクトで持っちゃってるので詳細画面の作りも変える必要がある)
                              // ◆詳細画面に遷移します
                              final Map<String, dynamic> productInfo = {
                                'product': {
                                  'code': productList[index]['barcode'],
                                  'product_name': productList[index]
                                      ['productName'],
                                  'brands': productList[index]['brandName'],
                                  'countries': productList[index]
                                      ['countryName'],
                                  'quantity': productList[index]['quantity'],
                                  'image_url': productList[index]['imageUrl'],
                                },
                              };
                              ref.read(Provider_Product_Info.notifier).state =
                                  productInfo;
                              Navigator.pushNamed(context, '/page_detail');
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Text('No Items');
                }
              },
            ),
          ),

          // 余白
          Expanded(child: Container()),

          // 読み取り開始ボタン
          Container(
            margin: EdgeInsets.all(8),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Color.fromARGB(255, 244, 143, 177),
                ),
                minimumSize:
                    MaterialStateProperty.all(Size(double.infinity, 60.0)),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/page_camera');
              },
              child: Text(
                '読み取り開始',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

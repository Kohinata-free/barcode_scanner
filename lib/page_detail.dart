import 'package:barcode_scanner/db_operator.dart';
import 'package:barcode_scanner/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barcode_scanner/appbar_component_widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> fetchProductInfo(String barcode) async {
  final String apiUrl =
      'https://world.openfoodfacts.org/api/v3/product/$barcode.json';

  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('APIリクエストの商品情報がありません：リターンコード=${response.statusCode}');
    }
  } catch (e) {
    print('APIリクエストに失敗しました：エラー情報=$e');
  }
  return null;
}

class PageDetail extends ConsumerWidget {
  // AppBar
  final appBar = AppBarComponentWidget(
    title: '食品バーコードリーダー',
  );
  @override
  Widget build(BuildContext context, ref) {
    // バーコード
    final scandata = ref.watch(Provider_Barcode_Info);
    // 商品情報
    final productInfo = ref.watch(Provider_Product_Info);

    String codeValue = scandata != null
        ? scandata.barcodes.first.rawValue
        : productInfo?['product']['code'] ?? '-----';

    // 商品情報のブランド
    String brandName = productInfo?['product']?['brands'] ?? '未登録';
    // 商品情報の商品名
    String productName = productInfo?['product']?['product_name'] ?? '未登録';
    // 商品情報の生産国
    String countryName = productInfo?['product']?['countries'] ?? '未登録';
    String imageUrl = productInfo?['product']?['image_url'] ?? '';
    // 商品情報の容量
    String quantity = productInfo?['product']?['quantity'] ?? '未登録';

    // ブランド名編集コントローラー
    TextEditingController _brandNameController =
        TextEditingController(text: '$brandName');
    // 商品名編集コントローラー
    TextEditingController _productNameController =
        TextEditingController(text: '$productName');
    // 生産国名編集コントローラー
    TextEditingController _countryNameController =
        TextEditingController(text: '$countryName');
    // 容量編集コントローラー
    TextEditingController _quantityController =
        TextEditingController(text: '$quantity');

    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: appBar,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(8),
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                child: Text(
                  '＜バーコード情報＞',
                  style: TextStyle(fontSize: 24, color: Colors.blue[800]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 50),
                child: Text(
                  '[コード値] ${codeValue}',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                height: 1,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey,
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 8),
                alignment: Alignment.center,
                child: Text(
                  '＜ーー食品情報ーー＞',
                  style: TextStyle(fontSize: 24, color: Colors.blue[800]),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[300],
                  ),
                  onPressed: () async {
                    // ◆バーコードからOpen Food Facts APIで情報を取得する
                    final Map<String, dynamic>? productInfo =
                        await fetchProductInfo('${codeValue}');

                    if (productInfo != null) {
                      // 商品名を取得
                      final String productName =
                          productInfo['product']['product_name'];
                      print('製品名=$productName');

                      // ◆続きはここから
                      ref.read(Provider_Product_Info.notifier).state =
                          productInfo;
                    }
                  },
                  child: Text(
                    '情報取得',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0, left: 50, right: 8),
                child: Row(
                  children: [
                    Text(
                      '[ブランド名] ',
                      style: TextStyle(fontSize: 18),
                    ),
                    Expanded(
                      child: TextField(
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        controller: _brandNameController,
                        onChanged: (newBrandName) {
                          brandName = newBrandName;
                        },
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.only(bottom: 0), // テキスト下部の余白を調整
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red, // フォーカス時のアンダーラインの色を設定
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0, left: 50, right: 8),
                child: Row(
                  children: [
                    Text(
                      '[商品名] ',
                      style: TextStyle(fontSize: 18),
                    ),
                    Expanded(
                      child: TextField(
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        controller: _productNameController,
                        onChanged: (newProductName) {
                          productName = newProductName;
                        },
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.only(bottom: 0), // テキスト下部の余白を調整
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red, // フォーカス時のアンダーラインの色を設定
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 50, right: 8),
                child: Row(
                  children: [
                    Text(
                      '[生産国] ',
                      style: TextStyle(fontSize: 18),
                    ),
                    Expanded(
                      child: TextField(
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        controller: _countryNameController,
                        onChanged: (newCountryName) {
                          countryName = newCountryName;
                        },
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.only(bottom: 0), // テキスト下部の余白を調整
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red, // フォーカス時のアンダーラインの色を設定
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 50, right: 8),
                child: Row(
                  children: [
                    Text(
                      '[容量] ',
                      style: TextStyle(fontSize: 18),
                    ),
                    Expanded(
                      child: TextField(
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        controller: _quantityController,
                        onChanged: (newQuantity) {
                          quantity = newQuantity;
                        },
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.only(bottom: 0), // テキスト下部の余白を調整
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red, // フォーカス時のアンダーラインの色を設定
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ◆URLがある場合のみ画像を表示するよう修正
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: (imageUrl != '')
                      ? Image.network(
                          imageUrl,
                          width: 130, // adjust the width as needed
                          height: 130, // adjust the height as needed
                          fit: BoxFit.cover, // adjust the fit as needed
                        )
                      : Text(
                          'No Image',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
              // Expanded(child: Container()),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size.fromHeight(60),
                          backgroundColor: Colors.amber[300],
                        ),
                        onPressed: () async {
                          if (productInfo != null) {
                            // 商品情報をSQLiteデータベースに保存
                            await insertProduct({
                              'barcode': codeValue,
                              'brandName': brandName,
                              'productName': productName,
                              'countryName': countryName,
                              'quantity': quantity,
                              'imageUrl': imageUrl,
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('商品情報を保存しました'),
                              ),
                            );
                          }
                        },
                        child: Text(
                          '保　存',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 26,
                          ),
                          // style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size.fromHeight(60),
                          backgroundColor: Colors.pink[200],
                        ),
                        onPressed: () {
                          ref.read(Provider_Barcode_Info.notifier).state = null;
                          ref.read(Provider_Product_Info.notifier).state = null;
                          Navigator.pushReplacementNamed(context, '/');
                        },
                        child: Text(
                          'ホーム',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 26,
                          ),
                          // style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

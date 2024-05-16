import 'dart:async';

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

// ignore: must_be_immutable
class PageDetail extends ConsumerWidget {
  PageDetail({super.key});

  // AppBar
  final appBar = AppBarComponentWidget(
    title: '食品バーコードリーダー',
  );

  // 初期化:TextEditingControllerのTextに随時値を設定すると、カーソルが先頭に移ってしまう為、更新したい場合のみ設定するためのフラグを用意し、他画面からもフラグを設定できるようにする
  bool initialized = false;
  String codeValue = '-----';
  // TextEditingControllerのTextに設定する変数
  String _brandName = '未登録';
  String _productName = '未登録';
  String _countryName = '未登録';
  String _imageUrl = '';
  String _quantity = '未登録';

  // TextEditingController:TextFieldに初期値を与えるために使用
  late TextEditingController _brandNameController;
  late TextEditingController _productNameController;
  late TextEditingController _countryNameController;
  late TextEditingController _quantityController;

  @override
  Widget build(BuildContext context, ref) {
    // バーコード
    final scandata = ref.watch(Provider_Barcode_Info);
    // 商品情報
    final productInfo = ref.watch(Provider_Product_Info);

    String _codeValue = scandata != null
        ? scandata.barcodes.first.rawValue
        : productInfo?['product']['code'] ?? '-----';

    // 商品情報のブランド
    if (!initialized) {
      _codeValue = scandata != null
          ? scandata.barcodes.first.rawValue
          : productInfo?['product']['code'] ?? '-----';
      _brandName = productInfo?['product']?['brands'] ?? '未登録';
      _brandNameController = TextEditingController(text: _brandName);
      _productName = productInfo?['product']?['product_name'] ?? '未登録';
      _productNameController = TextEditingController(text: _productName);
      _countryName = productInfo?['product']?['countries'] ?? '未登録';
      _countryNameController = TextEditingController(text: _countryName);
      _imageUrl = productInfo?['product']?['image_url'] ?? '';
      _quantity = productInfo?['product']?['quantity'] ?? '未登録';
      _quantityController = TextEditingController(text: _quantity);
      initialized = true;
    }

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
                  '[コード値] ${_codeValue}',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                height: 1,
                decoration: const BoxDecoration(
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
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4.0),
                  ),
                  onPressed: () async {
                    // ◆バーコードからOpen Food Facts APIで情報を取得する
                    final Map<String, dynamic>? productInfo =
                        await fetchProductInfo('${_codeValue}');

                    if (productInfo != null) {
                      // 商品名を取得
                      final String productName =
                          productInfo['product']['product_name'];
                      print('製品名=$productName');

                      // ◆続きはここから
                      ref.read(Provider_Product_Info.notifier).state =
                          productInfo;
                      initialized = false;
                    }
                  },
                  child: const Text(
                    'ネットから情報とるよ',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0, left: 50, right: 8),
                child: Row(
                  children: [
                    const Text(
                      '[ブランド名] ',
                      style: TextStyle(fontSize: 18),
                    ),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                        controller: _brandNameController,
                        onChanged: (newBrandName) {
                          _brandName = newBrandName;
                          productInfo?['product']?['brands'] = newBrandName;
                        },
                        decoration: const InputDecoration(
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
                    const Text(
                      '[商品名] ',
                      style: TextStyle(fontSize: 18),
                    ),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                        controller: _productNameController,
                        onChanged: (newProductName) {
                          _productName = newProductName;
                          productInfo?['product']?['product_name'] =
                              newProductName;
                        },
                        decoration: const InputDecoration(
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
                    const Text(
                      '[生産国] ',
                      style: TextStyle(fontSize: 18),
                    ),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                        controller: _countryNameController,
                        onChanged: (newCountryName) {
                          _countryName = newCountryName;
                          productInfo?['product']?['countries'] =
                              newCountryName;
                        },
                        decoration: const InputDecoration(
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
                    const Text(
                      '[容量] ',
                      style: TextStyle(fontSize: 18),
                    ),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                        controller: _quantityController,
                        onChanged: (newQuantity) {
                          _quantity = newQuantity;
                          productInfo?['product']?['quantity'] = newQuantity;
                        },
                        decoration: const InputDecoration(
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
                  child: (_imageUrl != '')
                      ? Image.network(
                          _imageUrl,
                          width: 130, // adjust the width as needed
                          height: 130, // adjust the height as needed
                          fit: BoxFit.cover, // adjust the fit as needed
                        )
                      : const Text(
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
                          fixedSize: const Size.fromHeight(60),
                          backgroundColor: Colors.amber[300],
                        ),
                        onPressed: () async {
                          if (productInfo != null) {
                            // 商品情報をSQLiteデータベースに保存
                            await insertProduct({
                              'barcode': _codeValue,
                              'brandName': _brandName,
                              'productName': _productName,
                              'countryName': _countryName,
                              'quantity': _quantity,
                              'imageUrl': _imageUrl,
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('商品情報を保存しました'),
                              ),
                            );
                          }
                          ref.read(Provider_progress.notifier).state = true;
                          var products = await retrieveProducts();
                          ref.read(Provider_Products_List.notifier).state =
                              products;
                          ref.read(Provider_progress.notifier).state = false;
                        },
                        child: const Text(
                          '保存するよ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size.fromHeight(60),
                          backgroundColor: Colors.pink[200],
                        ),
                        onPressed: () {
                          ref.read(Provider_Barcode_Info.notifier).state = null;
                          ref.read(Provider_Product_Info.notifier).state = null;
                          Navigator.pushReplacementNamed(context, '/');
                        },
                        child: const Text(
                          '一覧に戻る',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                          ),
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

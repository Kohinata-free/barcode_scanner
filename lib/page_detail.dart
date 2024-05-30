import 'dart:async';
import 'dart:io';

import 'package:barcode_scanner/db_operator.dart';
import 'package:barcode_scanner/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barcode_scanner/appbar_component_widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

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
  final appBar = AppBarComponentWidget();

  // 初期化:TextEditingControllerのTextに随時値を設定すると、カーソルが先頭に移ってしまう為、更新したい場合のみ設定するためのフラグを用意し、他画面からもフラグを設定できるようにする
  bool initialized = false;
  String codeValue = '-----';
  // TextEditingControllerのTextに設定する変数
  String _productName = '未登録';
  String _makerName = '未登録';
  String _brandName = '未登録';
  String _countryName = '未登録';
  String _imageUrl = '';
  String _quantity = '未登録';
  String _storeName = '';
  String _comment = '未登録';
  int _favorit = 1;

  // TextEditingController:TextFieldに初期値を与えるために使用
  late TextEditingController _productNameController;
  late TextEditingController _makerNameController;
  // late TextEditingController _brandNameController;
  late TextEditingController _countryNameController;
  late TextEditingController _quantityController;
  late TextEditingController _storeNameController;
  late TextEditingController _commentController;

  @override
  Widget build(BuildContext context, ref) {
    // バーコード
    final scandata = ref.watch(Provider_Barcode_Info);
    // 商品情報
    final productInfo = ref.watch(Provider_Product_Info);
    // 更新
    final update = ref.watch(Provider_detail_item_update);

    // メッセージ管理
    final l10n = L10n.of(context);

    // カメラコントローラ
    final imagePicker = ImagePicker();

    String _codeValue = scandata != null
        ? scandata.barcodes.first.rawValue
        : productInfo?['product']['code'] ?? '-----';

    // 商品情報のブランド
    if (!initialized) {
      _codeValue = scandata != null
          ? scandata.barcodes.first.rawValue
          : productInfo?['product']['code'] ?? '-----';
      _brandName = productInfo?['product']?['brands'] ?? '未登録';
      // _brandNameController = TextEditingController(text: _brandName);
      _makerName = productInfo?['product']?['maker'] ?? '未登録';
      _makerNameController = TextEditingController(text: _makerName);
      _productName = productInfo?['product']?['product_name'] ?? '未登録';
      _productNameController = TextEditingController(text: _productName);
      _countryName = productInfo?['product']?['countries'] ?? '未登録';
      _countryNameController = TextEditingController(text: _countryName);
      _imageUrl = productInfo?['product']?['image_url'] ?? '';
      _quantity = productInfo?['product']?['quantity'] ?? '未登録';
      _quantityController = TextEditingController(text: _quantity);
      _storeName = productInfo?['product']?['storeName'] ?? '';
      _storeNameController = TextEditingController(text: _storeName);
      _comment = productInfo?['product']?['comment'] ?? '未登録';
      _commentController = TextEditingController(text: _comment);
      _favorit = productInfo?['product']?['favorit'] ?? 1;
      initialized = true;
    }

    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: appBar,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                child: Text(
                  '＜情 報＞',
                  style: TextStyle(fontSize: 24, color: Colors.blue[800]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0, left: 20),
                child: Row(
                  children: [
                    Text(
                      '[バーコード値] $_codeValue',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
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
                              await fetchProductInfo('$_codeValue');

                          if (productInfo != null) {
                            ref.read(Provider_Product_Info.notifier).state =
                                productInfo;
                            initialized = false;
                          }
                        },
                        child: Text(
                          l10n.itemDetail_getInfo,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 8,
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
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 20, right: 8),
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
                        inputFormatters: [
                          // 最大15文字まで
                          LengthLimitingTextInputFormatter(15),
                        ],
                        decoration: const InputDecoration(
                          hintText: '例)チキチキボーン(骨なし)',
                          isDense: true,
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
                padding: const EdgeInsets.only(top: 8, left: 20, right: 8),
                child: Row(
                  children: [
                    const Text(
                      '[メーカー] ',
                      style: TextStyle(fontSize: 18),
                    ),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                        controller: _makerNameController,
                        onChanged: (newMakerName) {
                          _makerName = newMakerName;
                          productInfo?['product']?['maker'] = newMakerName;
                        },
                        inputFormatters: [
                          // 最大15文字まで
                          LengthLimitingTextInputFormatter(15),
                        ],
                        decoration: const InputDecoration(
                          hintText: '例)日本ハム',
                          isDense: true,
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
                padding: const EdgeInsets.only(top: 8, left: 20, right: 8),
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
                        inputFormatters: [
                          // 最大15文字まで
                          LengthLimitingTextInputFormatter(15),
                        ],
                        decoration: const InputDecoration(
                          hintText: '例)日本',
                          isDense: true,
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
                padding: const EdgeInsets.only(top: 8, left: 20, right: 8),
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
                        inputFormatters: [
                          // 最大15文字まで
                          LengthLimitingTextInputFormatter(15),
                        ],
                        decoration: const InputDecoration(
                          hintText: '例)174 g',
                          isDense: true,
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
                padding: const EdgeInsets.only(top: 8, left: 20, right: 8),
                child: Row(
                  children: [
                    const Text(
                      '[お店] ',
                      style: TextStyle(fontSize: 18),
                    ),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                        controller: _storeNameController,
                        onChanged: (newStoreName) {
                          _storeName = newStoreName;
                          productInfo?['product']?['storeName'] = newStoreName;
                        },
                        inputFormatters: [
                          // 最大15文字まで
                          LengthLimitingTextInputFormatter(15),
                        ],
                        decoration: const InputDecoration(
                          hintText: '例)生鮮市場TOP',
                          isDense: true,
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
                padding: EdgeInsets.only(top: 0, left: 20, right: 8, bottom: 0),
                child: Row(
                  children: [
                    const Text(
                      '[コメント] ',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(
                      width: 42,
                      height: 42,
                      child: IconButton(
                        padding: const EdgeInsets.all(0),
                        // constraints: const BoxConstraints(), // デフォルトの制約を削除
                        onPressed: () {
                          if (_favorit < 5) {
                            _favorit = _favorit + 1;
                            productInfo?['product']?['favorit'] = _favorit;
                            ref
                                .read(Provider_detail_item_update.notifier)
                                .state = !update;
                          }
                        },
                        icon: const Icon(Icons.thumb_up),
                        color: Colors.blue,
                      ),
                    ),
                    ...List.generate(5, (index) {
                      return Icon(
                        Icons.favorite,
                        color: index < _favorit ? Colors.pink : Colors.grey,
                      );
                    }),
                    SizedBox(
                      width: 42,
                      height: 42,
                      child: IconButton(
                        padding: const EdgeInsets.all(0),
                        onPressed: () {
                          if (_favorit > 0) {
                            _favorit = _favorit - 1;
                            productInfo?['product']?['favorit'] = _favorit;
                            ref
                                .read(Provider_detail_item_update.notifier)
                                .state = !update;
                          }
                        },
                        icon: const Icon(Icons.thumb_down),
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0, left: 20, right: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                        controller: _commentController,
                        maxLines: 3,
                        inputFormatters: [
                          // 最大50文字まで
                          LengthLimitingTextInputFormatter(50),
                        ],
                        onChanged: (newComment) {
                          _comment = newComment;
                          productInfo?['product']?['comment'] = newComment;
                        },
                        decoration: const InputDecoration(
                          hintText: '例)鶏むね肉にスパイシーな衣をつけて、植物油でカラッと揚げました。',
                          isDense: true,
                          contentPadding: EdgeInsets.all(4.0), // テキスト下部の余白を調整
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red, // フォーカス時のアンダーラインの色を設定
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                            ),
                          ),
                          filled: true,
                          fillColor: Color.fromARGB(255, 180, 230, 250),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ◆URLがある場合のみ画像を表示するよう修正
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: (_imageUrl.isNotEmpty)
                          ? (_imageUrl.startsWith('http')
                              ? Image.network(
                                  _imageUrl,
                                  width: 130, // adjust the width as needed
                                  height: 130, // adjust the height as needed
                                  fit: BoxFit.cover, // adjust the fit as needed
                                )
                              : Image.file(
                                  File(_imageUrl),
                                  width: 130, // adjust the width as needed
                                  height: 130, // adjust the height as needed
                                  fit: BoxFit.cover, // adjust the fit as needed
                                ))
                          : const Text(
                              'No Image',
                              style: TextStyle(fontSize: 20),
                            ),
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () async {
                        final imageFilePath = await imagePicker.pickImage(
                            source: ImageSource.camera);
                        if (imageFilePath == null) return;

                        final imagePath = File(imageFilePath.path);

                        _imageUrl = imagePath.path;
                        productInfo?['product']?['image_url'] = _imageUrl;

                        ref.read(Provider_detail_item_update.notifier).state =
                            !update;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4.0,
                        ),
                      ),
                      child: const Text(
                        'カメラで撮影',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size.fromHeight(50),
                          backgroundColor: Colors.amber[300],
                        ),
                        onPressed: () async {
                          try {
                            // if (productInfo != null) {
                            // 商品情報をSQLiteデータベースに保存
                            bool result = await insertProduct({
                              'barcode': _codeValue,
                              'productName': _productName,
                              'makerName': _makerName,
                              'brandName': _brandName,
                              'countryName': _countryName,
                              'quantity': _quantity,
                              'storeName': _storeName,
                              'comment': _comment,
                              'imageUrl': _imageUrl,
                              'favorit': _favorit,
                            });
                            if (result) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('商品情報を保存しました'),
                                ),
                              );
                              // }
                              ref.read(Provider_progress.notifier).state = true;
                              var products = await retrieveProducts();
                              ref.read(Provider_Products_List.notifier).state =
                                  products;
                              ref.read(Provider_progress.notifier).state =
                                  false;
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('商品情報の保存は100件まです'),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('商品情報の保存に失敗しました'),
                              ),
                            );
                          }
                        },
                        child: Text(
                          l10n.itemDetail_btnSave,
                          style: const TextStyle(
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
                          fixedSize: const Size.fromHeight(50),
                          backgroundColor: Colors.pink[200],
                        ),
                        onPressed: () {
                          ref.read(Provider_Barcode_Info.notifier).state = null;
                          ref.read(Provider_Product_Info.notifier).state = null;
                          Navigator.pushReplacementNamed(context, '/');
                        },
                        child: Text(
                          l10n.itemDetail_btnReturn,
                          style: const TextStyle(
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

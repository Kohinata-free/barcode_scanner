import 'dart:async';
import 'dart:io';

import 'package:barcode_scanner/db_operator.dart';
import 'package:barcode_scanner/home.dart';
import 'package:camera/camera.dart';
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
  String _productName = '';
  String _makerName = '';
  // String _brandName = '';
  String _countryName = '';
  String _imageUrl = '';
  String _quantity = '';
  String _storeName = '';
  String _comment = '';
  int _favorit = 1;

  // TextEditingController:TextFieldに初期値を与えるために使用
  late TextEditingController _productNameController;
  late TextEditingController _makerNameController;
  // late TextEditingController _brandNameController;
  late TextEditingController _countryNameController;
  late TextEditingController _quantityController;
  late TextEditingController _storeNameController;
  late TextEditingController _commentController;

  // カメラコントローラ
  // var imagePicker = ImagePicker();
  CameraController? _cameraController;
  XFile? _imageFile;
  late List<CameraDescription> cameras;

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.high,
    );

    await _cameraController?.initialize();
  }

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

    debugPrint("🔸page_detail->build()");

    // カメラコントローラ
    // final imagePicker = ImagePicker();

    // String codeValue = scandata != null
    //     ? scandata.barcodes.first.rawValue
    //     : productInfo?['product']['code'] ?? '-----';

    // 商品情報のブランド
    if (!initialized) {
      codeValue = scandata != null
          ? scandata.barcodes.first.rawValue
          : productInfo?['product']['code'] ?? '-----';
      //   _brandName = productInfo?['product']?['brands'] ?? '未登録';
      //   // _brandNameController = TextEditingController(text: _brandName);
      _makerName = productInfo?['product']?['maker'] ?? '';
      _makerNameController = TextEditingController(text: _makerName);
      _productName = productInfo?['product']?['product_name'] ?? '';
      _productNameController = TextEditingController(text: _productName);
      _countryName = productInfo?['product']?['countries'] ?? '';
      _countryNameController = TextEditingController(text: _countryName);
      _imageUrl = productInfo?['product']?['image_url'] ?? '';
      _quantity = productInfo?['product']?['quantity'] ?? '';
      _quantityController = TextEditingController(text: _quantity);
      _storeName = productInfo?['product']?['storeName'] ?? '';
      _storeNameController = TextEditingController(text: _storeName);
      _comment = productInfo?['product']?['comment'] ?? '';
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
                  l10n.itemDetail_title,
                  style: TextStyle(fontSize: 24, color: Colors.blue[800]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0, left: 20),
                child: Row(
                  children: [
                    Text(
                      '${l10n.itemDetail_category_barcode}  $codeValue',
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
                              await fetchProductInfo(codeValue);

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
              const Divider(
                // height: 10,
                thickness: 2,
                indent: 20,
                endIndent: 8,
                color: Colors.blue,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 20, right: 8),
                child: Row(
                  children: [
                    Text(
                      '${l10n.itemDetail_category_name} ',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                        controller: _productNameController,
                        onChanged: (newProductName) {
                          _productName = newProductName;
                          // productInfo?['product']?['product_name'] =
                          //     newProductName;
                        },
                        inputFormatters: [
                          // 最大15文字まで
                          LengthLimitingTextInputFormatter(15),
                        ],
                        decoration: const InputDecoration(
                          // hintText: l10n.itemDetail_hint_name,
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
                    Text(
                      '${l10n.itemDetail_category_maker} ',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                        controller: _makerNameController,
                        onChanged: (newMakerName) {
                          _makerName = newMakerName;
                          // productInfo?['product']?['maker'] = newMakerName;
                        },
                        inputFormatters: [
                          // 最大15文字まで
                          LengthLimitingTextInputFormatter(15),
                        ],
                        decoration: const InputDecoration(
                          // hintText: l10n.itemDetail_hint_maker,
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
                    Text(
                      '${l10n.itemDetail_category_country} ',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                        controller: _countryNameController,
                        onChanged: (newCountryName) {
                          _countryName = newCountryName;
                          //   productInfo?['product']?['countries'] =
                          //       newCountryName;
                        },
                        inputFormatters: [
                          // 最大15文字まで
                          LengthLimitingTextInputFormatter(15),
                        ],
                        decoration: const InputDecoration(
                          // hintText: l10n.itemDetail_hint_country,
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
                    Text(
                      '${l10n.itemDetail_category_capacity} ',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                        controller: _quantityController,
                        onChanged: (newQuantity) {
                          _quantity = newQuantity;
                          // productInfo?['product']?['quantity'] = newQuantity;
                        },
                        inputFormatters: [
                          // 最大15文字まで
                          LengthLimitingTextInputFormatter(15),
                        ],
                        decoration: const InputDecoration(
                          // hintText: l10n.itemDetail_hint_capacity,
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
                    Text(
                      '${l10n.itemDetail_category_store} ',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                        controller: _storeNameController,
                        onChanged: (newStoreName) {
                          _storeName = newStoreName;
                          // productInfo?['product']?['storeName'] = newStoreName;
                        },
                        inputFormatters: [
                          // 最大15文字まで
                          LengthLimitingTextInputFormatter(15),
                        ],
                        decoration: const InputDecoration(
                          // hintText: l10n.itemDetail_hint_store,
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
                padding: const EdgeInsets.only(
                    top: 0, left: 20, right: 8, bottom: 0),
                child: Row(
                  children: [
                    Text(
                      '${l10n.itemDetail_category_comment} ',
                      style: const TextStyle(fontSize: 18),
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
                          // productInfo?['product']?['comment'] = newComment;
                        },
                        decoration: const InputDecoration(
                          // hintText: l10n.itemDetail_hint_comment,
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
                      child: (_cameraController != null &&
                              _cameraController!.value.isInitialized)
                          // ? const Text('画像プレビュー')
                          ? Container(
                              width: 136,
                              height: 136,
                              child: AspectRatio(
                                aspectRatio:
                                    _cameraController!.value.aspectRatio,
                                child: CameraPreview(_cameraController!),
                              ),
                            )
                          : (_imageUrl.isNotEmpty)
                              ? (_imageUrl.startsWith('http')
                                  ? Image.network(
                                      _imageUrl,
                                      width: 136, // adjust the width as needed
                                      height:
                                          136, // adjust the height as needed
                                      fit: BoxFit
                                          .cover, // adjust the fit as needed
                                    )
                                  : Image.file(
                                      File(_imageUrl),
                                      width: 136, // adjust the width as needed
                                      height:
                                          136, // adjust the height as needed
                                      fit: BoxFit
                                          .cover, // adjust the fit as needed
                                    ))
                              : const Text(
                                  'No Image',
                                  style: TextStyle(fontSize: 20),
                                ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8.0),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if (_cameraController == null) {
                              await _initializeCamera();
                              ref
                                  .read(Provider_detail_item_update.notifier)
                                  .state = !update;
                            } else {
                              if (!_cameraController!.value.isInitialized) {
                                return;
                              }
                              try {
                                XFile picture =
                                    await _cameraController!.takePicture();
                                _imageFile = picture;
                              } catch (e) {
                                print(e);
                              }
                              if (_imageFile != null) {
                                _imageUrl = _imageFile!.path;
                                // productInfo?['product']?['image_url'] = _imageUrl;
                              }
                              await _cameraController?.dispose();
                              _cameraController = null;
                              ref
                                  .read(Provider_detail_item_update.notifier)
                                  .state = !update;
                            }
                          },
                          // onPressed: () async {
                          //   // カメラコントローラ
                          //   var imagePicker = ImagePicker();

                          //   final imageFilePath = await imagePicker.pickImage(
                          //       source: ImageSource.camera);
                          //   if (imageFilePath == null) return;

                          //   final imagePath = File(imageFilePath.path);

                          //   _imageUrl = imagePath.path;
                          //   // productInfo?['product']?['image_url'] = _imageUrl;

                          //   ref.read(Provider_detail_item_update.notifier).state =
                          //       !update;
                          // },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4.0,
                            ),
                          ),
                          child: Text(
                            (_cameraController == null)
                                ? l10n.itemDetail_btnPhoto
                                : '押してください',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (_cameraController != null) {
                              await _cameraController?.dispose();
                              _cameraController = null;
                            }
                            ref
                                .read(Provider_detail_item_update.notifier)
                                .state = !update;
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4.0,
                            ),
                          ),
                          child: Text(
                            // l10n.itemDetail_btnPhoto,
                            'キャンセル',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
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
                              'barcode': codeValue,
                              'productName': _productName,
                              'makerName': _makerName,
                              // 'brandName': _brandName,
                              'countryName': _countryName,
                              'quantity': _quantity,
                              'storeName': _storeName,
                              'comment': _comment,
                              'imageUrl': _imageUrl,
                              'favorit': _favorit,
                            });
                            if (result) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.itemDetail_snacker_save),
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
                                SnackBar(
                                  content:
                                      Text(l10n.itemDetail_snacker_save_limit),
                                ),
                              );
                            }
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text(l10n.itemDetail_snacker_save_error),
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

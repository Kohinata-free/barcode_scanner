import 'dart:async';
import 'dart:io';

import 'package:barcode_scanner/db_operator.dart';
import 'package:barcode_scanner/home.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barcode_scanner/appbar_component_widget.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Future<Map<String, dynamic>?> fetchProductInfo(String barcode) async {
//   final String apiUrl =
//       'https://world.openfoodfacts.org/api/v3/product/$barcode.json';

//   try {
//     final response = await http.get(Uri.parse(apiUrl));

//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       print('APIリクエストの商品情報がありません：リターンコード=${response.statusCode}');
//     }
//   } catch (e) {
//     print('APIリクエストに失敗しました：エラー情報=$e');
//   }
//   return null;
// }

///画面上にローディングアニメーションを表示する
void dispProgressIndicator(BuildContext context) {
  // Show the loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                backgroundColor: Colors.grey[200],
                strokeWidth: 6,
              ),
              SizedBox(width: 20),
              Text('Loading...'),
            ],
          ),
        ),
      );
    },
  );
}

///画面上にローディングアニメーションを非表示する
void hideProgressIndicator(BuildContext context) {
  Navigator.pop(context);
}

// firebaseのデータベースからバーコード値を指定して1件取得する
Future<Map<String, dynamic>?> fetchFirebaseData(
    BuildContext context, String code) async {
  Map<String, dynamic>? data;
  final docRef = FirebaseFirestore.instance.collection('items').doc(code);

  try {
    await docRef.get().then((DocumentSnapshot doc) {
      if (doc.exists) {
        data = doc.data() as Map<String, dynamic>;
      }
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('firebase_error'),
      ),
    );
  }

  return data;
}

// ignore: must_be_immutable
class PageDetail extends ConsumerWidget {
  PageDetail({super.key});

  // AppBar
  final appBar = const AppBarComponentWidget();

  // 初期化:TextEditingControllerのTextに随時値を設定すると、カーソルが先頭に移ってしまう為、更新したい場合のみ設定するためのフラグを用意し、他画面からもフラグを設定できるようにする
  bool initialized = false;
  String codeValue = '-----';
  // TextEditingControllerのTextに設定する変数
  String _name = '';
  String _maker = '';
  // String _brandName = '';
  String _country = '';
  String _imageUrl = '';
  String _capacity = '';
  String _store = '';
  String _comment = '';
  int _favorit = 1;

  // TextEditingController:TextFieldに初期値を与えるために使用
  late TextEditingController _nameController;
  late TextEditingController _makerController;
  // late TextEditingController _brandNameController;
  late TextEditingController _countryController;
  late TextEditingController _capacityController;
  late TextEditingController _storeController;
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

    // カメラコントローラ
    // final imagePicker = ImagePicker();

    // String codeValue = scandata != null
    //     ? scandata.barcodes.first.rawValue
    //     : productInfo?['product']['code'] ?? '-----';

    // 商品情報のブランド
    if (!initialized) {
      codeValue = scandata != null
          ? scandata.barcodes.first.rawValue
          : productInfo?['code'] ?? '-----';
      //   _brandName = productInfo?['product']?['brands'] ?? '未登録';
      //   // _brandNameController = TextEditingController(text: _brandName);
      _maker = productInfo?['maker'] ?? '';
      _makerController = TextEditingController(text: _maker);
      _name = productInfo?['name'] ?? '';
      _nameController = TextEditingController(text: _name);
      _country = productInfo?['country'] ?? '';
      _countryController = TextEditingController(text: _country);
      _imageUrl = productInfo?['image_url'] ?? '';
      _capacity = productInfo?['capacity'] ?? '';
      _capacityController = TextEditingController(text: _capacity);
      _store = productInfo?['store'] ?? '';
      _storeController = TextEditingController(text: _store);
      _comment = productInfo?['comment'] ?? '';
      _commentController = TextEditingController(text: _comment);
      _favorit = productInfo?['favorit'] ?? 3;
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
                          // firebaseから商品情報を取得
                          final tmpProductInfo =
                              await fetchFirebaseData(context, codeValue);
                          // ◆バーコードからOpen Food Facts APIで情報を取得する
                          // final Map<String, dynamic>? productInfo =
                          //     await fetchProductInfo(codeValue);

                          if (tmpProductInfo != null) {
                            ref.read(Provider_Product_Info.notifier).state =
                                tmpProductInfo;
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
                        controller: _nameController,
                        onChanged: (newName) {
                          _name = newName;
                        },
                        inputFormatters: [
                          // 最大15文字まで
                          LengthLimitingTextInputFormatter(15),
                        ],
                        decoration: const InputDecoration(
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
                        controller: _makerController,
                        onChanged: (newMaker) {
                          _maker = newMaker;
                        },
                        inputFormatters: [
                          // 最大15文字まで
                          LengthLimitingTextInputFormatter(15),
                        ],
                        decoration: const InputDecoration(
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
                        controller: _countryController,
                        onChanged: (newCountry) {
                          _country = newCountry;
                        },
                        inputFormatters: [
                          // 最大15文字まで
                          LengthLimitingTextInputFormatter(15),
                        ],
                        decoration: const InputDecoration(
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
                        controller: _capacityController,
                        onChanged: (newCapacity) {
                          _capacity = newCapacity;
                        },
                        inputFormatters: [
                          // 最大15文字まで
                          LengthLimitingTextInputFormatter(15),
                        ],
                        decoration: const InputDecoration(
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
                        controller: _storeController,
                        onChanged: (newStore) {
                          _store = newStore;
                        },
                        inputFormatters: [
                          // 最大15文字まで
                          LengthLimitingTextInputFormatter(15),
                        ],
                        decoration: const InputDecoration(
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
                        onPressed: () {
                          if (_favorit < 5) {
                            _favorit = _favorit + 1;
                            productInfo?['favorit'] = _favorit;
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
                            productInfo?['favorit'] = _favorit;
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
                        },
                        decoration: const InputDecoration(
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
                          ? SizedBox(
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
                              : Image.asset(
                                  'assets/images/barcode_head_face.png',
                                  height: 136,
                                  width: 136,
                                  fit: BoxFit.cover,
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
                                // print(e);
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
                                : l10n.itemDetail_btnTap,
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
                            l10n.itemDetail_cancel,
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
                              'code': codeValue,
                              'name': _name,
                              'maker': _maker,
                              // 'brandName': _brandName,
                              'country': _country,
                              'capacity': _capacity,
                              'store': _store,
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

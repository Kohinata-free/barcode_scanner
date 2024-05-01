import 'package:barcode_scanner/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barcode_scanner/appbar_component_widget.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> fetchProductInfo(String barcode) async {
  final String apiUrl =
      'https://world.openfoodfacts.org/api/v3/product/$barcode.json';
  // final String apiUrl =
  //     'https://world.openfoodfacts.org/api/v3/product/737628064502.json';

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

    // コードから読み取った文字列
    String codeValue = scandata?.barcodes.first.rawValue ?? 'null';
    // コードのタイプを示すオブジェクト
    BarcodeType? codeType = scandata?.barcodes.first.type;
    // コードのタイプを文字列にする
    String cardTitle = "[${'$codeType'.split('.').last}]";

    // 商品情報のブランド
    String brandName =
        productInfo != null ? productInfo['product']['brands'] : '';
    // 商品情報の商品名
    String productName =
        productInfo != null ? productInfo['product']['product_name'] : '';
    // 商品情報の生産国
    String countryName =
        productInfo != null ? productInfo['product']['countries'] : '';
    // 商品情報の画像URL
    String imageSmallUrl = productInfo != null
        ? productInfo['product']['image_front_small_url']
        : '';
    // 商品情報のサムネ画像URL
    String imageThumbUrl = productInfo != null
        ? productInfo['product']['image_front_thumb_url']
        : '';
    // 商品情報のサムネ画像URL
    String imageUrl =
        productInfo != null ? productInfo['product']['image_url'] : '';
    // 商品情報の容量
    String quantity =
        productInfo != null ? productInfo['product']['quantity'] : '';

    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: appBar,
      body: Container(
        padding: EdgeInsets.all(8),
        width: double.infinity,
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
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 50),
              child: Text(
                '[コードの種類] ${cardTitle}',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                vertical: 15,
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
              padding: const EdgeInsets.only(top: 8, left: 50),
              child: Text(
                '[ブランド名] ${brandName}',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 50),
              child: Text(
                '[商品名] ${productName}',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 50),
              child: Text(
                '[生産国] ${countryName}',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 50),
              child: Text(
                '[容量] ${quantity}',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 50),
              child: Image.network(
                imageUrl,
                width: 150, // adjust the width as needed
                height: 150, // adjust the height as needed
                fit: BoxFit.cover, // adjust the fit as needed
              ),
            ),
            Expanded(child: Container()),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[200],
                minimumSize: Size(double.infinity, 60.0),
              ),
              onPressed: () {
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
          ],
        ),
      ),
    );
  }
}

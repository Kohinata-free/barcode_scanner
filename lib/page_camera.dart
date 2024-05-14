import 'package:audioplayers/audioplayers.dart';
import 'package:barcode_scanner/db_operator.dart';
import 'package:barcode_scanner/page_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:barcode_scanner/home.dart';
import 'package:barcode_scanner/appbar_component_widget.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// 音源を再生します
Future<void> playSound(String source) async {
  AudioPlayer audioPlayer = AudioPlayer();
  await audioPlayer.play(AssetSource(source));
  // audioPlayer.dispose();
}

class PageCamera extends ConsumerWidget {
  // AppBar
  final appBar = AppBarComponentWidget(
    title: '食品バーコードリーダー',
  );
  // カメラがオンしているかどうか
  final bool isStarted = true;
  // ズームの程度。0から1まで。多いほど近い
  final double zoomFactor = 0.0;

  PageCamera({super.key});

  @override
  Widget build(BuildContext context, ref) {
    // スキャナーの作用を制御するコントローラーのオブジェクト
    MobileScannerController controller = MobileScannerController();
    // バーコード
    // final barcode = ref.watch(Provider_Barcode);
    return Scaffold(
      backgroundColor: Colors.blueGrey[100],
      appBar: appBar,
      body: Center(
        child: Column(
          children: [
            // タイトル
            Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.center,
              child: Text(
                '読み取り中・・・',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.width * 6 / 5,
              child: MobileScanner(
                controller: controller,
                fit: BoxFit.cover,
                // fit: BoxFit.contain,
                // QRコードかバーコードが見つかった後すぐ実行する関数
                onDetect: (scandata) async {
                  controller.stop(); // まずはカメラを止める
                  ref.read(Provider_Barcode_Info.notifier).state = scandata;
                  // 検知音を鳴らす
                  playSound('sounds/chimes.wav');

                  // ◆データベースに存在する場合、取得する
                  final Map<String, dynamic>? product =
                      await retrieveProductByBarcode(
                          scandata.barcodes.first.rawValue!);
                  if (product != null) {
                    final Map<String, dynamic> productInfo = {
                      'product': {
                        'code': product['barcode'],
                        'product_name': product['productName'],
                        'brands': product['brandName'],
                        'countries': product['countryName'],
                        'quantity': product['quantity'],
                        'image_url': product['imageUrl'],
                      },
                    };
                    ref.read(Provider_Product_Info.notifier).state =
                        productInfo;
                  } else {
                    // ◆バーコードからOpen Food Facts APIで情報を取得する
                    final Map<String, dynamic>? productInfo =
                        await fetchProductInfo(
                            scandata.barcodes.first.rawValue!);

                    if (productInfo != null) {
                      // 商品名を取得
                      final String productName =
                          productInfo['product']['product_name'];
                      print('製品名=$productName');

                      // ◆続きはここから
                      ref.read(Provider_Product_Info.notifier).state =
                          productInfo;
                    }
                  }

                  // 結果を表す画面に切り替える
                  Navigator.pushNamed(context, '/page_detail');
                },
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
                        backgroundColor: Colors.green[200],
                      ),
                      onPressed: () {
                        controller.stop(); // まずはカメラを止める
                        Navigator.pop(context);
                      },
                      child: Text(
                        '戻る',
                        style: TextStyle(color: Colors.black, fontSize: 26),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  // Expanded(
                  //   child: ElevatedButton(
                  //     style: ElevatedButton.styleFrom(
                  //       fixedSize: Size.fromHeight(60),
                  //       backgroundColor: Colors.amber[200],
                  //     ),
                  //     onPressed: () {
                  //       controller.stop(); // まずはカメラを止める
                  //       Navigator.pushNamed(context, '/page_detail');
                  //     },
                  //     child: Text(
                  //       '詳細',
                  //       style: TextStyle(color: Colors.black, fontSize: 26),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

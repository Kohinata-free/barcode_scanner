import 'package:audioplayers/audioplayers.dart';
import 'package:barcode_scanner/db_operator.dart';
import 'package:barcode_scanner/page_detail.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:barcode_scanner/home.dart';
import 'package:barcode_scanner/appbar_component_widget.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// 音源を再生します
Future<void> playSound(String source) async {
  AudioPlayer audioPlayer = AudioPlayer();
  audioPlayer.onPlayerComplete.listen((event) {
    audioPlayer.dispose();
  });
  await audioPlayer.play(AssetSource(source));
  // audioPlayer.dispose();
}

// ignore: must_be_immutable
class PageCamera extends ConsumerWidget {
  // AppBar
  final appBar = const AppBarComponentWidget();
  // カメラがオンしているかどうか
  final bool isStarted = true;
  // ズームの程度。0から1まで。多いほど近い
  final double zoomFactor = 0.0;
  // 2スキャン用のバーコード値
  String? _lastBarcode;
  // スキャナーの作用を制御するコントローラーのオブジェクト
  MobileScannerController controller = MobileScannerController();

  PageCamera({super.key});

  @override
  Widget build(BuildContext context, ref) {
    _lastBarcode = ref.watch(Provider_barcode);
    // メッセージ管理
    final l10n = L10n.of(context);

    return Scaffold(
      backgroundColor: Colors.blueGrey[100],
      appBar: appBar,
      body: Center(
        child: Column(
          children: [
            // タイトル
            Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/barcode_head.png',
                    height: 114 * 4 / 5,
                    width: 138 * 4 / 5,
                  ),
                  Text(
                    l10n.camera_message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.width * 17 / 18,
              child: MobileScanner(
                controller: controller,
                fit: BoxFit.cover,
                // QRコードかバーコードが見つかった後すぐ実行する関数
                onDetect: (scandata) async {
                  if (scandata.barcodes.first.rawValue != null) {
                    if (scandata.barcodes.first.rawValue!.startsWith('http')) {
                      return;
                    }
                  }
                  if (_lastBarcode != scandata.barcodes.first.rawValue) {
                    // debugPrint('スキャン1回目:$value');
                    ref.read(Provider_barcode.notifier).state =
                        scandata.barcodes.first.rawValue;
                  } else {
                    await controller.stop(); // まずはカメラを止める
                    controller.dispose();
                    // debugPrint('スキャン2回目:$value');
                    ref.read(Provider_Barcode_Info.notifier).state = scandata;
                    // 検知音を鳴らす
                    playSound('sounds/chimes.wav');

                    // ◆データベースに存在する場合、取得する
                    final Map<String, dynamic>? product =
                        await retrieveProductByBarcode(
                            scandata.barcodes.first.rawValue!);
                    if (product != null) {
                      final imageUrlFirebase = await FirebaseStorage.instance
                          .ref(product['imageUrl'])
                          .getDownloadURL();

                      final Map<String, dynamic> productInfo = {
                        'code': product['code'],
                        'name': product['name'],
                        'maker': product['maker'],
                        // 'brands': product['brand'],
                        'country': product['country'],
                        'capacity': product['capacity'],
                        'store': product['store'],
                        'comment': product['comment'],
                        'image_url': product['imageUrl'],
                        'favorit': product['favorit'],
                        'image_url_firebase': imageUrlFirebase,
                      };
                      ref.read(Provider_Product_Info.notifier).state =
                          productInfo;
                    } else {
                      dispProgressIndicator(context);
                      final Map<String, dynamic>? productInfo =
                          await fetchFirebaseData(
                              context, scandata.barcodes.first.rawValue!);
                      hideProgressIndicator(context);
                      if (productInfo != null) {
                        if (productInfo['image_url'] != null &&
                            productInfo['image_url'] != '') {
                          final imageUrlFirebase = await FirebaseStorage
                              .instance
                              .ref(productInfo['image_url'])
                              .getDownloadURL();
                          productInfo['image_url_firebase'] = imageUrlFirebase;
                        }
                        // 商品情報を更新
                        ref.read(Provider_Product_Info.notifier).state =
                            productInfo;
                      }
                    }

                    // 結果を表す画面に切り替える
                    Navigator.pushNamed(context, '/page_detail');
                  }
                },
              ),
            ),
            // Expanded(child: Container()),
            Container(
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size.fromHeight(55),
                        backgroundColor: Colors.green[200],
                      ),
                      onPressed: () async {
                        await controller.stop(); // まずはカメラを止める
                        controller.dispose();
                        ref.read(Provider_barcode.notifier).state = null;
                        Navigator.pop(context);
                      },
                      child: Text(
                        l10n.camera_btnCancel,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

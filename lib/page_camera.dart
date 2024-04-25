import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:barcode_scanner/home.dart';
import 'package:barcode_scanner/appbar_component_widget.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class PageCamera extends ConsumerWidget {
  // AppBar
  final appBar = AppBarComponentWidget(
    title: '食品バーコードリーダー',
  );
  // カメラがオンしているかどうか
  bool isStarted = true;
  // ズームの程度。0から1まで。多いほど近い
  double zoomFactor = 0.0;

  @override
  Widget build(BuildContext context, ref) {
    // スキャナーの作用を制御するコントローラーのオブジェクト
    MobileScannerController controller = MobileScannerController();
    // バーコード
    final barcode = ref.watch(Provider_Barcode);
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
              height: MediaQuery.of(context).size.width * 1.2,
              // width: MediaQuery.of(context).size.width * 1.2,
              child: MobileScanner(
                controller: controller,
                fit: BoxFit.contain,
                // QRコードかバーコードが見つかった後すぐ実行する関数
                onDetect: (scandata) {
                  controller.stop(); // まずはカメラを止める
                  ref.read(Provider_Barcode.notifier).state =
                      scandata.barcodes[0].toString();
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
                        Navigator.pop(context);
                      },
                      child: Text(
                        '戻る',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size.fromHeight(60),
                        backgroundColor: Colors.amber[200],
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/page_detail');
                      },
                      child: Text(
                        '詳細',
                        style: TextStyle(fontSize: 20),
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

import 'package:barcode_scanner/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barcode_scanner/appbar_component_widget.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class PageDetail extends ConsumerWidget {
  // AppBar
  final appBar = AppBarComponentWidget(
    title: '食品バーコードリーダー',
  );
  @override
  Widget build(BuildContext context, ref) {
    // バーコード
    final scandata = ref.watch(Provider_Barcode_Info);

    // コードから読み取った文字列
    String codeValue = scandata?.barcodes.first.rawValue ?? 'null';
    // コードのタイプを示すオブジェクト
    BarcodeType? codeType = scandata?.barcodes.first.type;
    // コードのタイプを文字列にする
    String cardTitle = "[${'$codeType'.split('.').last}]";

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
                },
                child: Text(
                  '情報取得',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            Expanded(child: Container()),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[200],
                minimumSize: Size(double.infinity, 60.0),
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
              child: Text(
                'ホーム',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PageList extends ConsumerWidget {
  const PageList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // AppBar
    final appBar = AppBar(
      backgroundColor: Colors.pink[200],
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0),
        child: Image.asset(
          'assets/images/TK-free_Circle.png',
          height: 40,
          width: 40,
        ),
      ),
      title: Text('食品バーコードリーダー'),
    );

    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: appBar,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // タイトル
          Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.center,
            child: Text(
              '商品リスト',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // ■並び替えラジオボタン
          Text('並び替えボタンを置くよ'),

          // ■商品リスト
          Text('商品リストを置くよ'),

          // 余白
          Expanded(child: Container()),

          // 読み取り開始ボタン
          Container(
            margin: EdgeInsets.all(8),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Color.fromARGB(255, 244, 143, 177),
                ),
                minimumSize:
                    MaterialStateProperty.all(Size(double.infinity, 60.0)),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/page_camera');
              },
              child: Text(
                '読み取り開始',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

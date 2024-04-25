import 'package:barcode_scanner/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barcode_scanner/appbar_component_widget.dart';

class PageDetail extends ConsumerWidget {
  // AppBar
  final appBar = AppBarComponentWidget(
    title: '食品バーコードリーダー',
  );
  @override
  Widget build(BuildContext context, ref) {
    // バーコード
    final barcode = ref.watch(Provider_Barcode);

    return Scaffold(
      appBar: appBar,
      body: Column(
        children: [
          Text('バーコード：${barcode}'),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[200],
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
            child: Text(
              'ホーム',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}

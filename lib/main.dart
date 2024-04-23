import 'package:barcode_scanner/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'page_camera.dart';
import 'page_detail.dart';

void main() {
  // 画面表示時、重くないように各画面を最初に生成しておく
  final home = Home();
  final pageCamera = PageCamera();
  final pageDetail = PageDetail();
  // final
  // アプリ
  final app = MaterialApp(
    // home: home,
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => home,
      '/page_camera': (context) => pageCamera,
      '/page_detail': (context) => pageDetail,
    },
  );

  final scopedApp = ProviderScope(child: app);

  runApp(scopedApp);
}

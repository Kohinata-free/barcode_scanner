import 'package:barcode_scanner/home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'page_camera.dart';
import 'page_detail.dart';

// initializeフラグを操作するために商品詳細画面をグローバル化
final pageDetail = PageDetail();

void main() {
  // ライセンス
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString(
      'assets/google_fonts/OFL.txt',
    );
    yield LicenseEntryWithLineBreaks(
      ['google_fonts'],
      license,
    );
  });
  // 画面表示時、重くないように各画面を最初に生成しておく
  final home = Home();
  final pageCamera = PageCamera();
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

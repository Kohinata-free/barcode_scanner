import 'package:barcode_scanner/home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'page_camera.dart';
import 'page_detail.dart';

// initializeフラグで商品詳細画面のTextFieldの更新を制御する
// initializeフラグを操作するために商品詳細画面をグローバル化
final pageDetail = PageDetail();

void main() {
  // google_fontsライセンス
  _registerLicenses();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// google_fontsライセンス
void _registerLicenses() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      initialRoute: '/',
      routes: {
        '/': (context) => Home(),
        '/page_camera': (context) => PageCamera(),
        '/page_detail': (context) => pageDetail,
      },
    );
  }
}

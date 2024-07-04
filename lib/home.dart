import 'package:barcode_scanner/page_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// バーコードの状態を共有する
final Provider_Barcode_Info = StateProvider<BarcodeCapture?>((ref) {
  return null;
});

// 最後に取得した商品情報を共有する
final Provider_Product_Info = StateProvider<Map<String, dynamic>?>((ref) {
  return null;
});

// 商品情報リストを共有する
final Provider_Products_List =
    StateProvider<List<Map<String, dynamic>>?>((ref) {
  return null;
});

// 進捗インジケーター
final Provider_progress = StateProvider((ref) {
  return false;
});

// 2スキャン一致バーコード値
final Provider_barcode = StateProvider<String?>((ref) {
  return null;
});

// 商品詳細画面更新プロバイダー
final Provider_detail_item_update = StateProvider((ref) {
  return false;
});

// 商品お気に入り数
final Provider_item_favorit = StateProvider((ref) {
  return 1;
});

class Home extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PageList();
  }
}

import 'package:barcode_scanner/page_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// バーコードの状態を共有する
final Provider_Barcode_Info = StateProvider<BarcodeCapture?>((ref) {
  return null;
});

class Home extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PageList();
  }
}

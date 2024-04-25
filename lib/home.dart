import 'package:barcode_scanner/page_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// バーコードの状態を共有する
final Provider_Barcode = StateProvider<String>((ref) {
  return "----------";
});

class Home extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PageList();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PageCamera extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('カメラ画面です'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
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
        ],
      ),
    );
  }
}

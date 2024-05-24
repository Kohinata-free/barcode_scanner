import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PageDetailItem extends StatelessWidget {
  const PageDetailItem(
      {super.key, required this.textEditingController, required this.itemName});

  final TextEditingController textEditingController;
  final String itemName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 20, right: 8),
      child: Row(
        children: [
          Text(
            itemName,
            style: const TextStyle(fontSize: 18),
          ),
          Expanded(
            child: TextField(
              style: const TextStyle(
                fontSize: 18,
              ),
              controller: textEditingController,
              onChanged: (newProductName) {
                // ◆将来対応(どうやってpage_detail.dartの持つ変数に反映するか？)
                // _productName = newProductName;
                // productInfo?['product']?['product_name'] = newProductName;
              },
              inputFormatters: [
                // 最大10文字まで
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.only(bottom: 0), // テキスト下部の余白を調整
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.red, // フォーカス時のアンダーラインの色を設定
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

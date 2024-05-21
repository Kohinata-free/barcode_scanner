import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppBarComponentWidget extends StatelessWidget
    implements PreferredSizeWidget {
  AppBarComponentWidget({super.key});
  // AppBarComponentWidget({required this.title, super.key});
  // final String title;

  @override
  Size get preferredSize {
    return const Size(double.infinity, 60.0);
  }

  @override
  Widget build(BuildContext context) {
    // メッセージ管理
    final l10n = L10n.of(context);

    return AppBar(
      backgroundColor: Colors.pink[200],
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 2.0),
        child: Image.asset(
          'assets/images/TK-free_Circle.png',
          height: 40,
          width: 40,
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(top: 0.0),
        child: Text(
          l10n.title_app,
          // title,
          style: GoogleFonts.hachiMaruPop(
            fontSize: 30,
          ),
        ),
      ),
      actions: [
        IconButton(
          padding: const EdgeInsets.only(top: 8),
          color: Colors.blue,
          iconSize: 30,
          alignment: Alignment.center,
          icon: const Icon(Icons.info_outline),
          onPressed: () {
            // ライセンス画面表示
            showLicensePage(context: context);
          },
        ),
      ],
    );
  }
}

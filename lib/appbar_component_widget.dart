import 'package:flutter/material.dart';

class AppBarComponentWidget extends StatelessWidget
    implements PreferredSizeWidget {
  AppBarComponentWidget({required this.title, super.key});
  final String title;

  @override
  Size get preferredSize {
    return Size(double.infinity, 60.0);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.pink[200],
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0),
        child: Image.asset(
          'assets/images/TK-free_Circle.png',
          height: 40,
          width: 40,
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Text(title),
      ),
    );
  }
}

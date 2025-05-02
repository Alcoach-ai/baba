import 'package:flutter/material.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBar appBar;
  final String title;
  const MainAppBar({super.key, required this.appBar, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue,
      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(
          color: Color(0xFFffffff),
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
          fontSize: 30,
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(50),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(appBar.preferredSize.height);
}

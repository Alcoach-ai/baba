import 'package:flutter/material.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBar appBar;
  final String title;
  final String? total;
  final Function()? showAddEdit;
  final bool? isHome;
  const MainAppBar(
      {super.key,
      required this.appBar,
      required this.title,
      this.showAddEdit,
      this.total,
      this.isHome});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: (isHome == true)
          ? Container()
          : BackButton(
              color: Colors.white,
            ),
      backgroundColor: Color.fromARGB(255, 165, 178, 214),
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
      actions: [
        if (total != null)
          Padding(
            padding: const EdgeInsets.only(right: 32.0),
            child: Text(
              total!,
              style: TextStyle(color: Color(0xFFffffff), fontSize: 20),
            ),
          ),
        (showAddEdit != null)
            ? Padding(
                padding: const EdgeInsets.only(right: 32.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 32,
                  ),
                  onTap: showAddEdit,
                ),
              )
            : Container(),
      ],
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

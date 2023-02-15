import 'package:flutter/material.dart';
import 'package:trus_app/colors.dart';

class AppBarHeadline extends StatelessWidget with PreferredSizeWidget {
  final String text;


  const AppBarHeadline({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(text),
      centerTitle: true,
      foregroundColor: blackColor,
      backgroundColor: Colors.white);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kMinInteractiveDimension);
}

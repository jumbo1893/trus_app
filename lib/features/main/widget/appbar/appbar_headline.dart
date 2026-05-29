import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';

class AppBarHeadline extends StatelessWidget implements PreferredSizeWidget {
  final String text;
  final VoidCallback? onBackButtonPressed;
  const AppBarHeadline({
    Key? key,
    required this.text,
    this.onBackButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: Text(text),
        centerTitle: true,
        leading: onBackButtonPressed != null ? IconButton(
          onPressed: () => onBackButtonPressed!(), icon: const Icon(Icons.arrow_back),): Container(),
        foregroundColor: context.appColors.textPrimary,
        backgroundColor: context.appColors.cardBackground);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kMinInteractiveDimension);
}

class Class{
  final Function function;
  Class({this.function = _defaultFunction});
  static _defaultFunction() {}
}


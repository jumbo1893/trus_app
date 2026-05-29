import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';

import '../custom_text_button.dart';


class ErrorDialog extends StatelessWidget {

  final String title;
  final String content;
  final VoidCallback continueCallBack;

  const ErrorDialog(this.title, this.content, this.continueCallBack, {super.key});
  TextStyle textStyle(BuildContext context) => TextStyle(color: context.appColors.textPrimary);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child:  AlertDialog(
          title: Text(title,style: textStyle(context),),
          content: Text(content, style: textStyle(context),),
          actions: [
            CustomTextButton(onPressed: () => Navigator.of(context).pop(), text:"Zavřít"),
            CustomTextButton(onPressed: () {continueCallBack.call(); Navigator.of(context).pop();}, text: "Návrat do hlavního menu")
          ],
        ));
  }
}
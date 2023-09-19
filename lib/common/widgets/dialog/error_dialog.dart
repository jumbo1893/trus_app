import 'dart:ui';
import 'package:flutter/material.dart';

import '../custom_text_button.dart';


class ErrorDialog extends StatelessWidget {

  final String title;
  final String content;
  final VoidCallback continueCallBack;

  const ErrorDialog(this.title, this.content, this.continueCallBack, {super.key});
  final TextStyle textStyle = const TextStyle (color: Colors.black);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child:  AlertDialog(
          title: Text(title,style: textStyle,),
          content: Text(content, style: textStyle,),
          actions: [
            CustomTextButton(onPressed: () => Navigator.of(context).pop(), text:"Zavřít"),
            CustomTextButton(onPressed: () {continueCallBack.call(); Navigator.of(context).pop();}, text: "Návrat do hlavního menu")
          ],
        ));
  }
}
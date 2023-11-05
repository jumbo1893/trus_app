import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../widgets/dialog/error_dialog.dart';

void showSnackBarWithPostFrame({required BuildContext context, required String content}) {
  SchedulerBinding.instance.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          content,
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black.withOpacity(0.5)));
  });
}

void showSnackBar({required BuildContext context, required String content}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          content,
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black.withOpacity(0.5)));
}

void showLoaderSnackBar({required BuildContext context}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: const [CircularProgressIndicator(),
          SizedBox(height: 10,),
          Text(
            "načítám",
            textAlign: TextAlign.center,
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.black.withOpacity(0.5)));
}

void hideSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
}

void showErrorDialog(String snapshotError, VoidCallback onDialogCancel, BuildContext context) {
  var dialog = ErrorDialog("Chyba!", snapshotError, () => onDialogCancel());
  showDialog(context: context, builder: (BuildContext context) => dialog);
}

String getValueFromValueKey(Key key) {
  return key.toString().substring(3, key.toString().length - 3);
}
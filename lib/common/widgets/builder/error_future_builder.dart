import 'package:flutter/material.dart';
import 'package:trus_app/common/widgets/error.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../../../colors.dart';
import '../../../features/general/error/api_executor.dart';
import '../dialog/error_dialog.dart';
import '../loader.dart';

class ErrorFutureBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final BuildContext context;
  final VoidCallback onDialogCancel;
  final Widget widget;
  const ErrorFutureBuilder({
    Key? key,
    required this.future,
    required this.context,
    required this.onDialogCancel,
    required this.widget,
  }) : super(key: key);

  void showErrorDialog(String snapshotError) {
    var dialog = ErrorDialog("Chyba!", snapshotError, () => onDialogCancel());
    showDialog(context: context, builder: (BuildContext context) => dialog);
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }
        else if (snapshot.hasError) {
          Future.delayed(Duration.zero, () => showErrorDialog(snapshot.error!.toString()));
          return const Loader();
        }
        return widget;
      },
    );
  }
}
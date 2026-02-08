import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../main.dart';
import '../repository/exception/client_timeout_exception.dart';
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

void showSnackBar({required BuildContext context, required String content, Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          content,
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
        duration: duration?? const Duration(milliseconds: 600),
        backgroundColor: Colors.black.withOpacity(0.5)));
}

void showLoaderSnackBar({required BuildContext context}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(
        children: [CircularProgressIndicator(),
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

void showErrorDialog(AsyncSnapshot<void> snapshot, VoidCallback onDialogCancel, BuildContext context) {
  final error = snapshot.error;
  if (isIgnorableError(error)) {
    debugPrint("Zachycena ClientTimeoutException, dialog nebude zobrazen,  $error\nStackTrace: ${snapshot.stackTrace}");
    return;
  }
  debugPrint('Chyba zachycena: $error\nStackTrace: ${snapshot.stackTrace}');
  var dialog = ErrorDialog("Chyba!", snapshot.error.toString(), () => onDialogCancel());
  showDialog(context: context, builder: (BuildContext context) => dialog);
}

void showErrorDialogFromError(
    Object error,
    StackTrace? stackTrace,
    VoidCallback onDialogCancel,
    BuildContext context,
    ) {
  if (isIgnorableError(error)) {
    debugPrint(
      "Ignorovaná chyba: $error",
    );
    return;
  }

  debugPrint(
    'Chyba zachycena: $error\nStackTrace: $stackTrace',
  );

  final dialog = ErrorDialog(
    "Chyba!",
    error.toString(),
    onDialogCancel,
  );

  showDialog(
    context: context,
    builder: (context) => dialog,
  );
}

bool isIgnorableError(Object? error) {
  if (error is ClientTimeoutException) {
    return true;
  }
  return false;
}

void showGlobalErrorDialog(Object error, [StackTrace? stackTrace]) {
  final context = navigatorKey.currentContext;
  if (context == null) {
    debugPrint("Nebyl nalezen context pro navigatorKey!");
    return;
  }
  if (isIgnorableError(error)) {
    debugPrint("Zachycena ClientTimeoutException, dialog nebude zobrazen, $error\nStackTrace: $stackTrace");
    return;
  }
  debugPrint('Chyba zachycena: ${error.toString()} \nStackTrace: $stackTrace');
  showDialog(
    context: context,
    builder: (context) =>
        AlertDialog(
          title: const Text("Chyba!"),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
  );
}

void showInfoDialog(BuildContext context, String message) {
  if(message.isNotEmpty) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text("Informace"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }
}

void showErrorDialogString(String error, VoidCallback onDialogCancel, BuildContext context) {
  var dialog = ErrorDialog("Chyba!", error.toString(), () => onDialogCancel());
  showDialog(context: context, builder: (BuildContext context) => dialog);
}

String getValueFromValueKey(Key key) {
  return key.toString().substring(3, key.toString().length - 3);
}

int castDoubleToPercentage(double? number) {
  return ((number?? 0)*100).toInt();
}

String? doubleInMinutesToMinutesSeconds(double? value) {
  if(value == null) {
    return null;
  }
  final minutes = value.floor();
  final seconds = ((value - minutes) * 60).round();

  return "${minutes}m, ${seconds}s";
}

String? doubleInSecondsToMinutesSeconds(double? value) {
  if(value == null) {
    return null;
  }
  return doubleInMinutesToMinutesSeconds(value/60);
}

double msToKmh(double ms) {
  return double.parse((ms * 3.6).toStringAsFixed(1));
}
import 'package:flutter/material.dart';
import '../../utils/utils.dart';
import '../loader.dart';

class ErrorFutureBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final BuildContext context;
  final Widget widget;
  final VoidCallback backToMainMenu;
  const ErrorFutureBuilder({
    Key? key,
    required this.future,
    required this.context,
    required this.widget,
    required this.backToMainMenu,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }
        else if (snapshot.hasError) {
          Future.delayed(Duration.zero, () => showErrorDialog(snapshot.error!.toString(), () => backToMainMenu(), context));
          return const Loader();
        }
        return widget;
      },
    );
  }
}
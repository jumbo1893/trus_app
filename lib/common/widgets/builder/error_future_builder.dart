import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/home/screens/home_screen.dart';

import '../../../features/main/screen_controller.dart';
import '../../utils/utils.dart';
import '../loader.dart';

class ErrorFutureBuilder<T> extends ConsumerWidget {
  final Future<T> future;
  final BuildContext context;
  final Widget widget;

  const ErrorFutureBuilder({
    Key? key,
    required this.future,
    required this.context,
    required this.widget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        } else if (snapshot.hasError) {
          Future.delayed(
              Duration.zero,
              () => showErrorDialog(
                  snapshot,
                  () =>
                      ref
                      .read(screenControllerProvider)
                      .changeFragment(HomeScreen.id),
                  context));
          return const Loader();
        }
        return widget;
      },
    );
  }
}

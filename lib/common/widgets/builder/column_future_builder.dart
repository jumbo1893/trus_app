import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/home/screens/home_screen.dart';
import '../../../features/main/screen_controller.dart';
import '../../utils/utils.dart';
import '../loader.dart';

class ColumnFutureBuilder<T> extends ConsumerWidget {
  final Future<void> loadModelFuture;
  final Stream<bool>? loadingScreen;
  final List<Widget> columns;
  final CrossAxisAlignment? crossAxisAlignment;

  const ColumnFutureBuilder({
    Key? key,
    required this.loadModelFuture,
    this.loadingScreen,
    this.crossAxisAlignment,
    required this.columns,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double padding = 8.0;
    return Scaffold(
      body: StreamBuilder<bool>(
          stream: loadingScreen,
          builder: (context, loadingSnapshot) {
            if (loadingSnapshot.connectionState != ConnectionState.waiting &&
                loadingSnapshot.hasData &&
                loadingSnapshot.data!) {
              return const Loader();
            }
            return FutureBuilder<void>(
                future: loadModelFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    Future.delayed(
                        Duration.zero,
                        () => showErrorDialog(
                            snapshot,
                            () => ref
                                .read(screenControllerProvider)
                                .changeFragment(HomeScreen.id),
                            context));
                    return const Loader();
                  }
                  return Padding(
                    padding: const EdgeInsets.all(padding),
                    child: SafeArea(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: crossAxisAlignment != null? crossAxisAlignment! : CrossAxisAlignment.start,
                            children: columns),
                      ),
                    ),
                  );
                });
          }),
    );
  }
}

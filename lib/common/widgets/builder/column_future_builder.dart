import 'package:flutter/material.dart';
import 'package:trus_app/common/widgets/error.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../../../colors.dart';
import '../../../features/loading/loading_screen.dart';
import '../../utils/utils.dart';
import '../dialog/error_dialog.dart';
import '../loader.dart';

class ColumnFutureBuilder<T> extends StatelessWidget {
  final Future<void> loadModelFuture;
  final Stream<bool>? loadingScreen;
  final List<Widget> columns;
  const ColumnFutureBuilder({
    Key? key,
    required this.loadModelFuture,
    this.loadingScreen,
    required this.columns,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double padding = 8.0;
    return Scaffold(
      body: StreamBuilder<bool>(
        stream: loadingScreen,
        builder: (context, loadingSnapshot) {
          set() {};
          if (loadingSnapshot.connectionState != ConnectionState.waiting && loadingSnapshot.hasData && loadingSnapshot.data!) {
            return const LoadingScreen();
          }
          return FutureBuilder<void>(
              future: loadModelFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  Future.delayed(Duration.zero, () => showErrorDialog(snapshot.error!.toString(),set, context));
                  return const Loader();
                }
                return Padding(
                  padding: const EdgeInsets.all(padding),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        children: columns
                      ),
                    ),
                  ),
                );
              }
          );
        }
      ),
    );
  }
}
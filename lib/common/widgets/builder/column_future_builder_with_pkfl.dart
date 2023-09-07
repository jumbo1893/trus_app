import 'package:flutter/material.dart';
import 'package:trus_app/common/widgets/error.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';
import 'package:trus_app/models/pkfl/pkfl_match.dart';

import '../../../colors.dart';
import '../../../features/loading/loading_screen.dart';
import '../../utils/utils.dart';
import '../dialog/error_dialog.dart';
import '../loader.dart';
import '../sliding_pkfl_appbar.dart';

class ColumnFutureBuilderWithPkfl<T> extends StatelessWidget {
  final Future<void> loadModelFuture;
  final Stream<bool>? loadingScreen;
  final Future<PkflMatch?> pkflMatchFuture;
  final VoidCallback onPkflConfirmClick;
  final List<Widget> columns;
  const ColumnFutureBuilderWithPkfl({
    Key? key,
    required this.loadModelFuture,
    required this.pkflMatchFuture,
    required this.onPkflConfirmClick,
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
                return FutureBuilder<PkflMatch?>(
                    future: pkflMatchFuture,
                    builder: (context, snapshot) {
                      var pkflMatch = snapshot.data;
                    return Scaffold(
                      appBar: pkflMatch != null? SlidingPkflAppBar(
                        pkflMatch: pkflMatch,
                        onConfirmPressed: () => onPkflConfirmClick(),
                        onAppBarInvisible: () => {},
                      ) : null,
                      body: Padding(
                        padding: const EdgeInsets.all(padding),
                        child: SafeArea(
                          child: SingleChildScrollView(
                            child: Column(
                              children: columns
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                );
              }
          );
        }
      ),
    );
  }
}
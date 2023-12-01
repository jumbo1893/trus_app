import 'package:flutter/material.dart';
import '../../utils/utils.dart';
import '../loader.dart';

class ColumnFutureBuilder<T> extends StatelessWidget {
  final Future<void> loadModelFuture;
  final Stream<bool>? loadingScreen;
  final List<Widget> columns;
  final VoidCallback backToMainMenu;
  const ColumnFutureBuilder({
    Key? key,
    required this.loadModelFuture,
    this.loadingScreen,
    required this.columns,
    required this.backToMainMenu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double padding = 8.0;
    return Scaffold(
      body: StreamBuilder<bool>(
        stream: loadingScreen,
        builder: (context, loadingSnapshot) {
          if (loadingSnapshot.connectionState != ConnectionState.waiting && loadingSnapshot.hasData && loadingSnapshot.data!) {
            return const Loader();
          }
          return FutureBuilder<void>(
              future: loadModelFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  Future.delayed(Duration.zero, () => showErrorDialog(snapshot.error!.toString(), () => backToMainMenu(), context));
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
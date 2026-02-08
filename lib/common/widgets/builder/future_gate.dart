import 'package:flutter/material.dart';

typedef AppErrorHandler = void Function(
    BuildContext context, AsyncSnapshot<void> snapshot);

class FutureGate extends StatelessWidget {
  final Future<void> future;
  final Widget child;
  final Widget? loading;
  final AppErrorHandler? onError;

  const FutureGate({
    super.key,
    required this.future,
    required this.child,
    this.loading,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading ?? const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          if (onError != null) {
            // odložíme kvůli build fázi
            Future.microtask(() => onError!(
                  context,
                  snapshot,
                ));
          }
          return loading ?? const Center(child: CircularProgressIndicator());
        }
        return child;
      },
    );
  }
}

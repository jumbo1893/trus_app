import 'package:flutter/material.dart';

/// Keeps every route and overlay above the device's navigation controls.
class SystemNavigationSafeArea extends StatelessWidget {
  final Widget child;

  const SystemNavigationSafeArea({super.key, required this.child});

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    left: false,
    right: false,
    child: child,
  );
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../main.dart';
import '../request_executor.dart';

class LifecycleEventHandler extends WidgetsBindingObserver {
  final ProviderContainer container;

  LifecycleEventHandler({required this.container});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final context = navigatorKey.currentContext;
      /*if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Obnovuji požadavky...")),
        );
      }*/

      container.read(requestExecutorProvider).retryQueuedRequests();
    }
  }
}




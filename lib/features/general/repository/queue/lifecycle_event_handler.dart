import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../request_executor.dart';
import '../../../steps/service/step_sync_scheduler.dart';
import '../../../steps/controller/step_controller.dart';

class LifecycleEventHandler extends WidgetsBindingObserver {
  final ProviderContainer container;

  LifecycleEventHandler({required this.container});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      container.read(requestExecutorProvider).retryQueuedRequests();
      container
          .read(stepSyncSchedulerProvider)
          .onAppResumed()
          .whenComplete(() => container.invalidate(stepControllerProvider));
    }
  }
}

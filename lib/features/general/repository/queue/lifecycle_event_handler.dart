import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../request_executor.dart';
import '../../../steps/service/step_sync_scheduler.dart';
import '../../../steps/controller/step_controller.dart';
import 'package:trus_app/services/app_open_tracker.dart';

class LifecycleEventHandler extends WidgetsBindingObserver {
  final ProviderContainer container;

  LifecycleEventHandler({required this.container});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      container.read(stepSyncSchedulerProvider).pauseForegroundMonitoring();
    }
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      container.read(appOpenTrackerProvider).onBackgrounded();
    }
    if (state == AppLifecycleState.resumed) {
      container.read(appOpenTrackerProvider).onResumed();
      container.read(requestExecutorProvider).retryQueuedRequests();
      container
          .read(stepSyncSchedulerProvider)
          .onAppResumed()
          .whenComplete(() => container.invalidate(stepControllerProvider));
    }
  }
}

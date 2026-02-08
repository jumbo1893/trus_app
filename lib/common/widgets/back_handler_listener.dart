import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/main/back_action.dart';
import 'package:trus_app/features/main/state_back_condition.dart';

import '../../features/main/controller/back_handler.dart';

class BackHandlerListener<T extends StateBackCondition>
    extends ConsumerWidget {
  final ProviderListenable<T> provider;
  final BackAction Function(WidgetRef ref) backActionBuilder;
  final Widget child;

  const BackHandlerListener({
    super.key,
    required this.provider,
    required this.backActionBuilder,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<T>(
      provider,
          (_, state) {
        final controller =
        ref.read(backHandlerProvider.notifier);

        if (state.isRootBack()) {
          controller.state = _GenericBackHandler(
            backActionBuilder(ref),
          );
        } else {
          controller.state = null;
        }
      },
    );

    return child;
  }
}

class _GenericBackHandler implements BackHandler {
  final BackAction action;

  _GenericBackHandler(this.action);

  @override
  bool onBack() {
    if (action.isRootBack()) {
      action.backToRoot();
      return true;
    }
    return false;
  }
}


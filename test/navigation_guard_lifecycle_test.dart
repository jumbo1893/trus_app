import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/main/controller/navigation_guard.dart';

// Mount and unmount under an actively listening ProviderScope, reproducing the
// lifecycle in which MainScreen previously wrote to a StateProvider.
class _GuardOwner extends ConsumerStatefulWidget {
  const _GuardOwner();
  @override
  ConsumerState<_GuardOwner> createState() => _GuardOwnerState();
}

class _GuardOwnerState extends ConsumerState<_GuardOwner> {
  late final VoidCallback unregister;
  @override
  void initState() {
    super.initState();
    unregister = ref.read(navigationGuardProvider).register(() async => false);
  }

  @override
  void dispose() {
    unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const Text('Ready');
}

void main() {
  testWidgets(
    'mount and dispose register the guard without provider mutation errors',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final showOwner = ValueNotifier(true);
      addTearDown(showOwner.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                ref.watch(navigationGuardProvider);
                return ValueListenableBuilder<bool>(
                  valueListenable: showOwner,
                  builder: (_, visible, _) =>
                      visible ? const _GuardOwner() : const SizedBox.shrink(),
                );
              },
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Ready'), findsOneWidget);
      expect(await container.read(navigationGuardProvider).guard!(), isFalse);
      showOwner.value = false;
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(container.read(navigationGuardProvider).guard, isNull);
      showOwner.value = true;
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(container.read(navigationGuardProvider).guard, isNotNull);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    },
  );

  test(
    'disposing an old screen does not remove the new screen guard',
    () async {
      final registry = NavigationGuardRegistry();
      final removeOld = registry.register(() async => true);
      final removeNew = registry.register(() async => false);
      removeOld();
      expect(await registry.guard!(), isFalse);
      removeNew();
      expect(registry.guard, isNull);
    },
  );
}

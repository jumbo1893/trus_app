import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/footbar/repository/footbar_repository.dart';
import 'package:trus_app/features/footbar/screens/footbar_connect_screen.dart';
import 'package:trus_app/features/main/controller/screen_notifier.dart';
import 'package:trus_app/services/push/push_navigation_handler.dart';
import 'package:trus_app/models/api/notification/push/push_payload.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/models/api/home/home_setup.dart';
import 'package:trus_app/features/footbar/screens/footbar_warning_card.dart';

class _Repository implements FootbarRepository {
  bool invalidated = false;
  @override
  void invalidateProfile() => invalidated = true;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'Footbar warning push invalidates profile and opens connection screen',
    (tester) async {
      final repository = _Repository();
      final container = ProviderContainer(
        overrides: [footbarRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      PushNavigationHandler.navigate(
        PushNavigationRef(
          read: container.read,
          invalidate: container.invalidate,
        ),
        PushPayload.fromData({'screenId': FootbarConnectScreen.id}),
      );
      expect(repository.invalidated, isTrue);
      expect(
        container.read(screenNotifierProvider).currentScreenId,
        FootbarConnectScreen.id,
      );
      tester.binding.scheduleFrame();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(tester.takeException(), isNull);
    },
  );
  test('home setup accepts old responses and personal Footbar warning', () {
    expect(HomeSetup.fromJson({}).footbarWarning, isNull);
    expect(
      HomeSetup.fromJson({
        'footbarWarning': 'Propoj účet znovu',
      }).footbarWarning,
      'Propoj účet znovu',
    );
  });
  testWidgets('warning opens connection flow on tap', (tester) async {
    var opened = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FootbarWarningCard(
            message: 'Propoj účet znovu',
            onOpen: () => opened = true,
          ),
        ),
      ),
    );
    expect(find.text('Propoj účet znovu'), findsOneWidget);
    await tester.tap(find.text('Zkontroluj propojení Footbaru'));
    expect(opened, isTrue);
  });
}

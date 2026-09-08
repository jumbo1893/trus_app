import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trus_app/common/widgets/entry_draft_scope.dart';
import 'package:trus_app/features/fine/match/widget/quick_fine_list.dart';

void main() {
  setUp(
    () =>
        SharedPreferences.setMockInitialValues({'userEmail': 'a@example.test'}),
  );
  test('draft writes are ordered and isolated by account and match', () async {
    final store = EntryDraftStore();
    final first = store.write('1:beer:1', {
      'values': {'1:b': 2},
    });
    final second = store.write('1:beer:1', {
      'values': {'1:b': 3},
    });
    await Future.wait([first, second]);
    expect((await store.read('1:beer:1'))!['values']['1:b'], 3);
    expect(await store.read('1:beer:2'), isNull);
    await (await SharedPreferences.getInstance()).setString(
      'userEmail',
      'b@example.test',
    );
    expect(await store.read('1:beer:1'), isNull);
    await (await SharedPreferences.getInstance()).setString(
      'userEmail',
      'a@example.test',
    );
    await store.write('1:beer:1', null);
    expect(await store.read('1:beer:1'), isNull);
  });
  test('preferred fines retain required ordering', () {
    expect(quickFineRank('Překop'), 0);
    expect(quickFineRank('Pozdní příchod do začátku'), 2);
    expect(quickFineRank('Třetí poločas'), 1);
    expect(quickFineRank('Pozdní příchod před začátkem utkání'), 2);
    expect(quickFineRank('Pozdní příchod po začátku utkání'), 3);
  });
  testWidgets(
    'restoration merges own delta with newer server values and failed save retains draft',
    (tester) async {
      final store = EntryDraftStore();
      await store.write('null:beer:1', {
        'values': {'1:b': 4},
        'baseline': {'1:b': 2},
      });
      final container = ProviderContainer(
        overrides: [entryDraftStoreProvider.overrideWithValue(store)],
      );
      addTearDown(container.dispose);
      var count = 5;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: StatefulBuilder(
              builder: (context, update) => Scaffold(
                body: EntryDraftScope(
                  screenId: 'beer',
                  draftId: 'beer:1',
                  loaded: true,
                  values: {'1:b': count},
                  baseline: const {'1:b': 5},
                  labels: const {'1:b': 'Jan · piva'},
                  hasChanges: () => count != 5,
                  restore: (values) => update(() => count = values['1:b']!),
                  save: () async => throw StateError('offline'),
                  child: const Text('Zápis'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Obnovit rozepsaný zápis?'), findsOneWidget);
      await tester.tap(find.text('Obnovit'));
      await tester.pumpAndSettle();
      expect(count, 7);
      final session = container.read(entrySessionsProvider)['beer']!;
      final leave = session.confirmLeave();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Uložit'));
      await tester.pumpAndSettle();
      expect(await leave, isFalse);
      expect(await store.read('null:beer:1'), isNotNull);
      final discard = session.confirmLeave();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Zahodit'));
      await tester.pumpAndSettle();
      expect(await discard, isTrue);
      expect(count, 5);
      expect(await store.read('null:beer:1'), isNull);
      expect(tester.takeException(), isNull);
    },
  );
}

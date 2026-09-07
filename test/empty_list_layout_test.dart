import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/common/widgets/notifier/listview/model_to_string_listview.dart';
import 'package:trus_app/features/general/state/model_to_string_state.dart';
import 'package:trus_app/theme/app_theme.dart';

void main() {
  for (final height in [120.0, 400.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
        'empty list stays readable at height $height and text scale $scale',
        (tester) async {
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp(
                theme: AppTheme.light(),
                home: Scaffold(
                  body: MediaQuery(
                    data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: 320,
                        height: height,
                        child: ModelToStringListview(
                          state: ModelToStringState(
                            stats: const AsyncValue.data([]),
                          ),
                          notifier: null,
                          emptyListTitle: 'Žádné výsledky pro vybranou sezonu',
                          emptyListText:
                              'Zkus změnit sezonu nebo upravit filtry.',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          expect(tester.takeException(), isNull);
          final scroll = find.byType(SingleChildScrollView);
          expect(scroll, findsOneWidget);
          final position = tester
              .state<ScrollableState>(
                find.descendant(of: scroll, matching: find.byType(Scrollable)),
              )
              .position;
          if (height == 120) expect(position.maxScrollExtent, greaterThan(0));
          position.jumpTo(position.maxScrollExtent);
          await tester.pump();
          final textBottom = tester
              .getBottomLeft(
                find.text('Zkus změnit sezonu nebo upravit filtry.'),
              )
              .dy;
          expect(
            textBottom,
            lessThanOrEqualTo(tester.getBottomLeft(scroll).dy),
          );
          expect(textBottom, greaterThan(tester.getTopLeft(scroll).dy));
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/common/utils/calendar.dart';

void main() {
  testWidgets('calendar inherits Czech locale on an English device', (
    tester,
  ) async {
    tester.binding.platformDispatcher.localeTestValue = const Locale(
      'en',
      'US',
    );
    addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('cs', 'CZ'),
        supportedLocales: const [Locale('cs', 'CZ')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showCalendar(context, DateTime(2026, 9, 12)),
              child: const Text('Otevřít kalendář'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Otevřít kalendář'));
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(DatePickerDialog));
    final translations = MaterialLocalizations.of(context);
    expect(Localizations.localeOf(context).languageCode, 'cs');
    expect(translations.firstDayOfWeekIndex, 1);
    expect(translations.formatMonthYear(DateTime(2026, 9)), contains('září'));
    expect(find.text(translations.cancelButtonLabel), findsOneWidget);
    expect(find.text('Cancel'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

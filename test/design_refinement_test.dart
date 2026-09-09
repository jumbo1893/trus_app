import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/common/widgets/filter/app_filter_bottom_sheet.dart';
import 'package:trus_app/features/statistics/widget/statistics_data_row.dart';
import 'package:trus_app/models/api/beer/beer_detailed_model.dart';
import 'package:trus_app/theme/app_theme.dart';
import 'ux_preview_capture.dart';

void main() {
  setUpAll(loadPreviewFont);
  test('orange primary buttons have readable text in both themes', () {
    for (final theme in [AppTheme.light(), AppTheme.dark()]) {
      final background = theme.colorScheme.primary.computeLuminance();
      final text = theme.colorScheme.onPrimary.computeLuminance();
      final contrast = (background + .05) / (text + .05);
      expect(contrast, greaterThanOrEqualTo(4.5));
    }
  });
  for (final dark in [false, true]) {
    testWidgets('compact filter and descriptive cards, dark=$dark', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final theme = dark ? AppTheme.dark() : previewTheme();
      await tester.pumpWidget(
        RepaintBoundary(
          child: MaterialApp(
            theme: theme.copyWith(
              textTheme: theme.textTheme.apply(fontFamily: 'Roboto'),
            ),
            home: Scaffold(
              body: SafeArea(
                child: Column(
                  children: [
                    const Text(
                      'Statistiky piv',
                      style: TextStyle(fontSize: 22),
                    ),
                    StatisticsDataRow(
                      item: BeerDetailedModel(beerNumber: 12, liquorNumber: 3),
                    ),
                    StatisticsDataRow(
                      item: BeerDetailedModel(
                        beerNumber: 124,
                        liquorNumber: 25,
                      ),
                    ),
                    Builder(
                      builder: (context) => FilledButton(
                        onPressed: () => AppFilterBottomSheet.show<int>(
                          context,
                          title: 'Filtry',
                          initialValue: 1,
                          resetValue: 0,
                          builder: (_, value, onChanged) => const ListTile(
                            title: Text('Sezona'),
                            subtitle: Text('Podzim 2026'),
                          ),
                        ),
                        child: const Text('Otevřít filtr'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await capturePreview(tester, 'design-stats-${dark ? 'dark' : 'light'}');
      await tester.tap(find.text('Otevřít filtr'));
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(AppFilterBottomSheet)).height,
        lessThan(450),
      );
      await capturePreview(tester, 'design-filter-${dark ? 'dark' : 'light'}');
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('long filter scrolls above keyboard with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 220);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: previewTheme(),
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 640),
            viewInsets: EdgeInsets.only(bottom: 220),
            textScaler: TextScaler.linear(1.5),
          ),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Align(
              alignment: Alignment.bottomCenter,
              child: AppFilterBottomSheet(
                title: 'Filtry',
                onReset: () {},
                onApply: () {},
                child: Column(
                  children: List.generate(
                    12,
                    (i) => ListTile(title: Text('Možnost $i')),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.getBottomRight(find.text('Použít filtry')).dy, lessThan(420));
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -1000),
    );
    await tester.pumpAndSettle();
    expect(find.text('Možnost 11').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

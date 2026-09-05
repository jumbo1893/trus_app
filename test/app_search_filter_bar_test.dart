import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/common/widgets/filter/app_search_filter_bar.dart';
import 'package:trus_app/theme/app_theme.dart';

void main() {
  testWidgets('search is applied immediately and advanced count is visible', (
    tester,
  ) async {
    String query = '';

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: AppSearchFilterBar(
            query: query,
            searchHint: 'Hledat',
            activeFilterCount: 2,
            onQueryChanged: (value) => query = value,
            onFilterPressed: () {},
            onClear: () {},
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'gól');
    await tester.pump();

    expect(query, 'gól');
    expect(find.text('Filtry (2)'), findsOneWidget);
    expect(find.byTooltip('Vymazat hledání'), findsOneWidget);

    await tester.tap(find.byTooltip('Vymazat hledání'));
    expect(query, isEmpty);
  });
}

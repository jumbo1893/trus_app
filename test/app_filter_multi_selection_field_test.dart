import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/common/widgets/filter/app_filter_multi_selection_field.dart';
import 'package:trus_app/theme/app_theme.dart';

void main() {
  testWidgets(
    'selection sheet does not focus search and returns multiple values',
    (tester) async {
      Set<String> selected = {};

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: AppFilterMultiSelectionField<String>(
              label: 'Kategorie',
              hint: 'Všechny kategorie',
              searchHint: 'Hledat kategorii',
              values: selected,
              items: const ['Pivní', 'Zápasové', 'Pokutové'],
              itemLabel: (item) => item,
              onChanged: (value) => selected = value,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Všechny kategorie'));
      await tester.pumpAndSettle();

      expect(tester.testTextInput.isVisible, isFalse);

      await tester.tap(find.text('Pivní'));
      await tester.tap(find.text('Pokutové'));
      await tester.tap(find.text('Použít výběr'));
      await tester.pumpAndSettle();

      expect(selected, {'Pivní', 'Pokutové'});
    },
  );
}

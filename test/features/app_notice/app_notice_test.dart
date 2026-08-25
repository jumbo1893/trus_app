import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/app_notice/widgets/app_notice_bottom_sheet.dart';
import 'package:trus_app/models/api/app_notice/app_notice.dart';
import 'package:trus_app/theme/app_theme.dart';

void main() {
  test('parses a notice and its backend-controlled action', () {
    final response = CurrentAppNotice.fromJson({
      'notice': {
        'id': 12,
        'title': 'Co je nového',
        'message': 'Nová verze je tady.',
        'dismissible': false,
        'actions': [
          {
            'id': 20,
            'label': 'Aktualizovat',
            'type': 'OPEN_URL',
            'style': 'PRIMARY',
            'value': 'https://example.com/app',
          },
        ],
      },
    });

    expect(response.notice?.id, 12);
    expect(response.notice?.dismissible, isFalse);
    expect(response.notice?.actions.single.type, AppNoticeActionType.openUrl);
    expect(response.notice?.actions.single.style, AppNoticeActionStyle.primary);
  });

  test('parses an empty current response', () {
    expect(CurrentAppNotice.fromJson({'notice': null}).notice, isNull);
  });

  testWidgets('renders backend text and executes the selected action', (
    tester,
  ) async {
    AppNoticeAction? selectedAction;
    const action = AppNoticeAction(
      id: 20,
      label: 'Podívat se',
      type: AppNoticeActionType.openScreen,
      style: AppNoticeActionStyle.secondary,
      value: 'step-screen',
    );
    const notice = AppNotice(
      id: 12,
      title: 'Nová funkce',
      message: 'Teď můžeš soutěžit v krocích.',
      dismissible: true,
      actions: [action],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => AppNoticeBottomSheet.show(
                context,
                notice: notice,
                onAction: (value) async => selectedAction = value,
              ),
              child: const Text('Otevřít'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Otevřít'));
    await tester.pumpAndSettle();

    expect(find.text('Nová funkce'), findsOneWidget);
    expect(find.text('Teď můžeš soutěžit v krocích.'), findsOneWidget);

    await tester.tap(find.text('Podívat se'));
    await tester.pumpAndSettle();

    expect(selectedAction, same(action));
    expect(find.text('Nová funkce'), findsNothing);
  });
}

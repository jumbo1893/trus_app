import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/ai/controller/ai_assistant_controller.dart';
import 'package:trus_app/features/ai/repository/ai_api_service.dart';
import 'package:trus_app/features/ai/screens/ai_assistant_screen.dart';
import 'package:trus_app/models/api/ai/ai_models.dart';
import 'package:trus_app/theme/app_theme.dart';

final usage = AiUsage.fromJson({'enabled': true, 'unlimited': true});
AiQuestion message(int id) => AiQuestion(
  id: id,
  question: 'Dotaz $id',
  answer: 'Odpověď $id na dotaz o zápase.',
  status: AiQuestionStatus.completed,
  createdAt: DateTime(2026),
  completedAt: DateTime(2026),
  usage: usage,
);

class ChatApi implements AiApiService {
  bool fail = false;
  @override
  Future<List<AiQuestion>> getHistory({int limit = 50}) async {
    if (fail) throw StateError('secret technical detail');
    return List.generate(30, (i) => message(30 - i));
  }

  @override
  Future<AiUsage> getUsage() async => usage;
  @override
  Future<AiQuestion> ask(String question) async =>
      throw StateError('secret technical detail');
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class ChatController extends AiAssistantController {
  ChatController(Ref ref, ChatApi api) : super(ref: ref, api: api);
  void append(int id) => safeSetState(
    state.copyWith(
      questions: AsyncValue.data([
        ...state.questions.requireValue,
        message(id),
      ]),
    ),
  );
}

void main() {
  testWidgets(
    'new messages preserve reading position and follow only at the bottom',
    (tester) async {
      late ChatController controller;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            aiAssistantControllerProvider.overrideWith(
              (ref) => controller = ChatController(ref, ChatApi()),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const Scaffold(body: AiAssistantScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final scroll = tester
          .widget<ListView>(find.byType(ListView).first)
          .controller!;
      expect(scroll.position.extentAfter, lessThan(1));
      scroll.jumpTo(scroll.position.maxScrollExtent - 600);
      await tester.pump();
      final offset = scroll.offset;
      controller.append(31);
      await tester.pumpAndSettle();
      expect(scroll.offset, closeTo(offset, 1));
      expect(find.text('Nové zprávy'), findsOneWidget);
      await tester.tap(find.text('Nové zprávy'));
      await tester.pumpAndSettle();
      expect(scroll.position.extentAfter, lessThan(1));
      expect(find.text('Nové zprávy'), findsNothing);
      controller.append(32);
      await tester.pumpAndSettle();
      expect(scroll.position.extentAfter, lessThan(1));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  test('technical errors stay out of user messages', () async {
    final api = ChatApi()..fail = true;
    final container = ProviderContainer(
      overrides: [aiApiServiceProvider.overrideWithValue(api)],
    );
    addTearDown(container.dispose);
    container.listen(aiAssistantControllerProvider, (_, __) {});
    await Future<void>.delayed(Duration.zero);
    expect(
      container.read(aiAssistantControllerProvider).errorMessage,
      isNot(contains('secret')),
    );
    await container
        .read(aiAssistantControllerProvider.notifier)
        .submit('Kolik piv?');
    expect(
      container.read(aiAssistantControllerProvider).errorMessage,
      contains('Dotaz zůstal rozepsaný'),
    );
    expect(
      container.read(aiAssistantControllerProvider).errorMessage,
      isNot(contains('secret')),
    );
  });
}

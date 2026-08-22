import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/models/api/ai/ai_models.dart';

void main() {
  test('unlimited usage can always ask while enabled', () {
    final usage = AiUsage.fromJson({
      'tier': 'ULTRA',
      'usedToday': 42,
      'dailyLimit': null,
      'remainingToday': null,
      'unlimited': true,
      'enabled': true,
      'date': '2026-08-21',
    });

    expect(usage.tierLabel, 'Ultra');
    expect(usage.canAsk, isTrue);
  });

  test('exhausted standard usage cannot ask', () {
    final usage = AiUsage.fromJson({
      'tier': 'STANDARD',
      'usedToday': 2,
      'dailyLimit': 2,
      'remainingToday': 0,
      'unlimited': false,
      'enabled': true,
      'date': '2026-08-21',
    });

    expect(usage.tierLabel, 'Standard');
    expect(usage.canAsk, isFalse);
  });

  test('question response parses status and usage', () {
    final question = AiQuestion.fromJson({
      'id': 7,
      'question': 'Kdo dal nejvíc gólů?',
      'answer': 'Adam.',
      'status': 'COMPLETED',
      'createdAt': '2026-08-21T12:00:00Z',
      'completedAt': '2026-08-21T12:00:01Z',
      'usage': {
        'tier': 'PREMIUM',
        'usedToday': 1,
        'dailyLimit': 20,
        'remainingToday': 19,
        'unlimited': false,
        'enabled': true,
        'date': '2026-08-21',
      },
    });

    expect(question.id, 7);
    expect(question.status, AiQuestionStatus.completed);
    expect(question.usage.remainingToday, 19);
  });
}

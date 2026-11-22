import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/match/post_match_flow.dart';
import 'package:trus_app/models/api/match/planned_match.dart';

void main() {
  final kickOff = DateTime(2026, 11, 22, 10);
  final match = PlannedMatch(
    id: 1,
    date: kickOff,
    type: 'LEAGUE',
    status: 'IN_PROGRESS',
  );

  String at(Duration elapsed) => livePhaseLabel(match, kickOff.add(elapsed));

  test('first half counts from kick-off', () {
    expect(at(const Duration(minutes: 12, seconds: 5)), '1. poločas · 12:05');
  });

  test('break shows remaining time', () {
    expect(at(const Duration(minutes: 31)), 'Přestávka · zbývá 04:00');
  });

  test('second half continues the match clock without the break', () {
    expect(at(const Duration(minutes: 35)), '2. poločas · 30:00');
    expect(at(const Duration(minutes: 64, seconds: 59)), '2. poločas · 59:59');
  });

  test('ends after both halves and the break', () {
    expect(at(const Duration(minutes: 65)), 'Konec zápasu');
    expect(match.endsAt, kickOff.add(const Duration(minutes: 65)));
  });

  test('training and teambuilding have no score', () {
    expect(scorelessMatchType('TRAINING'), isTrue);
    expect(scorelessMatchType('TEAMBUILDING'), isTrue);
    expect(scorelessMatchType('LEAGUE'), isFalse);
    expect(scorelessMatchType(null), isFalse);
  });
}

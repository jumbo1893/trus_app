import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/entry_draft_scope.dart';
import 'package:trus_app/common/widgets/match_context_header.dart';
import 'package:trus_app/common/widgets/screen/custom_consumer_stateful_widget.dart';
import 'package:trus_app/features/goal/controller/goal_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';

class GoalScreen extends CustomConsumerStatefulWidget {
  static const String id = 'goal-screen';
  const GoalScreen({super.key})
    : super(title: 'Přidání gólů/asistencí', name: id);

  @override
  ConsumerState<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends ConsumerState<GoalScreen> {
  bool _initialized = false;
  bool _correcting = false;

  @override
  Widget build(BuildContext context) {
    final sc = ref.read(screenVariablesNotifierProvider);
    final matchId = sc.matchId;
    final state = ref.watch(goalNotifierProvider);
    final notifier = ref.read(goalNotifierProvider.notifier);
    if (!_initialized && matchId != null) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) notifier.setupMatch(matchId);
      });
    }
    final goals = state.setups.fold<int>(0, (n, p) => n + p.goalNumber);
    final assists = state.setups.fold<int>(0, (n, p) => n + p.assistNumber);
    return EntryDraftScope(
      key: ValueKey(notifier.draftId),
      screenId: GoalScreen.id,
      draftId: notifier.draftId,
      loaded: state.matchId > 0,
      values: notifier.draftValues,
      baseline: notifier.draftBaseline,
      labels: {
        for (final p in state.setups) ...{
          '${p.player.id}:g': '${p.player.name} · góly',
          '${p.player.id}:a': '${p.player.name} · asistence',
        },
        'rewrite': 'Přepočítat pokuty',
      },
      hasChanges: () => notifier.hasChanges,
      restore: notifier.restoreDraft,
      save: () => notifier.changeGoals(navigate: false),
      showStatus: false,
      child: ColoredBox(
        color: const Color(0xFF0E0B12),
        child: Column(
          children: [
            if (sc.matchModel.id == matchId)
              MatchContextHeader(match: sc.matchModel),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Účet zápasu',
                      style: TextStyle(
                        color: Color(0xFFFFF7E9),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (state.saving)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Text(
                      state.saveFailed ? 'Neuloženo' : 'Ukládá se automaticky',
                      style: TextStyle(
                        fontSize: 11,
                        color: state.saveFailed
                            ? Colors.redAccent
                            : const Color(0xFFA29BB4),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: state.matchId < 0
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                      itemCount: state.setups.length,
                      itemBuilder: (context, index) {
                        final player = state.setups[index];
                        return Container(
                          key: ValueKey('goal-player-${player.player.id}'),
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          padding: const EdgeInsets.fromLTRB(10, 6, 8, 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1721),
                            border: Border.all(color: const Color(0xFF302A38)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 95,
                                child: Text(
                                  player.player.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFFF7F2FA),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              _scoreTile(
                                index,
                                true,
                                player.goalNumber,
                                const Color(0xFFFFB529),
                              ),
                              const SizedBox(width: 5),
                              _scoreTile(
                                index,
                                false,
                                player.assistNumber,
                                const Color(0xFF7ADCCC),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            SwitchListTile(
              dense: true,
              title: const Text(
                'Přepočítat pokuty za góly a hattricky',
                style: TextStyle(color: Color(0xFFF7F2FA), fontSize: 13),
              ),
              secondary: IconButton(
                tooltip: 'Jak se přepočítají pokuty',
                icon: const Icon(Icons.info_outline, color: Color(0xFFA29BB4)),
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Přepočet pokut'),
                    content: const Text(
                      'Stávající pokuty za góly a hattricky v tomto zápase se nahradí podle zadaných gólů. Za každý gól vznikne pokuta střelci. Za každé tři góly jednoho střelce vznikne pokuta za hattrick ostatním aktivním hráčům týmu. Asistence ani ostatní druhy pokut se tím nemění.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Rozumím'),
                      ),
                    ],
                  ),
                ),
              ),
              value: state.rewriteToFines,
              onChanged: notifier.setRewriteToFines,
            ),
            if (state.saveFailed)
              TextButton.icon(
                onPressed: () => notifier
                    .changeGoals(navigate: false)
                    .catchError((Object _) {}),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Nepodařilo se uložit · Zkusit znovu'),
              ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 5, 12, 8),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFF2D2834))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _total(goals, 'GÓLY', const Color(0xFFFFB529)),
                  ),
                  Expanded(
                    child: _total(
                      assists,
                      'ASISTENCE',
                      const Color(0xFF7ADCCC),
                    ),
                  ),
                  InkWell(
                    key: const ValueKey('goal-mode-toggle'),
                    onTap: () => setState(() => _correcting = !_correcting),
                    child: Container(
                      width: 58,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _correcting
                            ? const Color(0xFFFFB529)
                            : const Color(0xFFE74778),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _correcting ? Icons.add : Icons.remove,
                            size: 18,
                          ),
                          Text(
                            _correcting ? 'Přidávat' : 'Opravit',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _total(int count, String label, Color color) => Column(
    children: [
      Text(
        '$count',
        style: TextStyle(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      Text(
        label,
        style: const TextStyle(color: Color(0xFFA29BB4), fontSize: 9),
      ),
    ],
  );

  Widget _scoreTile(int index, bool goal, int count, Color accent) {
    final notifier = ref.read(goalNotifierProvider.notifier);
    final playerId = ref.read(goalNotifierProvider).setups[index].player.id;
    return Expanded(
      child: Semantics(
        button: true,
        label:
            '${_correcting ? 'Odebrat' : 'Přidat'} ${goal ? 'gól' : 'asistenci'}, celkem $count',
        child: InkWell(
          key: ValueKey('goal-$playerId-${goal ? 'goal' : 'assist'}'),
          borderRadius: BorderRadius.circular(14),
          onTap: _correcting && count == 0
              ? null
              : () => _correcting
                    ? notifier.removeNumber(index, goal)
                    : notifier.addNumber(index, goal),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: count > 0 ? accent.withAlpha(24) : const Color(0xFF18151E),
              border: count > 0
                  ? Border.all(color: accent.withAlpha(100))
                  : null,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _FootballActionIcon(goal: goal, color: accent),
                const SizedBox(width: 5),
                Text(
                  '$count',
                  style: TextStyle(
                    color: accent,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FootballActionIcon extends StatelessWidget {
  const _FootballActionIcon({required this.goal, required this.color});

  final bool goal;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 40,
    height: 32,
    child: CustomPaint(painter: _FootballActionPainter(goal, color)),
  );
}

class _FootballActionPainter extends CustomPainter {
  const _FootballActionPainter(this.goal, this.color);

  final bool goal;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fineLine = Paint()
      ..color = color.withAlpha(140)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    if (goal) {
      // The scorer shoots a ball into the goal.
      _player(canvas, 6, line);
      canvas.drawPath(
        Path()
          ..moveTo(19, 27)
          ..lineTo(19, 6)
          ..lineTo(38, 6)
          ..lineTo(38, 27),
        line,
      );
      for (final x in [25.0, 31.0]) {
        canvas.drawLine(Offset(x, 7), Offset(x, 27), fineLine);
      }
      for (final y in [13.0, 20.0, 26.0]) {
        canvas.drawLine(Offset(20, y), Offset(37, y), fineLine);
      }
      _ball(canvas, const Offset(20, 25), line, radius: 3.5);
      _letter(canvas, 'G', const Offset(30, 16));
    } else {
      // The ball follows a pass toward the receiving player.
      _player(canvas, 34, line);
      _ball(canvas, const Offset(6, 24), line, radius: 3);
      canvas.drawPath(
        Path()
          ..moveTo(11, 23)
          ..quadraticBezierTo(19, 16, 27, 23),
        line,
      );
      canvas.drawPath(
        Path()
          ..moveTo(24, 19)
          ..lineTo(27, 23)
          ..lineTo(23, 24),
        line,
      );
      _letter(canvas, 'A', const Offset(20, 9));
    }
  }

  void _player(Canvas canvas, double x, Paint line) {
    canvas.drawCircle(Offset(x, 8), 2.5, line);
    canvas.drawLine(Offset(x, 11), Offset(x, 20), line);
    canvas.drawLine(Offset(x - 5, 15), Offset(x + 5, 15), line);
    canvas.drawLine(Offset(x, 20), Offset(x - 4, 28), line);
    canvas.drawLine(Offset(x, 20), Offset(x + 4, 28), line);
  }

  void _ball(Canvas canvas, Offset center, Paint line, {double radius = 5}) {
    canvas.drawCircle(center, radius, line);
    final dot = Paint()..color = color;
    canvas.drawCircle(center, radius * .33, dot);
    for (final direction in [
      const Offset(0, -1),
      const Offset(1, 0),
      const Offset(0, 1),
      const Offset(-1, 0),
    ]) {
      canvas.drawLine(
        center + direction * (radius * .4),
        center + direction * (radius * .85),
        line,
      );
    }
  }

  void _letter(Canvas canvas, String letter, Offset center) {
    final background = Paint()..color = const Color(0xFF18151E);
    canvas.drawCircle(center, 7, background);
    canvas.drawCircle(
      center,
      7,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    final text = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(canvas, center - Offset(text.width / 2, text.height / 2));
  }

  @override
  bool shouldRepaint(covariant _FootballActionPainter oldDelegate) =>
      oldDelegate.goal != goal || oldDelegate.color != color;
}

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/entry_draft_scope.dart';
import 'package:trus_app/common/widgets/match_context_header.dart';
import 'package:trus_app/common/widgets/screen/custom_consumer_stateful_widget.dart';
import 'package:trus_app/features/goal/controller/goal_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/features/main/controller/screen_notifier.dart';
import 'package:trus_app/features/beer/screens/beer_simple_screen.dart';
import 'package:trus_app/features/fine/match/screens/fine_match_screen.dart';
import 'package:trus_app/features/home/screens/home_screen.dart';
import 'package:trus_app/theme/app_colors.dart';

class GoalScreen extends CustomConsumerStatefulWidget {
  static const String id = 'goal-screen';
  const GoalScreen({super.key})
    : super(title: 'Přidání gólů/asistencí', name: id);

  @override
  ConsumerState<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends ConsumerState<GoalScreen>
    with SingleTickerProviderStateMixin {
  bool _initialized = false;
  bool _correcting = false;
  late final AnimationController _deleteWiggle;

  @override
  void initState() {
    super.initState();
    _deleteWiggle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 230),
    );
  }

  @override
  void dispose() {
    _deleteWiggle.dispose();
    super.dispose();
  }

  void _setCorrection(bool enabled) {
    setState(() => _correcting = enabled);
    if (_correcting) {
      _deleteWiggle.repeat(reverse: true);
    } else {
      _deleteWiggle.stop();
      _deleteWiggle.reset();
    }
  }

  Widget _wiggle(Widget child, int index, bool selected, {int icon = 0}) {
    if (!_correcting || !selected) return child;
    final marked = Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        const Positioned(
          top: -3,
          right: -3,
          child: IgnorePointer(
            child: CircleAvatar(
              radius: 7,
              backgroundColor: Color(0xFFE74778),
              child: Icon(Icons.close, size: 10, color: Colors.white),
            ),
          ),
        ),
      ],
    );
    return AnimatedBuilder(
      animation: _deleteWiggle,
      builder: (context, child) => Transform.rotate(
        angle:
            math.sin(
              _deleteWiggle.value * math.pi * 2 + icon * 0.9 + index * 0.5,
            ) *
            0.065,
        child: child,
      ),
      child: marked,
    );
  }

  Widget _deleteSwitch(bool canDelete) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('Mazání', style: TextStyle(fontWeight: FontWeight.w600)),
      Switch(
        key: const ValueKey('goal-mode-toggle'),
        value: _correcting && canDelete,
        onChanged: canDelete ? _setCorrection : null,
      ),
    ],
  );

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
    final yellowCards = state.setups.fold<int>(0, (n, p) => n + p.yellowCards);
    final redCards = state.setups.fold<int>(0, (n, p) => n + p.redCards);
    final keepers = state.setups.where((p) => p.goalkeepingMinutes > 0).length;
    final canDelete = goals + assists + yellowCards + redCards + keepers > 0;
    if (_correcting && !canDelete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_correcting) return;
        final current = ref.read(goalNotifierProvider).setups;
        if (current.any(
          (p) =>
              p.goalNumber > 0 ||
              p.assistNumber > 0 ||
              p.yellowCards > 0 ||
              p.redCards > 0 ||
              p.goalkeepingMinutes > 0,
        ))
          return;
        _setCorrection(false);
      });
    }
    final dark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.appColors;
    final goalColor = dark ? const Color(0xFF43C87A) : const Color(0xFF177245);
    final assistColor = dark
        ? const Color(0xFF67A9FF)
        : const Color(0xFF1E5EB4);
    final yellowColor = dark ? Colors.amber : const Color(0xFF9B6700);
    final redColor = dark ? Colors.redAccent : const Color(0xFFB42332);
    final keeperColor = dark ? Colors.white : const Color(0xFF374151);
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
          '${p.player.id}:y': '${p.player.name} · žluté karty',
          '${p.player.id}:r': '${p.player.name} · červené karty',
          '${p.player.id}:m': '${p.player.name} · minuty v bráně',
        },
      },
      hasChanges: () => notifier.hasChanges,
      restore: notifier.restoreDraft,
      save: () => notifier.changeGoals(navigate: false),
      showStatus: false,
      child: ColoredBox(
        color: dark ? const Color(0xFF0E0B12) : colors.backgroundPrimary,
        child: Column(
          children: [
            if (sc.matchModel.id == matchId)
              MatchContextHeader(
                match: sc.matchModel,
                trailing: _deleteSwitch(canDelete),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Statistiky zápasu',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (sc.matchModel.id != matchId) _deleteSwitch(canDelete),
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
                            ? redColor
                            : colors.textSecondary,
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
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                          decoration: BoxDecoration(
                            color: dark
                                ? const Color(0xFF1A1721)
                                : colors.cardBackground,
                            border: Border.all(
                              color: dark
                                  ? const Color(0xFF302A38)
                                  : colors.border,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                player.player.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  _scoreTile(
                                    index,
                                    true,
                                    player.goalNumber,
                                    goalColor,
                                  ),
                                  const SizedBox(width: 4),
                                  _scoreTile(
                                    index,
                                    false,
                                    player.assistNumber,
                                    assistColor,
                                  ),
                                  const SizedBox(width: 4),
                                  _cardTile(
                                    index,
                                    true,
                                    player.yellowCards,
                                    yellowColor,
                                  ),
                                  const SizedBox(width: 4),
                                  _cardTile(
                                    index,
                                    false,
                                    player.redCards,
                                    redColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: _wiggle(
                                      Tooltip(
                                        message: 'Brankář',
                                        child: InkWell(
                                          key: ValueKey(
                                            'goal-${player.player.id}-keeper',
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          onTap:
                                              _correcting &&
                                                  player.goalkeepingMinutes == 0
                                              ? null
                                              : () => notifier.toggleGoalkeeper(
                                                  index,
                                                ),
                                          child: Container(
                                            height: 42,
                                            width: double.infinity,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color:
                                                  player.goalkeepingMinutes > 0
                                                  ? keeperColor.withAlpha(24)
                                                  : dark
                                                  ? const Color(0xFF18151E)
                                                  : colors.backgroundSecondary,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              'GK',
                                              style: TextStyle(
                                                color: keeperColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      index,
                                      player.goalkeepingMinutes > 0,
                                      icon: 4,
                                    ),
                                  ),
                                ],
                              ),
                              if (player.goalkeepingMinutes > 0)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: SizedBox(
                                    width: 95,
                                    child: _MinutesField(
                                      key: ValueKey(
                                        'keeper-minutes-${player.player.id}',
                                      ),
                                      minutes: player.goalkeepingMinutes,
                                      onChanged: (value) => notifier
                                          .setGoalkeepingMinutes(index, value),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
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
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: dark ? const Color(0xFF2D2834) : colors.border,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _total(goals, 'GÓLY', goalColor)),
                      Expanded(
                        child: _total(assists, 'ASISTENCE', assistColor),
                      ),
                      Expanded(
                        child: _total(yellowCards, 'ŽLUTÉ', yellowColor),
                      ),
                      Expanded(child: _total(redCards, 'ČERVENÉ', redColor)),
                      Expanded(child: _total(keepers, 'BRANKÁŘI', keeperColor)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (final (label, id) in [
                        ('Do hospody', BeerSimpleScreen.id),
                        ('K pokutám', FineMatchScreen.id),
                        ('Přehled', HomeScreen.id),
                      ])
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: SizedBox(
                              height: 40,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                onPressed: state.saving
                                    ? null
                                    : () => ref
                                          .read(screenNotifierProvider.notifier)
                                          .changeByFragmentId(id),
                                child: Text(
                                  label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
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
        style: TextStyle(color: context.appColors.textSecondary, fontSize: 9),
      ),
    ],
  );

  Widget _cardTile(int index, bool yellow, int count, Color color) {
    final notifier = ref.read(goalNotifierProvider.notifier);
    return Expanded(
      child: _wiggle(
        InkWell(
          key: ValueKey(
            'goal-${ref.read(goalNotifierProvider).setups[index].player.id}-${yellow ? 'yellow' : 'red'}',
          ),
          onTap: _correcting && count == 0
              ? null
              : () => notifier.changeCard(
                  index,
                  yellow: yellow,
                  remove: _correcting,
                ),
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: count > 0
                  ? color.withAlpha(22)
                  : Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF18151E)
                  : context.appColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.style, color: color, size: 16),
                const SizedBox(width: 2),
                Text(
                  '$count',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        index,
        count > 0,
        icon: yellow ? 2 : 3,
      ),
    );
  }

  Widget _scoreTile(int index, bool goal, int count, Color accent) {
    final notifier = ref.read(goalNotifierProvider.notifier);
    final playerId = ref.read(goalNotifierProvider).setups[index].player.id;
    return Expanded(
      child: _wiggle(
        Semantics(
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
              height: 42,
              decoration: BoxDecoration(
                color: count > 0
                    ? accent.withAlpha(24)
                    : Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF18151E)
                    : context.appColors.backgroundSecondary,
                border: count > 0
                    ? Border.all(color: accent.withAlpha(100))
                    : null,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 23,
                    height: 23,
                    child: FittedBox(
                      child: _FootballActionIcon(
                        goal: goal,
                        color: accent,
                        background:
                            Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF18151E)
                            : context.appColors.backgroundSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '$count',
                    style: TextStyle(
                      color: accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        index,
        count > 0,
        icon: goal ? 0 : 1,
      ),
    );
  }
}

class _MinutesField extends StatefulWidget {
  const _MinutesField({
    super.key,
    required this.minutes,
    required this.onChanged,
  });
  final int minutes;
  final ValueChanged<int> onChanged;

  @override
  State<_MinutesField> createState() => _MinutesFieldState();
}

class _MinutesFieldState extends State<_MinutesField> {
  late final TextEditingController controller = TextEditingController(
    text: '${widget.minutes}',
  );

  @override
  void didUpdateWidget(covariant _MinutesField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.minutes != oldWidget.minutes &&
        int.tryParse(controller.text) != widget.minutes) {
      controller.text = '${widget.minutes}';
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    style: TextStyle(color: context.appColors.textPrimary),
    decoration: const InputDecoration(isDense: true, suffixText: 'min'),
    onChanged: (value) {
      final minutes = int.tryParse(value);
      if (minutes != null) widget.onChanged(minutes);
    },
  );
}

class _FootballActionIcon extends StatelessWidget {
  const _FootballActionIcon({
    required this.goal,
    required this.color,
    required this.background,
  });

  final bool goal;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 40,
    height: 32,
    child: CustomPaint(
      painter: _FootballActionPainter(goal, color, background),
    ),
  );
}

class _FootballActionPainter extends CustomPainter {
  const _FootballActionPainter(this.goal, this.color, this.background);

  final bool goal;
  final Color color;
  final Color background;

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
    final backgroundPaint = Paint()..color = background;
    canvas.drawCircle(center, 7, backgroundPaint);
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
      oldDelegate.goal != goal ||
      oldDelegate.color != color ||
      oldDelegate.background != background;
}

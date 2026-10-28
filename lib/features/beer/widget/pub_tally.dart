import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:trus_app/models/api/beer/beer_no_match_with_player.dart';
import 'package:trus_app/models/api/beer/pub_attendance.dart';

import 'czech_name_compare.dart';
import 'pub_drink_art.dart';

class PubTally extends StatefulWidget {
  const PubTally({
    super.key,
    required this.matchId,
    required this.players,
    required this.matchPlayerIds,
    required this.myPlayerId,
    this.active = true,
    required this.onAdd,
    required this.onRemove,
    required this.attendance,
    required this.onSaveAttendance,
    this.onChoosingChanged,
  });
  final int matchId;
  final List<BeerNoMatchWithPlayer> players;
  final List<int> matchPlayerIds;
  final int? myPlayerId;
  final bool active;
  final void Function(int, bool) onAdd;
  final void Function(int, bool) onRemove;
  final PubAttendance? attendance;
  final Future<PubAttendance> Function(Set<int>, Set<int>) onSaveAttendance;
  final ValueChanged<bool>? onChoosingChanged;
  @override
  State<PubTally> createState() => _PubTallyState();
}

class _DashedTileBorderPainter extends CustomPainter {
  const _DashedTileBorderPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(18)),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final metric in path.computeMetrics()) {
      for (var distance = 0.0; distance < metric.length; distance += 7) {
        canvas.drawPath(
          metric.extractPath(distance, (distance + 3).clamp(0, metric.length)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedTileBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _PubTallyState extends State<PubTally>
    with SingleTickerProviderStateMixin {
  static const styledDrinkOrder = [PubDrinkType.beer, PubDrinkType.shot];
  late final AnimationController _deleteWiggle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 230),
  );

  Set<int> guests = {};
  Set<int> left = {};
  bool choosing = true;
  bool saving = false;
  bool correcting = false;
  @override
  void initState() {
    super.initState();
    selectInitialGuests();
    applySavedAttendance();
  }

  @override
  void dispose() {
    _deleteWiggle.dispose();
    super.dispose();
  }

  void setCorrection(bool enabled) {
    setState(() => correcting = enabled);
    if (enabled) {
      _deleteWiggle.repeat(reverse: true);
    } else {
      _deleteWiggle.stop();
      _deleteWiggle.reset();
    }
  }

  @override
  void didUpdateWidget(covariant PubTally oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.matchId != widget.matchId) {
      selectInitialGuests();
      applySavedAttendance();
    } else if (!oldWidget.active &&
        widget.active &&
        widget.attendance?.configured != true) {
      choosing = true;
    } else {
      if (oldWidget.attendance != widget.attendance) applySavedAttendance();
    }
  }

  void addDrink(int index, PubDrinkType type) {
    if (left.contains(widget.players[index].player.id)) return;
    widget.onAdd(index, type == PubDrinkType.beer);
  }

  void removeDrink(int index, PubDrinkType type) {
    if (left.contains(widget.players[index].player.id)) return;
    widget.onRemove(index, type == PubDrinkType.beer);
  }

  void selectInitialGuests() {
    final ids = widget.matchPlayerIds.toSet();
    guests = widget.players
        .where(
          (p) =>
              ids.contains(p.player.id) ||
              p.beerNumber > 0 ||
              p.liquorNumber > 0,
        )
        .map((p) => p.player.id)
        .whereType<int>()
        .toSet();
    if (guests.isEmpty) {
      guests = widget.players.map((p) => p.player.id).whereType<int>().toSet();
    }
  }

  void applySavedAttendance() {
    if (widget.attendance?.configured == true) {
      guests = {...widget.attendance!.guestIds};
      left = {...widget.attendance!.leftIds};
      choosing = false;
    } else {
      left = {};
      choosing = true;
    }
  }

  Future<void> saveAttendance(
    Set<int> newGuests,
    Set<int> newLeft, {
    required bool finishChoosing,
  }) async {
    if (saving) return;
    final savingMatchId = widget.matchId;
    setState(() => saving = true);
    try {
      final saved = await widget.onSaveAttendance(newGuests, newLeft);
      if (!mounted || widget.matchId != savingMatchId) return;
      setState(() {
        guests = {...saved.guestIds};
        left = {...saved.leftIds};
        if (finishChoosing) choosing = false;
      });
      if (finishChoosing) widget.onChoosingChanged?.call(false);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Účast v hospodě se nepodařilo uložit. Zkus to znovu.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) =>
      choosing ? picker(context) : tally(context);

  Widget picker(BuildContext context) {
    final sortedPlayers = [...widget.players]
      ..sort((a, b) {
        final aMe =
            widget.myPlayerId != null && a.player.id == widget.myPlayerId;
        final bMe =
            widget.myPlayerId != null && b.player.id == widget.myPlayerId;
        if (aMe != bMe) return aMe ? -1 : 1;
        return compareCzechNames(a.player.name, b.player.name);
      });
    return Column(
      children: [
        Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kdo jde do hospody?',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Účastníci zápasu jsou vybraní. Odškrtni ty, kteří nejdou.',
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: ClipRect(
            child: ListView.builder(
              clipBehavior: Clip.hardEdge,
              physics: const ClampingScrollPhysics(),
              itemCount: sortedPlayers.length,
              itemBuilder: (context, i) {
                final player = sortedPlayers[i].player;
                return CheckboxListTile(
                  value: guests.contains(player.id),
                  title: Text(player.name),
                  secondary: const Icon(Icons.person_outline_rounded),
                  onChanged: player.id == null
                      ? null
                      : (checked) => setState(() {
                          if (checked ?? false) {
                            guests.add(player.id!);
                          } else {
                            guests.remove(player.id);
                            left.remove(player.id);
                          }
                        }),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              TextButton(
                key: const ValueKey('pub-choose-later'),
                onPressed: saving
                    ? null
                    : () => setState(() => choosing = false),
                child: const Text('Později'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: saving
                      ? null
                      : () => saveAttendance(
                          {...guests},
                          {...left},
                          finishChoosing: true,
                        ),
                  icon: const Icon(Icons.sports_bar_rounded),
                  label: Text('DO HOSPODY · ${guests.length}'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget tally(BuildContext context) {
    final entries = <(int, BeerNoMatchWithPlayer)>[
      for (var i = 0; i < widget.players.length; i++)
        if (guests.contains(widget.players[i].player.id))
          (i, widget.players[i]),
    ];
    entries.sort((a, b) {
      final aMe =
          widget.myPlayerId != null && a.$2.player.id == widget.myPlayerId;
      final bMe =
          widget.myPlayerId != null && b.$2.player.id == widget.myPlayerId;
      if (aMe != bMe) return aMe ? -1 : 1;
      final aLeft = left.contains(a.$2.player.id);
      final bLeft = left.contains(b.$2.player.id);
      if (aLeft != bLeft) return aLeft ? 1 : -1;
      final byName = compareCzechNames(a.$2.player.name, b.$2.player.name);
      return byName != 0 ? byName : a.$1.compareTo(b.$1);
    });
    return styledTally(context, entries);
  }

  Map<PubDrinkType, int> countsFor(BeerNoMatchWithPlayer item) => {
    PubDrinkType.beer: item.beerNumber,
    PubDrinkType.shot: item.liquorNumber,
  };

  double litersFor(Map<PubDrinkType, int> counts) =>
      counts[PubDrinkType.beer]! * .5 + counts[PubDrinkType.shot]! * .04;

  String litersLabel(double liters) => liters
      .toStringAsFixed(liters < .1 && liters > 0 ? 2 : 1)
      .replaceAll('.', ',');

  Widget styledTally(
    BuildContext context,
    List<(int, BeerNoMatchWithPlayer)> entries,
  ) {
    final canDelete = entries.any(
      (entry) =>
          !left.contains(entry.$2.player.id) &&
          (entry.$2.beerNumber > 0 || entry.$2.liquorNumber > 0),
    );
    if (correcting && !canDelete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !correcting) return;
        if (widget.players.any(
          (player) =>
              guests.contains(player.player.id) &&
              !left.contains(player.player.id) &&
              (player.beerNumber > 0 || player.liquorNumber > 0),
        ))
          return;
        setCorrection(false);
      });
    }
    final light = Theme.of(context).brightness == Brightness.light;
    final colors =
        Theme.of(context).extension<AppColors>() ??
        (light ? AppColors.light : AppColors.dark);
    final background = light
        ? colors.backgroundPrimary
        : const Color(0xFF0E0B12);
    final muted = light ? colors.textSecondary : const Color(0xFFA29BB4);
    final gold = light ? const Color(0xFF9A5B00) : const Color(0xFFFFB529);
    final text = light ? colors.textPrimary : const Color(0xFFFFF7E9);
    final totals = {
      for (final type in styledDrinkOrder)
        type: entries.fold<int>(
          0,
          (sum, entry) => sum + countsFor(entry.$2)[type]!,
        ),
    };
    final totalPieces = totals.values.fold<int>(0, (sum, n) => sum + n);
    final totalLiters = litersFor(totals);
    final leader = entries.isEmpty
        ? null
        : ([...entries]..sort(
                (a, b) => litersFor(
                  countsFor(b.$2),
                ).compareTo(litersFor(countsFor(a.$2))),
              ))
              .first
              .$2;

    return ColoredBox(
      color: background,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Účet v hospodě',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: text,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Upravit účastníky',
                  onPressed: () {
                    setState(() => choosing = true);
                    widget.onChoosingChanged?.call(true);
                  },
                  icon: Icon(Icons.group_outlined, color: text),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
            child: Row(
              children: [
                Icon(Icons.workspace_premium_outlined, color: gold, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    leader != null && totalPieces > 0
                        ? 'Vede ${leader.player.name}'
                        : 'Zatím bez lídra',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$totalPieces ks',
                  style: TextStyle(
                    color: muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${litersLabel(totalLiters)} l',
                  style: TextStyle(
                    color: text,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
              itemCount: entries.length,
              itemBuilder: (context, position) {
                final (index, item) = entries[position];
                return styledPlayerCard(index, item);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 5, 12, 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: light ? colors.border : const Color(0xFF2D2834),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      for (final type in styledDrinkOrder)
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '${totals[type]}',
                                style: TextStyle(
                                  color: styledDrinkColor(type),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                drinkLabel(type),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: muted, fontSize: 9),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Mazání',
                      style: TextStyle(
                        color: text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Switch.adaptive(
                      key: const ValueKey('pub-mode-toggle'),
                      value: correcting && canDelete,
                      onChanged: canDelete ? setCorrection : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color styledDrinkColor(PubDrinkType type) => switch (type) {
    PubDrinkType.beer =>
      Theme.of(context).brightness == Brightness.light
          ? const Color(0xFF9A5B00)
          : const Color(0xFFFFB529),
    PubDrinkType.shot =>
      Theme.of(context).brightness == Brightness.light
          ? const Color(0xFF087A70)
          : const Color(0xFF7ADCCC),
  };

  Widget styledPlayerCard(int index, BeerNoMatchWithPlayer item) {
    final light = Theme.of(context).brightness == Brightness.light;
    final colors =
        Theme.of(context).extension<AppColors>() ??
        (light ? AppColors.light : AppColors.dark);
    final muted = light ? colors.textSecondary : const Color(0xFFA29BB4);
    final counts = countsFor(item);
    final pieces = counts.values.fold<int>(0, (sum, n) => sum + n);
    final hasLeft = left.contains(item.player.id);
    return Container(
      key: ValueKey('styled-player-${item.player.id}'),
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.fromLTRB(10, 6, 8, 6),
      decoration: BoxDecoration(
        color: light ? colors.cardBackground : const Color(0xFF1A1721),
        border: Border.all(
          color: light ? colors.border : const Color(0xFF302A38),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Opacity(
        opacity: hasLeft ? .55 : 1,
        child: Row(
          children: [
            SizedBox(
              width: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.player.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: light
                                ? colors.textPrimary
                                : const Color(0xFFF7F2FA),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Tooltip(
                        message: hasLeft
                            ? 'Vrátit do hospody'
                            : 'Odešel z hospody',
                        child: InkWell(
                          key: ValueKey('styled-leave-${item.player.id}'),
                          onTap: saving
                              ? null
                              : () {
                                  final next = {...left};
                                  if (hasLeft) {
                                    next.remove(item.player.id);
                                  } else {
                                    next.add(item.player.id!);
                                  }
                                  saveAttendance(
                                    {...guests},
                                    next,
                                    finishChoosing: false,
                                  );
                                },
                          child: SizedBox(
                            width: 26,
                            height: 26,
                            child: Center(
                              child: Icon(
                                hasLeft
                                    ? Icons.undo_rounded
                                    : Icons.logout_rounded,
                                color: muted,
                                size: 17,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pieces == 0
                        ? 'zatím nic'
                        : '$pieces ks · ${litersLabel(litersFor(counts))} l',
                    maxLines: 1,
                    style: TextStyle(color: muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            for (final type in styledDrinkOrder)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: styledDrinkTile(index, type, counts[type]!, hasLeft),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget styledDrinkTile(
    int index,
    PubDrinkType type,
    int count,
    bool hasLeft,
  ) {
    final active = count > 0;
    final light = Theme.of(context).brightness == Brightness.light;
    final colors =
        Theme.of(context).extension<AppColors>() ??
        (light ? AppColors.light : AppColors.dark);
    final accent = styledDrinkColor(type);
    final enabled = !hasLeft && (correcting ? active : true);
    return Semantics(
      button: true,
      label:
          '${correcting ? 'Odebrat' : 'Přidat'} ${drinkLabel(type).toLowerCase()}, $count kusů',
      child: GestureDetector(
        key: ValueKey('styled-${widget.players[index].player.id}-${type.name}'),
        onTap: enabled
            ? () =>
                  correcting ? removeDrink(index, type) : addDrink(index, type)
            : null,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: active
                ? accent.withAlpha(light ? 20 : 24)
                : (light
                      ? colors.backgroundSecondary
                      : const Color(0xFF18151E)),
            border: active ? Border.all(color: accent.withAlpha(100)) : null,
            borderRadius: BorderRadius.circular(14),
          ),
          child: CustomPaint(
            foregroundPainter: active
                ? null
                : _DashedTileBorderPainter(
                    light ? colors.border : const Color(0xFF373140),
                  ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                if (correcting && active)
                  AnimatedBuilder(
                    animation: _deleteWiggle,
                    builder: (context, child) => Transform.rotate(
                      angle:
                          math.sin(
                            _deleteWiggle.value * math.pi * 2 +
                                index * 0.5 +
                                type.index * 0.9,
                          ) *
                          0.065,
                      child: child,
                    ),
                    child: PubDrinkArt(type: type, active: active),
                  )
                else
                  PubDrinkArt(type: type, active: active),
                if (correcting && active && !hasLeft)
                  Positioned(
                    top: -4,
                    left: -4,
                    child: Container(
                      key: ValueKey(
                        'remove-badge-${widget.players[index].player.id}-${type.name}',
                      ),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE74778),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: light
                              ? colors.cardBackground
                              : const Color(0xFF1A1721),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (active)
                  Positioned(
                    top: correcting ? null : -3,
                    bottom: correcting ? -3 : null,
                    right: -3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        '×$count',
                        style: TextStyle(
                          color: light ? Colors.white : const Color(0xFF100C12),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String drinkLabel(PubDrinkType type) => switch (type) {
    PubDrinkType.beer => 'Pivo',
    PubDrinkType.shot => 'Panák',
  };
}

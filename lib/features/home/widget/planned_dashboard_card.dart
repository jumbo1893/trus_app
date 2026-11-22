import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/football/repository/planned_match_api_service.dart';
import 'package:trus_app/features/football/screens/planned_match_sheet.dart';
import 'package:trus_app/features/football/widgets/planned_match_photo.dart';
import 'package:trus_app/features/football/widgets/planned_match_status_button.dart';
import 'package:trus_app/features/home/controller/home_notifier.dart';
import 'package:trus_app/features/match/widget/match_score_bar.dart';
import 'package:trus_app/features/home/widget/home_section_card.dart';
import 'package:trus_app/models/api/match/planned_match.dart';
import 'package:trus_app/models/api/match/planned_match_participation.dart';
import 'package:trus_app/models/api/participation/match_participation_status.dart';
import 'package:trus_app/theme/app_colors.dart';

class PlannedDashboardCard extends ConsumerStatefulWidget {
  const PlannedDashboardCard({
    super.key,
    required this.match,
    required this.title,
    required this.initialParticipation,
  });

  final PlannedMatch match;
  final String title;
  final PlannedMatchParticipation initialParticipation;

  @override
  ConsumerState<PlannedDashboardCard> createState() =>
      _PlannedDashboardCardState();
}

class _PlannedDashboardCardState extends ConsumerState<PlannedDashboardCard> {
  late PlannedMatchParticipation participation;

  @override
  void initState() {
    super.initState();
    participation = widget.initialParticipation;
  }

  @override
  void didUpdateWidget(covariant PlannedDashboardCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.match.id != widget.match.id ||
        oldWidget.initialParticipation != widget.initialParticipation) {
      participation = widget.initialParticipation;
    }
  }

  Future<void> _respond(int choice) async {
    try {
      final result = await ref
          .read(plannedMatchApiProvider)
          .respond(
            widget.match.id,
            choice < 2
                ? MatchParticipationStatus.attending
                : choice == 2
                ? MatchParticipationStatus.maybe
                : MatchParticipationStatus.notAttending,
            playing: choice == 0
                ? true
                : choice == 1
                ? false
                : null,
          );
      if (mounted) setState(() => participation = result);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Účast se nepodařilo uložit.')),
        );
      }
    }
  }

  void _openDetail() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: context.appColors.backgroundPrimary,
    builder: (_) => PlannedMatchSheet(id: widget.match.id),
  );

  Future<void> _openParticipation() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: context.appColors.backgroundPrimary,
      builder: (sheetContext) => FutureBuilder<PlannedMatchParticipation>(
        future: ref
            .read(plannedMatchApiProvider)
            .participation(widget.match.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(
              height: 220,
              child: Center(
                child: snapshot.hasError
                    ? const Text('Účast se nepodařilo načíst.')
                    : const CircularProgressIndicator(),
              ),
            );
          }
          final detail = snapshot.data!;
          return SafeArea(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.55,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Účast · ${widget.match.opponent ?? _typeName(widget.match.type)}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _members(
                    context,
                    'Jdou',
                    detail.attendingPlayers,
                    context.appColors.successSolid,
                  ),
                  _members(
                    context,
                    'Možná',
                    detail.maybePlayers,
                    context.appColors.warningSolid,
                  ),
                  _members(
                    context,
                    'Nejdou',
                    detail.notAttendingPlayers,
                    context.appColors.errorSolid,
                  ),
                  PopupMenuButton<int>(
                    tooltip: 'Změnit účast',
                    onSelected: (choice) {
                      Navigator.of(sheetContext).pop();
                      _respond(choice);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 0, child: Text('✓ Jdu a hraju')),
                      PopupMenuItem(
                        value: 1,
                        child: Text('✓ Jdu jako fanoušek'),
                      ),
                      PopupMenuItem(value: 2, child: Text('? Možná')),
                      PopupMenuItem(value: 3, child: Text('✕ Nejdu')),
                    ],
                    child: const ListTile(
                      leading: Icon(Icons.how_to_reg_outlined),
                      title: Text('Změnit účast'),
                      trailing: Icon(Icons.keyboard_arrow_down),
                    ),
                  ),
                  const SizedBox(height: 8),
                  PlannedMatchStatusButton(
                    match: widget.match,
                    onChanged: (result) {
                      Navigator.of(sheetContext).pop();
                      if (!navigateAfterStatusChange(ref.read, result)) {
                        ref.read(homeNotifierProvider.notifier).load();
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _members(
    BuildContext context,
    String label,
    List<String> names,
    Color color,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label (${names.length})',
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        Text(names.isEmpty ? '—' : names.join(', ')),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final match = widget.match;
    final date = match.date.toLocal();
    final status = participation.currentStatus;
    final statusColor = switch (status) {
      MatchParticipationStatus.attending => colors.successSolid,
      MatchParticipationStatus.maybe => colors.warningSolid,
      MatchParticipationStatus.notAttending => colors.errorSolid,
      null => colors.accent,
    };
    final statusLabel = switch (status) {
      MatchParticipationStatus.attending =>
        participation.currentPlaying == false ? 'Fanoušek' : 'Jdu',
      MatchParticipationStatus.maybe => 'Možná',
      MatchParticipationStatus.notAttending => 'Nejdu',
      null => 'Účast',
    };
    String two(int value) => value.toString().padLeft(2, '0');
    return HomeSectionCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 53,
            child: InkWell(
              onTap: _openDetail,
              child: Column(
                children: [
                  if (match.hasPhoto)
                    PlannedMatchPhoto(id: match.id, width: 36, height: 36)
                  else
                    Icon(Icons.event, size: 32, color: colors.accent),
                  const SizedBox(height: 4),
                  Text(
                    '${two(date.day)}.${two(date.month)}.',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${two(date.hour)}:${two(date.minute)}',
                    style: TextStyle(fontSize: 11, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: InkWell(
              onTap: _openDetail,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: colors.accent,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    match.opponent?.isNotEmpty == true
                        ? match.opponent!
                        : _typeName(match.type),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    _typeName(match.type),
                    style: TextStyle(fontSize: 11, color: colors.textSecondary),
                  ),
                  if (match.home != null)
                    Text(
                      match.home! ? 'Doma' : 'Venku',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.textSecondary,
                      ),
                    ),
                  if (match.description?.isNotEmpty == true)
                    Text(
                      match.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 7),
          SizedBox(
            width: 92,
            child: Column(
              children: [
                PopupMenuButton<int>(
                  tooltip: 'Změnit účast',
                  onSelected: _respond,
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 0, child: Text('✓ Jdu a hraju')),
                    PopupMenuItem(value: 1, child: Text('✓ Jdu jako fanoušek')),
                    PopupMenuItem(value: 2, child: Text('? Možná')),
                    PopupMenuItem(value: 3, child: Text('✕ Nejdu')),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.how_to_reg_outlined,
                          size: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            statusLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 14,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _openParticipation,
                  child: Column(
                    children: [
                      _count(
                        Icons.group_outlined,
                        participation.attendingPlayerCount,
                        colors.successSolid,
                      ),
                      _count(
                        Icons.group_outlined,
                        participation.maybePlayerCount,
                        colors.warningSolid,
                      ),
                      _count(
                        Icons.group_outlined,
                        participation.notAttendingPlayerCount,
                        colors.errorSolid,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _count(IconData icon, int count, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 15, color: color),
      const SizedBox(width: 3),
      Text(
        '$count',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    ],
  );
}

String _typeName(String type) => switch (type) {
  'TRAINING' => 'Trénink',
  'FRIENDLY' => 'Přípravný zápas',
  'LEAGUE' => 'Ligový zápas',
  'CUP' => 'Pohár',
  'TEAMBUILDING' => 'Teambuilding',
  _ => type,
};

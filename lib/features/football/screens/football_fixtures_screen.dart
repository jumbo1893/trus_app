import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/football/repository/planned_match_api_service.dart';
import 'package:trus_app/models/api/match/planned_match.dart';
import 'package:trus_app/features/football/screens/planned_match_sheet.dart';
import 'package:trus_app/features/chat/chat_controller.dart';
import 'package:trus_app/features/chat/chat_screen.dart';
import 'package:trus_app/features/main/controller/screen_notifier.dart';
import 'package:trus_app/features/football/screens/planned_match_editor.dart';
import 'package:trus_app/features/football/widgets/planned_match_photo.dart';
import 'package:trus_app/common/utils/calendar.dart';
import 'package:trus_app/common/widgets/football/team_logo.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:trus_app/theme/app_widget_values.dart';

import '../../../common/widgets/screen/custom_consumer_widget.dart';

class FootballFixturesScreen extends CustomConsumerWidget {
  static const String id = "football-fixtures-screen";

  const FootballFixturesScreen({super.key})
    : super(title: "Program zápasů", name: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'Přidat plánovanou událost',
        onPressed: () => _showCreateSheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          children: [
            Expanded(
              child: _PlannedFixtures(
                key: ValueKey(ref.watch(_plannedRefreshProvider)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _showCreateSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: context.appColors.backgroundPrimary,
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * 0.86,
        child: PlannedMatchEditor(
          onSaved: (_) {
            ref.read(_plannedRefreshProvider.notifier).state++;
            Navigator.pop(sheetContext);
          },
          onCancel: () => Navigator.pop(sheetContext),
        ),
      ),
    );
  }
}

final _plannedRefreshProvider = StateProvider<int>((ref) => 0);

class _PlannedFixtures extends ConsumerWidget {
  const _PlannedFixtures({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      FutureBuilder<List<PlannedMatch>>(
        future: ref.read(plannedMatchApiProvider).list(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: TextButton(
                onPressed: () =>
                    ref.read(_plannedRefreshProvider.notifier).state++,
                child: const Text('Program se nepodařilo načíst. Zkusit znovu'),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final now = DateTime.now();
          final items = snapshot.data!
              .where(
                (item) => item.status == 'SCHEDULED' && item.date.isAfter(now),
              )
              .toList();
          if (items.isEmpty) {
            return const Center(
              child: Text('Zatím není naplánovaný žádný budoucí zápas.'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.read(_plannedRefreshProvider.notifier).state++;
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 90),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                Future<void> open({bool edit = false}) async {
                  await showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    showDragHandle: true,
                    backgroundColor: context.appColors.backgroundPrimary,
                    builder: (_) =>
                        PlannedMatchSheet(id: item.id, startEditing: edit),
                  );
                  ref.read(_plannedRefreshProvider.notifier).state++;
                }

                final actions = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.chat_bubble_outline),
                      tooltip: 'Chat plánovaného zápasu',
                      onPressed: () {
                        ref
                            .read(screenNotifierProvider.notifier)
                            .changeByFragmentId(ChatScreen.id);
                        ref
                            .read(chatControllerProvider.notifier)
                            .load('planned-${item.id}');
                      },
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Upravit plánovaný zápas',
                      onPressed: item.isCompleted || item.isInProgress
                          ? null
                          : () => open(edit: true),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.chevron_right),
                      tooltip: 'Detail a H2H',
                      onPressed: () => open(),
                    ),
                  ],
                );
                return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                  child: _ManualPlannedTile(
                    match: item,
                    onTap: () => open(),
                    actions: actions,
                  ),
                );
              },
            ),
          );
        },
      );
}

class _ManualPlannedTile extends StatelessWidget {
  final PlannedMatch match;
  final VoidCallback onTap;
  final Widget actions;

  const _ManualPlannedTile({
    required this.match,
    required this.onTap,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final title = match.opponent?.isNotEmpty == true
        ? match.opponent!
        : _typeName(match.type);
    return Material(
      color: context.appColors.cardBackground,
      borderRadius: AppWidgetValues.borderRadiusXl,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppWidgetValues.borderRadiusXl,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.appColors.cardBackground,
            borderRadius: AppWidgetValues.borderRadiusXl,
            boxShadow: AppWidgetValues.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.appColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: match.opponentLogoUrl != null
                    ? TeamLogo(url: match.opponentLogoUrl, size: 46)
                    : match.hasPhoto
                    ? PlannedMatchPhoto(id: match.id, width: 50, height: 56)
                    : Icon(
                        Icons.event,
                        color: context.appColors.accent,
                        size: 30,
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.appColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      match.isInProgress
                          ? 'Probíhá · ${matchDateToString(match.date, includeTime: true)}'
                          : matchDateToString(match.date, includeTime: true),
                      style: TextStyle(
                        color: context.appColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      '${match.footballRound == null ? _typeName(match.type) : '${match.footballRound}. kolo'}${match.home == null
                          ? ''
                          : match.home!
                          ? ' · DOMA'
                          : ' · VENKU'}${match.footballStadium?.isNotEmpty == true ? ' · ${match.footballStadium}' : ''}',
                      style: TextStyle(
                        color: context.appColors.textMuted,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              actions,
            ],
          ),
        ),
      ),
    );
  }
}

String _typeName(String type) => switch (type) {
  'TRAINING' => 'Trénink',
  'FRIENDLY' => 'Přípravný zápas',
  'LEAGUE' => 'Ligový zápas',
  'CUP' => 'Pohár',
  'TEAMBUILDING' => 'Teambuilding',
  _ => type,
};

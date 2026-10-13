import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:trus_app/theme/app_widget_values.dart';

import '../controller/football_table_team_detail_notifier.dart';
import 'table_team_detail_matches_screen.dart';

class TableTeamMutualMatchesScreen extends ConsumerWidget {
  const TableTeamMutualMatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamId = ref.watch(screenVariablesNotifierProvider).tableTeam.id!;
    final detail = ref.watch(footballTableTeamDetailNotifierProvider(teamId)).detail;
    if (detail == null) return const Center(child: CircularProgressIndicator());
    final colors = context.appColors;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Container(
          width: double.infinity,
          padding: AppWidgetValues.cardPadding,
          decoration: BoxDecoration(color: colors.cardBackground,
            borderRadius: AppWidgetValues.borderRadiusXl,
            boxShadow: AppWidgetValues.cardShadow),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Vzájemné zápasy', style: TextStyle(color: colors.textPrimary,
              fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            Text('BILANCE V / R / P', style: TextStyle(color: colors.textMuted,
              fontSize: 11, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(detail.aggregateMatches?.isNotEmpty == true ? detail.aggregateMatches! : '—',
              style: TextStyle(color: colors.accent, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Text('Celkové skóre: ${detail.aggregateScore?.isNotEmpty == true ? detail.aggregateScore : '—'}',
              style: TextStyle(color: colors.textSecondary, fontSize: 14)),
          ]),
        ),
      ),
      Expanded(child: TeamMatchList(
        matches: detail.mutualMatches,
        teamId: detail.tableTeam.teamId,
        emptyTitle: 'Žádné vzájemné zápasy',
        emptyText: 'Bilance se zobrazí po prvním vzájemném zápase.',
      )),
    ]);
  }
}

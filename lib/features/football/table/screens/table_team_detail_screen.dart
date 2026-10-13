import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:trus_app/theme/app_widget_values.dart';

import '../controller/football_table_team_detail_notifier.dart';

class TableTeamDetailScreen extends ConsumerWidget {
  const TableTeamDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamId = ref.watch(screenVariablesNotifierProvider).tableTeam.id!;
    final detail = ref.watch(footballTableTeamDetailNotifierProvider(teamId)).detail;
    if (detail == null) return const Center(child: CircularProgressIndicator());
    final team = detail.tableTeam;
    final scorer = detail.bestScorer;
    final colors = context.appColors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _Card(child: Row(children: [
          Container(width: 64, height: 64, alignment: Alignment.center,
            decoration: BoxDecoration(color: colors.accentSoft, borderRadius: BorderRadius.circular(18)),
            child: Icon(Icons.shield_rounded, color: colors.accent, size: 32)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(team.teamName, style: TextStyle(color: colors.textPrimary, fontSize: 21, fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            Text('${team.rank}. místo v tabulce', style: TextStyle(color: colors.textSecondary, fontSize: 14)),
          ])),
        ])),
        AppWidgetValues.section,
        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Sezóna', style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _Stat('BODY', '${team.points}', true)),
            Expanded(child: _Stat('ZÁPASY', '${team.matches}', false)),
            Expanded(child: _Stat('SKÓRE', '${team.goalsScored}:${team.goalsReceived}', false)),
          ]),
          const SizedBox(height: 18),
          Divider(color: colors.border, height: 1),
          const SizedBox(height: 16),
          Text('VÝHRY / REMÍZY / PROHRY', style: TextStyle(color: colors.textMuted, fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 5),
          Text('${team.wins} / ${team.draws} / ${team.losses}', style: TextStyle(color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
          if (team.penalty.trim().isNotEmpty && team.penalty.trim() != '0') ...[
            const SizedBox(height: 14),
            Text('Bodový trest: ${team.penalty}', style: TextStyle(color: colors.warningForeground, fontWeight: FontWeight.w600)),
          ],
        ])),
        AppWidgetValues.section,
        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tým', style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _InfoRow(Icons.cake_outlined, 'Průměrný rok narození', '${detail.averageBirthYear}'),
          if (scorer != null) ...[
            const SizedBox(height: 16),
            _InfoRow(Icons.sports_soccer_rounded, 'Nejlepší střelec', '${scorer.player.name} · ${scorer.totalGoals} gólů'),
          ],
        ])),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: AppWidgetValues.cardPadding,
    decoration: BoxDecoration(color: context.appColors.cardBackground,
      borderRadius: AppWidgetValues.borderRadiusXl, boxShadow: AppWidgetValues.cardShadow),
    child: child,
  );
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.highlight);
  final String label;
  final String value;
  final bool highlight;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(color: context.appColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700)),
    const SizedBox(height: 5),
    Text(value, style: TextStyle(color: highlight ? context.appColors.accent : context.appColors.textPrimary,
      fontSize: 21, fontWeight: FontWeight.w800)),
  ]);
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, color: context.appColors.accent, size: 22),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: context.appColors.textMuted, fontSize: 12)),
      const SizedBox(height: 3),
      Text(value, style: TextStyle(color: context.appColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
    ])),
  ]);
}

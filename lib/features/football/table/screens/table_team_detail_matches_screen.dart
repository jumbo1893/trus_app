import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/football/widget/football_fixture_list_tile.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/theme/app_colors.dart';

import '../controller/football_table_team_detail_notifier.dart';
import '../football_team_detail_tab.dart';

class TableTeamDetailMatchesScreen extends ConsumerWidget {
  const TableTeamDetailMatchesScreen({super.key, required this.tab});
  final FootballTeamDetailTab tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamId = ref.watch(screenVariablesNotifierProvider).tableTeam.id!;
    final detail = ref.watch(footballTableTeamDetailNotifierProvider(teamId)).detail;
    if (detail == null) return const Center(child: CircularProgressIndicator());
    final matches = tab == FootballTeamDetailTab.nextMatches
        ? detail.nextMatches : detail.pastMatches;
    return TeamMatchList(
      matches: matches,
      teamId: detail.tableTeam.teamId,
      emptyTitle: tab == FootballTeamDetailTab.nextMatches
          ? 'Žádné naplánované zápasy' : 'Žádné výsledky',
      emptyText: tab == FootballTeamDetailTab.nextMatches
          ? 'Program týmu se zatím nezobrazuje.' : 'Tým zatím nemá odehrané zápasy.',
    );
  }
}

class TeamMatchList extends StatelessWidget {
  const TeamMatchList({super.key, required this.matches, required this.teamId,
    required this.emptyTitle, required this.emptyText});
  final List<FootballMatchApiModel> matches;
  final int teamId;
  final String emptyTitle;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.event_busy_rounded, size: 42, color: context.appColors.textMuted),
          const SizedBox(height: 12),
          Text(emptyTitle, textAlign: TextAlign.center,
            style: TextStyle(color: context.appColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(emptyText, textAlign: TextAlign.center,
            style: TextStyle(color: context.appColors.textSecondary)),
        ]),
      ));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: matches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => FootballFixtureListTile(
        match: matches[index], userTeamId: teamId),
    );
  }
}

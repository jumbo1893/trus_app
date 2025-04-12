import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/rows/view/row_text_view_stream.dart';
import 'package:trus_app/features/football/table/widget/i_football_team_detail_key.dart';
import 'package:trus_app/features/mixin/view_controller_mixin.dart';

class TableTeamDetailWidget<T> extends ConsumerWidget {
  final Size size;
  final IFootballTeamDetailKey iFootballTeamDetailKey;
  final ViewControllerMixin viewMixin;

  const TableTeamDetailWidget({
    Key? key,
    required this.size,
    required this.iFootballTeamDetailKey,
    required this.viewMixin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double padding = 8.0;
    return Column(
      children: [
        RowTextViewStream(
          key: const ValueKey('team_name_text'),
          size: size,
          textFieldText: "Tým:",
          padding: padding,
          viewMixin: viewMixin,
          hashKey: iFootballTeamDetailKey.nameKey(),
        ),
        RowTextViewStream(
          key: const ValueKey('team_league_ranking_text'),
          size: size,
          textFieldText: "Pořadí:",
          padding: padding,
          viewMixin: viewMixin,
          hashKey: iFootballTeamDetailKey.leagueRanking(),
        ),
        const SizedBox(height: 10),
        RowTextViewStream(
          key: const ValueKey('team_average_year_text'),
          size: size,
          padding: padding,
          textFieldText: 'Průměrný rok narození týmu:',
          viewMixin: viewMixin,
          hashKey: iFootballTeamDetailKey.averageBirthYear(),
          allowWrap: true,
        ),
        const SizedBox(height: 10),
        RowTextViewStream(
          key: const ValueKey('team_best_scorer_text'),
          size: size,
          padding: padding,
          textFieldText: 'Nejlepší střelec:',
          viewMixin: viewMixin,
          hashKey: iFootballTeamDetailKey.bestPlayer(),
          allowWrap: true,
        ),
      ],
    );
  }
}

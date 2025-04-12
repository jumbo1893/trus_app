import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/rows/view/row_text_view_stream.dart';
import 'package:trus_app/features/football/widget/i_football_match_detail_hash_key.dart';
import 'package:trus_app/features/mixin/view_controller_mixin.dart';

class FootballMatchHomeAwayViewWidget<T> extends ConsumerWidget {
  final Size size;
  final ViewControllerMixin viewMixin;
  final IFootballMatchDetailHashKey iFootballMatchDetailHashKey;
  final bool home;

  const FootballMatchHomeAwayViewWidget({
    Key? key,
    required this.size,
    required this.viewMixin,
    required this.iFootballMatchDetailHashKey,
    required this.home,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double padding = 8.0;
    return Column(
      children: [
        RowTextViewStream(
          key: const ValueKey('football_best_player_text'),
          size: size,
          textFieldText: "Hvězda zápasu:",
          padding: padding,
          viewMixin: viewMixin,
          hashKey: iFootballMatchDetailHashKey.bestPlayer(home),
          allowWrap: true,
        ),
        RowTextViewStream(
          key: const ValueKey('football_goal_text'),
          size: size,
          textFieldText: "Střelci:",
          padding: padding,
          viewMixin: viewMixin,
          hashKey: iFootballMatchDetailHashKey.goalScorers(home),
          allowWrap: true,
          showIfEmptyText: false,
        ),
        const SizedBox(height: 10),
        RowTextViewStream(
          key: const ValueKey('football_own_goal_text'),
          size: size,
          padding: padding,
          textFieldText: 'Vlastňáky:',
          viewMixin: viewMixin,
          hashKey: iFootballMatchDetailHashKey.ownGoalPlayers(home),
          allowWrap: true,
          showIfEmptyText: false,
        ),
        const SizedBox(height: 10),
        RowTextViewStream(
          key: const ValueKey('football_yellow_card_text'),
          size: size,
          padding: padding,
          textFieldText: "Žluté:",
          viewMixin: viewMixin,
          hashKey: iFootballMatchDetailHashKey.yellowCardPlayers(home),
          allowWrap: true,
          showIfEmptyText: false,
        ),
        RowTextViewStream(
          key: const ValueKey('football_red_card_text'),
          size: size,
          padding: padding,
          textFieldText: "Červené:",
          viewMixin: viewMixin,
          hashKey: iFootballMatchDetailHashKey.redCardPlayers(home),
          allowWrap: true,
          showIfEmptyText: false,
        ),
      ],
    );
  }
}

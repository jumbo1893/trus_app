import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/football/widget/football_match_detail_view_widget.dart';
import 'package:trus_app/features/football/widget/football_match_home_away_view_widget.dart';

import '../../../common/widgets/builder/column_future_builder.dart';
import '../../match/controller/match_controller.dart';
import '../controller/football_match_controller.dart';

class FootballMatchDetailScreen extends ConsumerStatefulWidget {
  const FootballMatchDetailScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<FootballMatchDetailScreen> createState() =>
      _FootballMatchDetailScreenState();
}

class _FootballMatchDetailScreenState
    extends ConsumerState<FootballMatchDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQueryData.fromView(WidgetsBinding.instance.window).size;
    return ColumnFutureBuilder(
      loadModelFuture: ref
          .watch(footballMatchControllerProvider)
          .setFootballMatch(
              ref.read(matchControllerProvider).returnFootballMatch()),
      columns: [
        if (ref.read(matchControllerProvider).getMatchDetailOptionForFootballDetail() == 1) ...[
          FootballMatchDetailViewWidget(
            size: size,
            iFootballMatchDetailHashKey:
                ref.read(footballMatchControllerProvider),
            viewMixin: ref.watch(footballMatchControllerProvider),
          ),
          const SizedBox(height: 10),
        ],
        if (ref.read(matchControllerProvider).getMatchDetailOptionForFootballDetail() == 2) ...[
          FootballMatchHomeAwayViewWidget(
            size: size,
            iFootballMatchDetailHashKey:
            ref.read(footballMatchControllerProvider),
            viewMixin: ref.watch(footballMatchControllerProvider),
            home: true,
          ),
          const SizedBox(height: 10),
        ],
        if (ref.read(matchControllerProvider).getMatchDetailOptionForFootballDetail() == 3) ...[
          FootballMatchHomeAwayViewWidget(
            size: size,
            iFootballMatchDetailHashKey:
            ref.read(footballMatchControllerProvider),
            viewMixin: ref.watch(footballMatchControllerProvider),
            home: false,
          ),
          const SizedBox(height: 10),
        ],
      ],

      loadingScreen: null,
    );
  }
}

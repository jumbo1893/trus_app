import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/football/table/controller/football_table_team_controller.dart';

import '../../../../common/widgets/builder/column_future_builder.dart';
import '../../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../widget/table_team_detail_widget.dart';


class TableTeamDetailScreen extends CustomConsumerStatefulWidget {
  static const String id = "table-team-detail-screen";

  const TableTeamDetailScreen({
    Key? key,
  }) : super(key: key, title: "Detail týmu", name: id);

  @override
  ConsumerState<TableTeamDetailScreen> createState() => _TableTeamDetailScreenState();
}

class _TableTeamDetailScreenState extends ConsumerState<TableTeamDetailScreen> {
  @override
  Widget build(BuildContext context) {
      final size =
          MediaQueryData.fromView(WidgetsBinding.instance.window).size;
      return ColumnFutureBuilder(
        loadModelFuture: ref.watch(footballTableTeamControllerProvider).initNewTeam(),
        columns: [
          TableTeamDetailWidget(
              size: size,
              iFootballTeamDetailKey: ref.read(footballTableTeamControllerProvider),
              viewMixin: ref.watch(footballTableTeamControllerProvider),
          ),
          const SizedBox(height: 10),
        ],
        loadingScreen: null,
      );
  }
}

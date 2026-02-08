import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_state.dart';
import 'package:trus_app/models/api/football/table_team_api_model.dart';

class FootballTableListState implements IListviewState {
  final AsyncValue<List<TableTeamApiModel>> tableTeams;
  final TableTeamApiModel? selectedTableTeam;

  FootballTableListState({
    required this.tableTeams,
    required this.selectedTableTeam,
  });

  factory FootballTableListState.initial() => FootballTableListState(
    tableTeams: const AsyncValue.loading(),
    selectedTableTeam: null,
      );

  FootballTableListState copyWith({
    AsyncValue<List<TableTeamApiModel>>? tableTeams,
    TableTeamApiModel? selectedTableTeam,
  }) {
    return FootballTableListState(
      tableTeams: tableTeams ?? this.tableTeams,
      selectedTableTeam: selectedTableTeam ?? this.selectedTableTeam,
    );
  }

  @override
  AsyncValue<List<TableTeamApiModel>> getListViewItems() {
    return tableTeams;
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/dropdown/i_dropdown_notifier.dart';
import 'package:trus_app/features/football/repository/football_api_service.dart';
import 'package:trus_app/features/general/notifier/app_notifier.dart';

import '../../../common/widgets/notifier/dropdown/dropdown_state.dart';
import '../../../models/api/football/football_player_api_model.dart';
import '../../../models/api/interfaces/dropdown_item.dart';

final footballPlayerDropdownNotifierProvider =
StateNotifierProvider<FootballPlayerDropdownNotifier, DropdownState>((ref) {
  return FootballPlayerDropdownNotifier(
    ref,
    ref.read(footballApiServiceProvider),
  );
});

class FootballPlayerDropdownNotifier extends AppNotifier<DropdownState> implements IDropdownNotifier {
  final FootballApiService api;

  FootballPlayerDropdownNotifier(Ref ref, this.api) : super(ref, DropdownState.initial()) {
    Future.microtask(() =>  loadFootballPlayers());
  }

  Future<void> loadFootballPlayers() async {
    final players = await runUiWithResult<List<FootballPlayerApiModel>>(
          () => api.getFootballPlayers(),
      showLoading: false,
      successSnack: null,
    );
    state = state.copyWith(
      dropdownItems: AsyncValue.data(players),
      selected: players.first,
    );
  }

  @override
  void selectDropdown(DropdownItem season) {
    state = state.copyWith(selected: season);
  }
}

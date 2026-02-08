import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/dropdown/i_dropdown_notifier.dart';
import 'package:trus_app/features/football/repository/football_api_service.dart';

import '../../../common/widgets/notifier/dropdown/dropdown_state.dart';
import '../../../models/api/interfaces/dropdown_item.dart';

final footballPlayerDropdownNotifierProvider =
StateNotifierProvider<FootballPlayerDropdownNotifier, DropdownState>((ref) {
  return FootballPlayerDropdownNotifier(
    ref.read(footballApiServiceProvider),
  );
});

class FootballPlayerDropdownNotifier extends StateNotifier<DropdownState> implements IDropdownNotifier {
  final FootballApiService api;

  FootballPlayerDropdownNotifier(this.api) : super(DropdownState.initial()) {
    loadSeasons();
  }

  Future<void> loadSeasons() async {
    try {
      final players = await api.getFootballPlayers();
      state = state.copyWith(
        dropdownItems: AsyncValue.data(players),
        selected: players.first,
      );
    } catch (e, st) {
      state = state.copyWith(dropdownItems: AsyncValue.error(e, st));
    }
  }

  @override
  void selectDropdown(DropdownItem season) {
    state = state.copyWith(selected: season);
  }
}

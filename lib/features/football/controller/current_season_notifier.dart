import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/dropdown/i_dropdown_notifier.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/season_api_model.dart';

import '../../../common/widgets/notifier/dropdown/dropdown_state.dart';
import '../../../models/api/interfaces/dropdown_item.dart';

final currentSeasonNotifierProvider =
StateNotifierProvider<CurrentSeasonNotifier, DropdownState>((ref) {
  return CurrentSeasonNotifier(
  );
});

class CurrentSeasonNotifier extends StateNotifier<DropdownState> implements IDropdownNotifier {

  CurrentSeasonNotifier() : super(DropdownState.initial()) {
    loadSeasons();
  }

  Future<void> loadSeasons() async {
    DropdownItem currentSeason = SeasonApiModel(name: "Aktuální sezona", fromDate: DateTime(0), toDate: DateTime(0), id: -1);
    DropdownItem allSeason = SeasonApiModel(name: "Všechny zápasy", fromDate: DateTime(0), toDate: DateTime(0), id: allSeasonId);
    List<DropdownItem> seasons = [currentSeason, allSeason];
    state = state.copyWith(
      dropdownItems: AsyncValue.data(seasons),
      selected: seasons.first,
    );
  }

  @override
  void selectDropdown(DropdownItem season) {
    state = state.copyWith(selected: season);
  }
}

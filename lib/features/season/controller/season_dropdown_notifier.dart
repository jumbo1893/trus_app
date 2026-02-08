import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/dropdown/i_dropdown_notifier.dart';
import 'package:trus_app/features/season/season_args.dart';

import '../../../common/utils/season_util.dart';
import '../../../common/widgets/notifier/dropdown/dropdown_state.dart';
import '../../../models/api/interfaces/dropdown_item.dart';
import '../repository/season_api_service.dart';

final seasonDropdownNotifierProvider = StateNotifierProvider
    .family<SeasonDropdownNotifier, DropdownState, SeasonArgs>((ref, args) {
  return SeasonDropdownNotifier(
      ref.read(seasonApiServiceProvider),
      args
  );
});

class SeasonDropdownNotifier extends StateNotifier<DropdownState>
    implements IDropdownNotifier {
  final SeasonApiService api;
  final SeasonArgs args;

  SeasonDropdownNotifier(this.api, this.args)
      : super(DropdownState.initial()) {
    loadSeasons(args);
  }

  Future<void> loadSeasons(SeasonArgs args) async {
    try {
      final seasons = await api.getSeasons2(args);
      state = state.copyWith(
        dropdownItems: AsyncValue.data(seasons),
        selected: returnCurrentSeason(seasons),
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

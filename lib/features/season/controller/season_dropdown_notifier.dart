import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/dropdown/i_dropdown_notifier.dart';
import 'package:trus_app/features/general/notifier/app_notifier.dart';
import 'package:trus_app/features/season/season_args.dart';

import '../../../common/utils/season_util.dart';
import '../../../common/widgets/notifier/dropdown/dropdown_state.dart';
import '../../../models/api/interfaces/dropdown_item.dart';
import '../../../models/api/season_api_model.dart';
import '../repository/season_api_service.dart';

final seasonDropdownNotifierProvider = StateNotifierProvider
    .family<SeasonDropdownNotifier, DropdownState, SeasonArgs>((ref, args) {
  return SeasonDropdownNotifier(
    ref,
      ref.read(seasonApiServiceProvider),
      args
  );
});

class SeasonDropdownNotifier extends AppNotifier<DropdownState>
    implements IDropdownNotifier {
  final SeasonApiService api;
  final SeasonArgs args;

  SeasonDropdownNotifier(Ref ref, this.api, this.args)
      : super(ref, DropdownState.initial()) {
    loadSeasons(args);
  }

  Future<void> loadSeasons(SeasonArgs args) async {
    final seasons = await runUiWithResult<List<SeasonApiModel>>(
              () => api.getSeasons2(args),
          showLoading: false,
          successSnack: null,
        );
    state = state.copyWith(
      dropdownItems: AsyncValue.data(seasons),
      selected: returnCurrentSeason(seasons),
    );
  }

  @override
  void selectDropdown(DropdownItem season) {
    state = state.copyWith(selected: season);
  }
}

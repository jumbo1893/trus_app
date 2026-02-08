import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_notifier.dart';
import 'package:trus_app/features/general/notifier/safe_state_notifier.dart';
import 'package:trus_app/features/match/match_notifier_args.dart';
import 'package:trus_app/features/match/repository/match_repository.dart';
import 'package:trus_app/features/match/state/match_list_state.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';

import '../../../common/widgets/notifier/dropdown/dropdown_state.dart';
import '../../../models/api/season_api_model.dart';
import '../../main/screen_controller.dart';
import '../../season/controller/season_dropdown_notifier.dart';
import '../../season/season_args.dart';
import '../screens/match_detail_screen.dart';

final matchNotifierProvider =
StateNotifierProvider.autoDispose<MatchNotifier, MatchListState>((ref) {
  return MatchNotifier(
    ref.read(matchRepositoryProvider),
    ref.read(screenControllerProvider),
    ref
  );
});

class MatchNotifier extends SafeStateNotifier<MatchListState>
    implements IListviewNotifier {

  final Ref ref;
  final MatchRepository repository;
  final ScreenController screenController;

  MatchNotifier(this.repository, this.screenController, this.ref)
      : super(MatchListState.initial()) {
    ref.listen<DropdownState>(seasonDropdownNotifierProvider(const SeasonArgs(false, true, true)), (_, next) {
      SeasonApiModel? season = next.selected as SeasonApiModel?;
      if (season != null) {
        _loadMatches(season.id!);
      }
    }, fireImmediately: true);

  }

  Future<void> _loadMatches(int seasonId) async {
    if (!mounted) return;

    final cached = repository.getCachedList(seasonId);
    if (cached != null) {
      safeSetState(
        state.copyWith(
          matches: AsyncValue.data(cached),
        ),
      );
    } else {
      safeSetState(
        state.copyWith(
          matches: const AsyncValue.loading(),
        ),
      );
    }
    final result = await AsyncValue.guard(
          () => repository.fetchList(seasonId),
    );

    if (!mounted) return;
    safeSetState(
      state.copyWith(
        matches: result,
      ),
    );
  }

  @override
  void selectListviewItem(ModelToString model) {
    state = state.copyWith(
      selectedMatch: model as MatchApiModel,
    );
    screenController.setMatchNotifierArgs(MatchNotifierArgs.footballMatchDetailByMatchId(model.id!));
    screenController.changeFragment(MatchDetailScreen.id);
  }
}

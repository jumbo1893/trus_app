import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_notifier.dart';
import 'package:trus_app/features/football/repository/football_repository.dart';
import 'package:trus_app/features/football/state/football_fixtures_list_state.dart';
import 'package:trus_app/features/general/notifier/safe_state_notifier.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../../main/screen_controller.dart';
import '../../match/match_notifier_args.dart';
import '../../match/screens/match_detail_screen.dart';

final footballFixturesNotifier =
    StateNotifierProvider.autoDispose<FootballFixturesNotifier, FootballFixturesListState>((ref) {
  return FootballFixturesNotifier(
    ref.read(footballRepositoryProvider),
    ref.read(screenControllerProvider),
  );
});

class FootballFixturesNotifier extends SafeStateNotifier<FootballFixturesListState>
    implements IListviewNotifier {
  final FootballRepository repository;
  final ScreenController screenController;

  FootballFixturesNotifier(this.repository, this.screenController)
      : super(FootballFixturesListState.initial()) {
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    if (!mounted) return;

    final cached = repository.getCachedList();
    if (cached != null) {
      safeSetState(
        state.copyWith(
          footballMatches: AsyncValue.data(cached),
        ),
      );
    } else {
      safeSetState(
        state.copyWith(
          footballMatches: const AsyncValue.loading(),
        ),
      );
    }
    final result = await AsyncValue.guard(
          () => repository.fetchList(),
    );

    if (!mounted) return;
    safeSetState(
      state.copyWith(
        footballMatches: result,
      ),
    );
  }

  @override
  selectListviewItem(ModelToString model) {
    screenController.setMatchNotifierArgs(MatchNotifierArgs.footballMatchDetail(model as FootballMatchApiModel));
  screenController.changeFragment(MatchDetailScreen.id);
  }
}

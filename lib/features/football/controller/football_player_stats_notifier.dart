import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/football/controller/football_player_dropdown_notifier.dart';
import 'package:trus_app/features/football/repository/football_api_service.dart';
import 'package:trus_app/features/general/state/model_to_string_state.dart';
import 'package:trus_app/models/api/football/football_player_api_model.dart';

import '../../../common/widgets/notifier/dropdown/dropdown_state.dart';

final footballPlayerStatsNotifierProvider =
StateNotifierProvider<FootballPlayerStatsNotifier, ModelToStringState>((ref) {
  return FootballPlayerStatsNotifier(
    ref: ref,
    footballApiService: ref.read(footballApiServiceProvider),
  );
});

class FootballPlayerStatsNotifier extends StateNotifier<ModelToStringState> {
  final Ref ref;
  final FootballApiService footballApiService;

  FootballPlayerStatsNotifier({
    required this.ref,
    required this.footballApiService,
  }) : super(ModelToStringState.initial()) {
    ref.listen<DropdownState>(footballPlayerDropdownNotifierProvider, (_, next) {
      FootballPlayerApiModel? player = next.selected as FootballPlayerApiModel?;
      if (player != null) {
        _loadPlayerFacts(player.id!);
      }
    }, fireImmediately: true);
  }

  Future<void> _loadPlayerFacts(int playerId) async {
    state = state.copyWith(
      stats: const AsyncValue.loading(),
    );
    final response = await footballApiService.getPlayerFacts(
      playerId,
    );
    state = state.copyWith(
      stats: AsyncValue.data(response),
    );
  }
}

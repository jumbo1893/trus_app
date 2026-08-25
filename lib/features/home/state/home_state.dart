import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/api/app_notice/app_notice.dart';
import '../../../models/api/home/home_setup.dart';
import '../../../models/api/player/player_api_model.dart';

class HomeState {
  final AsyncValue<HomeSetup> setup;
  final AsyncValue<AppNotice?> appNotice;
  final PlayerApiModel? selectedChartPlayer;
  final AsyncValue<List<PlayerApiModel>> chartPlayers;

  const HomeState({
    required this.setup,
    required this.appNotice,
    required this.chartPlayers,
    this.selectedChartPlayer,
  });

  factory HomeState.initial() => const HomeState(
    setup: AsyncValue.loading(),
    appNotice: AsyncValue.loading(),
    chartPlayers: AsyncValue.data([]),
  );

  HomeState copyWith({
    AsyncValue<HomeSetup>? setup,
    AsyncValue<AppNotice?>? appNotice,
    AsyncValue<List<PlayerApiModel>>? chartPlayers,
    PlayerApiModel? selectedChartPlayer,
  }) {
    return HomeState(
      setup: setup ?? this.setup,
      appNotice: appNotice ?? this.appNotice,
      chartPlayers: chartPlayers ?? this.chartPlayers,
      selectedChartPlayer: selectedChartPlayer ?? this.selectedChartPlayer,
    );
  }
}

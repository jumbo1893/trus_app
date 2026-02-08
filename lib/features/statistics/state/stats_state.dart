import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_state.dart';
import 'package:trus_app/features/statistics/stats_level.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';
import 'package:trus_app/models/helper/title_and_text.dart';

import '../../main/state_back_condition.dart';

class StatsState implements StateBackCondition, IListviewState {
  final AsyncValue<List<ModelToString>> stats;
  final AsyncValue<TitleAndText?> overall;
  final String? filter;
  final bool orderDescending;
  final ModelToString? selectedModel;
  final int? selectedModelId;
  final int? selectedDetailedModelId;
  final String api;
  final bool matchOrPlayer;
  final StatsLevel level;
  bool get isDetail => level != StatsLevel.root;

  StatsState({
    required this.stats,
    required this.overall,
    required this.filter,
    required this.orderDescending,
    required this.selectedModel,
    required this.selectedModelId,
    required this.selectedDetailedModelId,
    required this.api,
    required this.matchOrPlayer,
    required this.level,
  });

  factory StatsState.initial(String api, bool matchOrPlayer) => StatsState(
      stats: const AsyncValue.loading(),
      overall: const AsyncValue.data(null),
      filter: null,
      orderDescending: true,
      selectedModel: null,
      selectedModelId: null,
      selectedDetailedModelId: null,
      api: api,
      level: StatsLevel.root,
      matchOrPlayer: matchOrPlayer);

  StatsState copyWith({
    AsyncValue<List<ModelToString>>? stats,
    AsyncValue<TitleAndText?>? overall,
    String? filter,
    bool? orderDescending,
    ModelToString? selectedModel,
    int? selectedModelId,
    ModelToString? selectedDetailedModel,
    int? selectedDetailedModelId,
    StatsLevel? level,
  }) {
    return StatsState(
        stats: stats ?? this.stats,
        overall: overall ?? this.overall,
        filter: filter ?? this.filter,
        orderDescending: orderDescending ?? this.orderDescending,
        selectedModel: selectedModel ?? this.selectedModel,
        selectedModelId: selectedModelId ?? this.selectedModelId,
        selectedDetailedModelId: selectedDetailedModelId ?? this.selectedDetailedModelId,
        api: api,
        level: level ?? this.level,
        matchOrPlayer: matchOrPlayer);
  }

  @override
  bool isRootBack() {
    return isDetail;
  }

  @override
  AsyncValue<List<ModelToString>> getListViewItems() {
    return stats;
  }
}

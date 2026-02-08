import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_state.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

class ModelToStringState implements IListviewState {
  final AsyncValue<List<ModelToString>> stats;

  ModelToStringState({
    required this.stats,
  });

  factory ModelToStringState.initial() => ModelToStringState(
        stats: const AsyncValue.loading(),
      );

  ModelToStringState copyWith({
    AsyncValue<List<ModelToString>>? stats,
  }) {
    return ModelToStringState(
      stats: stats ?? this.stats,
    );
  }

  @override
  AsyncValue<List<ModelToString>> getListViewItems() {
    return stats;
  }
}

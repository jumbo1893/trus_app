import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_state.dart';
import 'package:trus_app/models/api/fine_api_model.dart';

class FineListState implements IListviewState {
  final AsyncValue<List<FineApiModel>> fines;
  final FineApiModel? selectedFine;

  FineListState({
    required this.fines,
    required this.selectedFine,
  });

  factory FineListState.initial() => FineListState(
        fines: const AsyncValue.loading(),
        selectedFine: null,
      );

  FineListState copyWith({
    AsyncValue<List<FineApiModel>>? fines,
    FineApiModel? selectedFine,
  }) {
    return FineListState(
      fines: fines ?? this.fines,
      selectedFine: selectedFine ?? this.selectedFine,
    );
  }

  @override
  AsyncValue<List<FineApiModel>> getListViewItems() {
    return fines;
  }
}

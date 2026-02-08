import 'package:trus_app/models/api/fine_api_model.dart';

import '../../../common/widgets/notifier/loader/loading_state.dart';
import '../../general/state/base_crud_state.dart';

class FineEditState extends BaseCrudState<FineApiModel> {
  final String name;
  final String amount;
  final bool inactive;

  const FineEditState({
    required this.name,
    required this.amount,
    required this.inactive,
    FineApiModel? model,
    super.loading,
    super.errors,
    super.successMessage,
  }) : super(model: model);

  @override
  FineEditState copyWith({
    String? name,
    String? amount,
    bool? inactive,
    FineApiModel? model,
    LoadingState? loading,
    Map<String, String>? errors,
    String? successMessage,
  }) {
    return FineEditState(
      name: name ?? this.name,
      amount: amount ?? this.amount,
      inactive: inactive ?? this.inactive,
      model: model ?? this.model,
      loading: loading ?? this.loading,
      errors: errors ?? this.errors,
      successMessage: successMessage,
    );
  }
}

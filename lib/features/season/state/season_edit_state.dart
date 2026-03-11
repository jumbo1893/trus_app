import '../../../models/api/season_api_model.dart';
import '../../general/state/base_crud_state.dart';

class SeasonEditState extends BaseCrudState<SeasonApiModel> {
  final String name;
  final DateTime from;
  final DateTime to;

  const SeasonEditState({
    required this.name,
    required this.from,
    required this.to,
    SeasonApiModel? model,
    super.errors,
  }) : super(model: model);

  @override
  SeasonEditState copyWith({
    String? name,
    DateTime? from,
    DateTime? to,
    SeasonApiModel? model,
    Map<String, String>? errors,
  }) {
    return SeasonEditState(
      name: name ?? this.name,
      from: from ?? this.from,
      to: to ?? this.to,
      model: model ?? this.model,
      errors: errors ?? this.errors,
    );
  }
}

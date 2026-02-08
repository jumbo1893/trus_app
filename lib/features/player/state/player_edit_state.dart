import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

import '../../../common/widgets/notifier/dropdown/i_dropdown_state.dart';
import '../../../common/widgets/notifier/loader/loading_state.dart';
import '../../../models/api/achievement/achievement_player_detail.dart';
import '../../../models/api/interfaces/dropdown_item.dart';
import '../../../models/helper/title_and_text.dart';
import '../../general/state/base_crud_state.dart';

class PlayerEditState extends BaseCrudState<PlayerApiModel> implements IDropdownState {
  final String name;
  final DateTime birthdate;
  final bool fan;
  final bool active;
  final AsyncValue<List<DropdownItem>> footballPlayers;
  final DropdownItem? selectedFootballPlayer;
  final AchievementPlayerDetail? achievementPlayerDetail;
  final List<TitleAndText> playerStats;

  const PlayerEditState({
    required this.name,
    required this.birthdate,
    required this.fan,
    required this.active,
    required this.footballPlayers,
    this.selectedFootballPlayer,
    this.achievementPlayerDetail,
    required this.playerStats,
    PlayerApiModel? model,
    super.loading,
    super.errors,
    super.successMessage,
  }) : super(model: model);

  @override
  PlayerEditState copyWith({
    String? name,
    DateTime? birthdate,
    bool? fan,
    bool? active,
    AsyncValue<List<DropdownItem>>? footballPlayers,
    DropdownItem? selectedFootballPlayer,
    AchievementPlayerDetail? achievementPlayerDetail,
    List<TitleAndText>? playerStats,
    PlayerApiModel? model,
    LoadingState? loading,
    Map<String, String>? errors,
    String? successMessage,
  }) {
    return PlayerEditState(
      name: name ?? this.name,
      birthdate: birthdate ?? this.birthdate,
      fan: fan ?? this.fan,
      active: active ?? this.active,
      footballPlayers: footballPlayers ?? this.footballPlayers,
      selectedFootballPlayer: selectedFootballPlayer ?? this.selectedFootballPlayer,
      achievementPlayerDetail: achievementPlayerDetail ?? this.achievementPlayerDetail,
      playerStats: playerStats ?? this.playerStats,
      model: model ?? this.model,
      loading: loading ?? this.loading,
      errors: errors ?? this.errors,
      successMessage: successMessage,
    );
  }

  @override
  AsyncValue<List<DropdownItem>> getDropdownItems() {
    return footballPlayers;
  }

  @override
  DropdownItem? getSelected() {
    return selectedFootballPlayer;
  }
}

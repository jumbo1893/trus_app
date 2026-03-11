import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/notifier/dropdown/i_dropdown_state.dart';
import '../../../models/api/auth/user_team_role_api_model.dart';
import '../../../models/api/interfaces/dropdown_item.dart';

class ViewUserState implements IDropdownState {
  final String name;
  final String email;
  final AsyncValue<List<DropdownItem>> eligiblePlayersToPairWith;
  final DropdownItem? selectedPlayer;
  final UserTeamRoleApiModel? userTeamRole;
  final String otherRoles;

  const ViewUserState({
    required this.name,
    required this.email,
    required this.eligiblePlayersToPairWith,
    this.selectedPlayer,
    this.userTeamRole,
    required this.otherRoles,
  });

  ViewUserState copyWith({
    String? name,
    String? email,
    AsyncValue<List<DropdownItem>>? eligiblePlayersToPairWith,
    DropdownItem? selectedPlayer,
    UserTeamRoleApiModel? userTeamRole,
    String? otherRoles,
  }) {
    return ViewUserState(
      name: name ?? this.name,
      email: email ?? this.email,
      eligiblePlayersToPairWith: eligiblePlayersToPairWith ?? this.eligiblePlayersToPairWith,
      selectedPlayer: selectedPlayer ?? this.selectedPlayer,
      userTeamRole: userTeamRole ?? this.userTeamRole,
      otherRoles: otherRoles ?? this.otherRoles,
    );
  }

  @override
  AsyncValue<List<DropdownItem>> getDropdownItems() {
    return eligiblePlayersToPairWith;
  }

  @override
  DropdownItem? getSelected() {
    return selectedPlayer;
  }
}

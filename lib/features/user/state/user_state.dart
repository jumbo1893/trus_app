import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../../../common/widgets/notifier/listview/i_listview_state.dart';
import '../../../models/api/auth/user_api_model.dart';

class UserState implements IListviewState {
  final AsyncValue<List<UserApiModel>> users;

  UserState({
    required this.users,
  });

  factory UserState.initial() => UserState(
    users: const AsyncValue.loading(),
      );

  UserState copyWith({
    AsyncValue<List<UserApiModel>>? users,
  }) {
    return UserState(
      users: users ?? this.users,
    );
  }

  @override
  AsyncValue<List<ModelToString>> getListViewItems() {
    return users;
  }
}

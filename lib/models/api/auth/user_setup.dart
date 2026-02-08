import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/auth/user_api_model.dart';
import 'package:trus_app/models/api/interfaces/json_and_http_converter.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

class UserSetup implements JsonAndHttpConverter {
  final UserApiModel currentUser;
  final List<PlayerApiModel> eligiblePlayersToPairWith;
  final List<UserApiModel> eligibleUsersToSendNotification;
  final PlayerApiModel primaryPlayer;

  UserSetup({
    required this.currentUser,
    required this.eligiblePlayersToPairWith,
    required this.eligibleUsersToSendNotification,
    required this.primaryPlayer,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      "currentUser": currentUser,
      "eligiblePlayersToPairWith": eligiblePlayersToPairWith,
      "eligibleUsersToSendNotification": eligibleUsersToSendNotification,
      "primaryPlayer": primaryPlayer,
    };
  }

  @override
  factory UserSetup.fromJson(Map<String, dynamic> json) {
    return UserSetup(
      currentUser: UserApiModel.fromJson(json["currentUser"]),
      eligiblePlayersToPairWith: List<PlayerApiModel>.from((json['eligiblePlayersToPairWith'] as List<dynamic>).map((player) => PlayerApiModel.fromJson(player))),
      eligibleUsersToSendNotification: List<UserApiModel>.from((json['eligibleUsersToSendNotification'] as List<dynamic>).map((user) => UserApiModel.fromJson(user))),
      primaryPlayer: PlayerApiModel.fromJson(json["primaryPlayer"]),
    );
  }

  @override
  String httpRequestClass() {
    return authApi;
  }
}

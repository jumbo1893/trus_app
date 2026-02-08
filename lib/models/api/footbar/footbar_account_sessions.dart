import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/footbar/footbar_session.dart';
import 'package:trus_app/models/api/interfaces/json_and_http_converter.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

import '../auth/user_api_model.dart';
import '../interfaces/model_to_string.dart';

class FootbarAccountSessions implements ModelToString, JsonAndHttpConverter {
  final int id;
  final bool primaryUser;
  final UserApiModel user;
  final PlayerApiModel? player;
  final List<FootbarSession> sessions;

  FootbarAccountSessions({
    required this.id,
    required this.primaryUser,
    required this.user,
    required this.player,
    required this.sessions,
  });

  @override
  factory FootbarAccountSessions.fromJson(Map<String, dynamic> json) {
    return FootbarAccountSessions(
      id: json['id'],
      primaryUser: json['primaryUser'],
      user: UserApiModel.fromJson(json["user"]),
      player: json['player'] != null ? PlayerApiModel.fromJson(json['player']) : null,
      sessions: (json['sessions'] as List<dynamic>)
          .map((a) => FootbarSession.fromJson(a))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'primaryUser': primaryUser,
      'user': user.toJson(),
      'player': player?.toJson(),
    };
  }

  @override
  int getId() {
    return id;
  }

  @override
  String listViewTitle() {
    if(player != null) {
      return player!.name;
    }
    return user.name?? "Neznámý hráč";
  }

  @override
  String toStringForAdd() {
    return "";
  }

  @override
  String toStringForConfirmationDelete() {
    return "";
  }

  @override
  String toStringForEdit(String originName) {
    return "";
  }

  @override
  String toStringForListView() {
    if(sessions.isEmpty) {
      return "bez záznamu";
    }
      return sessions[0].toString();

  }

  @override
  String httpRequestClass() {
    return footbarApi;
  }

  @override
  String toString() {
    return 'FootbarAccountSessions{id: $id, primaryUser: $primaryUser, user: $user, player: $player, sessions: $sessions}';
  }
}

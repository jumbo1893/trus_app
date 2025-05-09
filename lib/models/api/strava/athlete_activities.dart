import 'package:trus_app/models/api/interfaces/json_and_http_converter.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
import '../auth/user_api_model.dart';
import '../interfaces/model_to_string.dart';
import 'strava_activity.dart';

class AthleteActivities implements ModelToString, JsonAndHttpConverter {
  final int id;
  final UserApiModel user;
  final PlayerApiModel? player;
  final List<StravaActivity> activities;

  AthleteActivities({
    required this.id,
    required this.user,
    required this.player,
    required this.activities,
  });

  @override
  factory AthleteActivities.fromJson(Map<String, dynamic> json) {
    return AthleteActivities(
      id: json['id'],
      user: UserApiModel.fromJson(json["user"]),
      player: json['player'] != null ? PlayerApiModel.fromJson(json['player']) : null,
      activities: (json['activities'] as List<dynamic>)
          .map((a) => StravaActivity.fromJson(a))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'player': player?.toJson(),
      'activities': activities.map((a) => a.toJson()).toList(),
    };
  }

  @override
  String httpRequestClass() {
    return "AthleteActivities";
  }

  @override
  String toString() {
    return 'AthleteActivities{id: $id, user: $user, player: $player, activities: $activities}';
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
    if(activities.isEmpty) {
      return "bez záznamu";
    }
      return activities[0].toString();

  }
}

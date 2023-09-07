import 'package:age_calculator/age_calculator.dart';
import 'package:trus_app/common/utils/calendar.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/interfaces/json_and_http_converter.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';
import 'package:trus_app/models/api/player_api_model.dart';

import '../interfaces/add_to_string.dart';

class GoalSetup implements JsonAndHttpConverter, AddToString {
  int? id;
  int goalNumber;
  int assistNumber;
  final PlayerApiModel player;

  GoalSetup({
    required this.goalNumber,
    required this.assistNumber,
    required this.player,
    this.id,
  });

  void addGoal() {
    goalNumber++;
  }

  void addAssist() {
    assistNumber++;
  }

  void removeGoal() {
    if (goalNumber > 0) {
      goalNumber--;
    }
  }

  void removeAssist() {
    if (assistNumber > 0) {
      assistNumber--;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "goalNumber": goalNumber,
      "assistNumber": assistNumber,
      "player": player,
    };
  }

  @override
  factory GoalSetup.fromJson(Map<String, dynamic> json) {
    return GoalSetup(
      goalNumber: json["goalNumber"] ?? 0,
      id: json["id"] ?? 0,
      assistNumber: json["assistNumber"] ?? 0,
      player: PlayerApiModel.fromJson(json["player"]),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalSetup &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String httpRequestClass() {
    return goalApi;
  }

  @override
  String toStringForListView() {
    return player.name;
  }

  @override
  String numberToString(bool goal) {
    if(goal) {
      return goalNumber.toString();
    }
    return assistNumber.toString();
  }

  @override
  void addNumber(bool goal) {
    if(goal) {
      addGoal();
    }
    else {
      addAssist();
    }
  }

  @override
  void removeNumber(bool goal) {
    if(goal) {
      removeGoal();
    }
    else {
      removeAssist();
    }
  }

  @override
  int number(bool goal) {
    if(goal) {
      return goalNumber;
    }
    else {
      return assistNumber;
    }
  }

  @override
  String toString() {
    return 'GoalSetup{goalNumber: $goalNumber, assistNumber: $assistNumber, player: ${player.name}';
  }
}

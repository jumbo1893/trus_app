
import 'package:trus_app/models/helper/helper_model.dart';

import '../fine_model.dart';
import '../player_model.dart';

class PlayerStatsHelperModel implements IHelperModel {
  final String id;
  int goalNumber;
  int assistNumber;
  final PlayerModel player;

  PlayerStatsHelperModel({
    required this.id,
    required this.player,
    required this.goalNumber,
    required this.assistNumber,
  });

  void addGoalNumber() {
    goalNumber++;
  }

  void removeGoalNumber() {
    if(goalNumber > 0) {
      goalNumber--;
    }
  }

  void addAssistNumber() {
    assistNumber++;
  }

  void addAssistAndGoalNumber(int assist, int goal) {
    assistNumber+=assist;
    goalNumber+=goal;
  }

  void removeAssistNumber() {
    if(assistNumber > 0) {
      assistNumber--;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PlayerStatsHelperModel &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;


  ///pro přidání čísla pro pole goalNumber použíjeme parametr "goal", pro assistNumber parametr "assist"
  @override
  void addNumber(String? field) {
    if (field == "goal") {
      addGoalNumber();
    }
    else if (field == "assist") {
      addAssistNumber();
    }
  }
  ///pro zjištění čísla pro pole goalNumber použíjeme parametr "goal", pro assistNumber parametr "assist"
  @override
  int getNumber(String? field) {
    if (field == "goal") {
      return goalNumber;
    }
    else if (field == "assist") {
      return assistNumber;
    }
    return 0;
  }
  ///pro odebrání čísla pro pole goalNumber použíjeme parametr "goal", pro assistNumber parametr "assist"
  @override
  void removeNumber(String? field) {
    if (field == "goal") {
      removeGoalNumber();
    }
    else if (field == "assist") {
      removeAssistNumber();
    }
  }

  @override
  String toStringForListviewAddModel() {
    return player.name;
  }

//

}

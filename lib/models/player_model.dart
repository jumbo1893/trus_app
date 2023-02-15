import 'package:age_calculator/age_calculator.dart';
import 'package:trus_app/common/utils/calendar.dart';

class PlayerModel {
  final String id;
  final String name;
  final DateTime birthday;
  final bool fan;
  final bool isActive;

  PlayerModel(
      {required this.name,
      required this.id,
      required this.birthday,
      required this.fan,
      required this.isActive,});

  PlayerModel.dummy()
      : id = "dummy",
        name = "neznámý hráč",
        birthday = DateTime.fromMicrosecondsSinceEpoch(0),
        fan = false,
        isActive = false;

  int calculateAge() {
    return AgeCalculator.age(birthday).years;
  }

  int calculateDaysToNextBirthday() {
    return AgeCalculator.timeToNextBirthday(birthday).days;
  }


  @override
  String toString() {
    return 'PlayerModel{id: $id, name: $name, birthday: $birthday, fan: $fan}';
    return name;
  }

  String toStringForPlayerList() {
    return "${fan ? "Fanoušek" : "Hráč"}, datum narození: ${dateTimeToString(birthday)}";
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "id": id,
      "birthday": birthday.millisecondsSinceEpoch,
      "fan": fan,
      "isActive": isActive,
    };
  }

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      birthday: DateTime.fromMillisecondsSinceEpoch(json['birthday']),
      name: json["name"] ?? "",
      id: json["id"] ?? "",
      fan: json["fan"] ?? false,
      isActive: json['isActive'] ?? true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

//

}

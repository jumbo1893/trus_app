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

  DateDuration nextBirthday() {
    return AgeCalculator.timeToNextBirthday(birthday);
  }

  bool isTodayBirthDay() {
    return nextBirthday().days == 0 && nextBirthday().months == 0;
  }

  String nextBirthdayToString() {
    String text = "";
    if(nextBirthday().months != 0) {
      text +=monthsToNextBirtdayToString();
      if (nextBirthday().days != 0) {
        return text+= " a ${daysToNextBirtdayToString()}";
      }
      else {
        return text;
      }
    }
    return daysToNextBirtdayToString();
  }

  String daysToNextBirtdayToString() {
    String text = "";
    if (nextBirthday().days == 1) {
      text += "${nextBirthday().days} den";
    }
    else if (nextBirthday().days == 2 || nextBirthday().days == 3 || nextBirthday().days == 4) {
      text += "${nextBirthday().days} dny";
    }
    else if (nextBirthday().days == 0) {
    }
    else {
      text += "${nextBirthday().days} dní";
    }
    return text;
  }

  String monthsToNextBirtdayToString() {
    String text = "";
    if (nextBirthday().months == 1) {
      text += "${nextBirthday().months} měsíc";
    }
    else if (nextBirthday().months == 2 || nextBirthday().months == 3 || nextBirthday().months == 4) {
      text += "${nextBirthday().months} měsíce";
    }
    else if (nextBirthday().months == 0) {
    }
    else {
      text += "${nextBirthday().months} měsíců";
    }
    return text;
  }

  /// 0 = dříve
  /// 1 = starší
  /// 2 = stejně
  int compareBirthday (PlayerModel playerModel) {
    if(nextBirthday().months < playerModel.nextBirthday().months) {
      return 0;
    }
    else if (nextBirthday().months > playerModel.nextBirthday().months) {
      return 1;
    }
    else {
      if(nextBirthday().days < playerModel.nextBirthday().months) {
        return 0;
      }
      else if (nextBirthday().days > playerModel.nextBirthday().months) {
        return 1;
      }
      else {
        return 2;
      }
    }
  }


  @override
  String toString() {
    return 'PlayerModel{id: $id, name: $name, birthday: $birthday, fan: $fan}';
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

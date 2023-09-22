import 'package:age_calculator/age_calculator.dart';
import 'package:trus_app/common/utils/calendar.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/interfaces/json_and_http_converter.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

class PlayerApiModel implements ModelToString, JsonAndHttpConverter {
  int? id;
  final String name;
  final DateTime birthday;
  final bool fan;
  final bool active;

  PlayerApiModel({
    required this.name,
    required this.birthday,
    required this.fan,
    required this.active,
    this.id,
  });

  PlayerApiModel.dummy()
      : id = 0,
        name = "neznámý hráč",
        birthday = DateTime.fromMicrosecondsSinceEpoch(0),
        fan = false,
        active = false;

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
    if (nextBirthday().months != 0) {
      text += monthsToNextBirtdayToString();
      if (nextBirthday().days != 0) {
        return text += " a ${daysToNextBirtdayToString()}";
      } else {
        return text;
      }
    }
    return daysToNextBirtdayToString();
  }

  String daysToNextBirtdayToString() {
    String text = "";
    if (nextBirthday().days == 1) {
      text += "${nextBirthday().days} den";
    } else if (nextBirthday().days == 2 ||
        nextBirthday().days == 3 ||
        nextBirthday().days == 4) {
      text += "${nextBirthday().days} dny";
    } else if (nextBirthday().days == 0) {
    } else {
      text += "${nextBirthday().days} dní";
    }
    return text;
  }

  String monthsToNextBirtdayToString() {
    String text = "";
    if (nextBirthday().months == 1) {
      text += "${nextBirthday().months} měsíc";
    } else if (nextBirthday().months == 2 ||
        nextBirthday().months == 3 ||
        nextBirthday().months == 4) {
      text += "${nextBirthday().months} měsíce";
    } else if (nextBirthday().months == 0) {
    } else {
      text += "${nextBirthday().months} měsíců";
    }
    return text;
  }

  /// 0 = dříve
  /// 1 = starší
  /// 2 = stejně
  int compareBirthday(PlayerApiModel playerModel) {
    if (nextBirthday().months < playerModel.nextBirthday().months) {
      return 0;
    } else if (nextBirthday().months > playerModel.nextBirthday().months) {
      return 1;
    } else {
      if (nextBirthday().days < playerModel.nextBirthday().months) {
        return 0;
      } else if (nextBirthday().days > playerModel.nextBirthday().months) {
        return 1;
      } else {
        return 2;
      }
    }
  }


  @override
  String toString() {
    return 'PlayerApiModel{id: $id, name: $name, birthday: $birthday, fan: $fan, active: $active}';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "id": id,
      "birthday": formatDateForJson(birthday),
      "fan": fan,
      "active": active,
    };
  }

  @override
  factory PlayerApiModel.fromJson(Map<String, dynamic> json) {
    return PlayerApiModel(
      birthday: DateTime.parse(json['birthday']),
      name: json["name"] ?? "",
      id: json["id"] ?? 0,
      fan: json["fan"] ?? false,
      active: json['active'] ?? true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerApiModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toStringForListView() {
    return "${fan ? "Fanoušek" : "Hráč"}, datum narození: ${dateTimeToString(birthday)}";
  }

  @override
  String listViewTitle() {
    return name;
  }

  @override
  String toStringForAdd() {
    return "Přidán ${fan ? "fanoušek" : "hráč"} $name s datumem narození: ${dateTimeToString(birthday)}";
  }

  @override
  String toStringForConfirmationDelete() {
    return "Opravdu chcete smazat tohoto hráče?";
  }

  @override
  String toStringForEdit(String originName) {
    return "$originName upraven na ${fan ? "fanouška" : "hráče"} $name, s datumem narození: ${dateTimeToString(birthday)}";
  }

  @override
  String httpRequestClass() {
    return playerApi;
  }

  @override
  int getId() {
    return id ?? -1;
  }
}

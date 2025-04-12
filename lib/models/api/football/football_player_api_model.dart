
import '../../../config.dart';
import '../interfaces/dropdown_item.dart';
import '../interfaces/json_and_http_converter.dart';

class FootballPlayerApiModel implements JsonAndHttpConverter, DropdownItem {
  int? id;
  List<int>? teamIdList;
  final String name;
  final int birthYear;
  String? email;
  String? phoneNumber;
  final String uri;

  FootballPlayerApiModel({
    this.id,
    this.teamIdList,
    required this.name,
    required this.birthYear,
    this.email,
    this.phoneNumber,
    required this.uri,
  });

  FootballPlayerApiModel.dummy()
      : name = "-",
        birthYear = 0,
        uri = "";

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "teamIdList": teamIdList,
      "name": name,
      "birthYear": birthYear,
      "email": email,
      "phoneNumber": phoneNumber,
      "uri": uri,
    };
  }

  factory FootballPlayerApiModel.fromJson(Map<String, dynamic> json) {
    return FootballPlayerApiModel(
      id: json["id"],
      teamIdList: json["teamIdList"] != null ? List<int>.from(json["teamIdList"]) : null,
      name: json["name"],
      birthYear: json["birthYear"],
      email: json["email"],
      phoneNumber: json["phoneNumber"],
      uri: json["uri"],
    );
  }

  @override
  String httpRequestClass() {
    return footballPlayerApi;
  }

  @override
  String dropdownItem() {
    if(birthYear == 0) {
      return name;
    }
    return "$name ($birthYear)";
  }

  @override
  String toString() {
    return 'FootballPlayerApiModel{id: $id, teamIdList: $teamIdList, name: $name, birthYear: $birthYear, email: $email, phoneNumber: $phoneNumber, uri: $uri}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FootballPlayerApiModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

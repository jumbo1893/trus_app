import 'package:trus_app/config.dart';

import '../interfaces/json_and_http_converter.dart';

class FootbarProfile implements JsonAndHttpConverter {
  final int? userId;
  final String? nickname;
  final String? favFoot;
  final String? favPosition;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? dateOfBirth;
  final String? profilePic;
  final String? ageCategory;
  final double? height;
  final double? weight;
  final String? strength;
  final String? countryFlag;
  final bool active;

  FootbarProfile({
    this.userId,
    this.nickname,
    this.favFoot,
    this.favPosition,
    this.firstName,
    this.lastName,
    this.gender,
    this.dateOfBirth,
    this.profilePic,
    this.ageCategory,
    this.height,
    this.weight,
    this.strength,
    this.countryFlag,
    required this.active,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'nickname': nickname,
      'favFoot': favFoot,
      'favPosition': favPosition,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'profilePic': profilePic,
      'ageCategory': ageCategory,
      'height': height,
      'weight': weight,
      'strength': strength,
      'countryFlag': countryFlag,
      'active': active,
    };
  }

  @override
  factory FootbarProfile.fromJson(Map<String, dynamic> json) {
    return FootbarProfile(
      userId: json["userId"] ?? -1,
      nickname: json["nickname"],
      favFoot: json["favFoot"],
      favPosition: json["favPosition"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      gender: json["gender"],
      dateOfBirth: json["dateOfBirth"],
      profilePic: json["profilePic"],
      ageCategory: json["ageCategory"],
      height: (json["height"] as num?)?.toDouble(),
      weight: (json["weight"] as num?)?.toDouble(),
      strength: json["strength"],
      countryFlag: json["countryFlag"],
      active: json["active"] ?? false
    );
  }

  @override
  String httpRequestClass() {
    return footbarApi;
  }

  @override
  String toString() {
    return 'FootbarProfile(userId: $userId, nick: $nickname, pos: $favPosition, '
        'dob: $dateOfBirth, height: $height, weight: $weight, active: $active)';
  }

  String? weightToString() {
    if(weight !=null) {
      return "$weight kg";
    }
    return null;
  }

  String? heightToString() {
    if(height !=null) {
      return "$height m";
    }
    return null;
  }
}

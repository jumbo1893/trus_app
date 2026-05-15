import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/achievement/achievement_rarity.dart';
import 'package:trus_app/models/api/interfaces/json_and_http_converter.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

class AchievementApiModel implements ModelToString, JsonAndHttpConverter {
  final int id;
  final String name;
  final String code;
  final String description;
  final bool onlyForPlayers;
  String? secondaryCondition;
  final bool manually;

  final double teamSuccessRate;

  final AchievementRarity rarity;

  AchievementApiModel({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.onlyForPlayers,
    this.secondaryCondition,
    required this.manually,
    this.teamSuccessRate = 1.0,
    this.rarity = AchievementRarity.common,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "code": code,
      "description": description,
      "onlyForPlayers": onlyForPlayers,
      "secondaryCondition": secondaryCondition,
      "manually": manually,
      "teamSuccessRate": teamSuccessRate,
      "rarity": rarity.toJson(),
    };
  }

  AchievementApiModel.dummy()
      : id = 0,
        name = "",
        code = "",
        description = "",
        onlyForPlayers = false,
        manually = false,
        teamSuccessRate = 1.0,
        rarity = AchievementRarity.common;

  factory AchievementApiModel.fromJson(Map<String, dynamic> json) {
    return AchievementApiModel(
      code: json['code'] ?? "",
      name: json["name"] ?? "",
      id: json["id"] ?? 0,
      description: json["description"] ?? "",
      onlyForPlayers: json['onlyForPlayers'] ?? false,
      secondaryCondition: json['secondaryCondition'],
      manually: json["manually"] ?? false,
      teamSuccessRate: (json["teamSuccessRate"] as num?)?.toDouble() ?? 1.0,
      rarity: AchievementRarityExtension.fromJson(json["rarity"]),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AchievementApiModel &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toStringForListView() {
    return description;
  }

  @override
  String listViewTitle() {
    return name;
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
  String httpRequestClass() {
    return achievementApi;
  }

  @override
  int getId() {
    return id;
  }
}
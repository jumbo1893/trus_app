import 'package:trus_app/models/api/stats/player_stats.dart';

import '../../../config.dart';
import '../interfaces/json_and_http_converter.dart';

class Stats implements JsonAndHttpConverter {
  final String dropdownText;
  final List<PlayerStats> playerStats;

  Stats({
    required this.dropdownText,
    required this.playerStats,
  });


  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      playerStats: List<PlayerStats>.from((json['playerStats'] as List<dynamic>).map((playerStats) => PlayerStats.fromJson(playerStats))),
      dropdownText: json["dropdownText"] ?? "",
    );
  }

  @override
  String httpRequestClass() {
    return statsApi;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "playerStats": playerStats,
      "dropdownText": dropdownText,
    };
  }
}

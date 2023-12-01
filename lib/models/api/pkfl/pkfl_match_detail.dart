import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/interfaces/json_and_http_converter.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';
import 'package:trus_app/models/api/pkfl/pkfl_individual_stats_api_model.dart';
import 'package:trus_app/models/api/pkfl/pkfl_match_api_model.dart';
import 'package:trus_app/models/api/pkfl/pkfl_opponent_api_model.dart';
import 'package:trus_app/models/api/pkfl/pkfl_player_api_model.dart';
import 'package:trus_app/models/api/pkfl/pkfl_referee_api_model.dart';
import 'package:trus_app/models/api/pkfl/pkfl_season_api_model.dart';
import 'package:trus_app/models/api/pkfl/pkfl_stadium_api_model.dart';

import '../../../common/utils/calendar.dart';

class PkflMatchDetail {
  PkflMatchApiModel pkflMatch;
  List<PkflMatchApiModel> commonMatches;
  String? aggregateScore;
  String? aggregateMatches;

  PkflMatchDetail(
      {required this.pkflMatch,
      required this.commonMatches,
      this.aggregateScore,
        this.aggregateMatches,
    });

  Map<String, dynamic> toJson() {
    return {
      "pkflMatch": pkflMatch,
      "commonMatches": commonMatches,
      "aggregateScore": aggregateScore,
      "aggregateMatches": aggregateMatches,
    };
  }

  factory PkflMatchDetail.fromJson(Map<String, dynamic> json) {
    return PkflMatchDetail(
      pkflMatch: PkflMatchApiModel.fromJson(json["pkflMatch"]),
      aggregateScore: json["aggregateScore"],
      aggregateMatches: json["aggregateMatches"],
      commonMatches: List<PkflMatchApiModel>.from((json['commonMatches'] as List<dynamic>).map((match) => PkflMatchApiModel.fromJson(match))),
    );
  }

  @override
  String toString() {
    return 'PkflMatchDetail{pkflMatch: $pkflMatch, commonMatches: $commonMatches, aggregateScore: $aggregateScore, aggregateMatches: $aggregateMatches}';
  }
}

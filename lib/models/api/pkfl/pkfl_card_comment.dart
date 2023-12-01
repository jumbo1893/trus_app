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

class PkflCardComment {
  PkflMatchApiModel pkflMatch;
  String comment;

  PkflCardComment(
      {required this.pkflMatch,
      required this.comment,
    });

  factory PkflCardComment.fromJson(Map<String, dynamic> json) {
    return PkflCardComment(
      pkflMatch: PkflMatchApiModel.fromJson(json["pkflMatch"]),
      comment: json["comment"],
    );
  }
}

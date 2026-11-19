import '../helper/warning_type.dart';
import '../helper/redirect/redirect.dart';
import 'package:trus_app/models/api/football/detail/football_match_detail.dart';
import 'package:trus_app/models/api/match/planned_match.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';

import '../helper/redirect/text_with_redirect.dart';

class DashboardMatch {
  final FootballMatchDetail? match;
  final PlannedMatch? plannedMatch;
  final MatchApiModel? recordedMatch;
  final List<TextWithRedirect> matchInfoList;

  DashboardMatch({
    required this.match,
    required this.matchInfoList,
    this.plannedMatch,
    this.recordedMatch,
  });

  bool get needsEntry =>
      match != null &&
      matchInfoList.any(
        (item) =>
            item.warningType == WarningType.error &&
            item.redirect?.redirect == Redirect.matchWithPlayerBottomsheet,
      );

  factory DashboardMatch.fromJson(Map<String, dynamic> json) {
    return DashboardMatch(
      match: json["match"] != null
          ? FootballMatchDetail.fromJson(json["match"])
          : null,
      plannedMatch: json['plannedMatch'] == null
          ? null
          : PlannedMatch.fromJson(json['plannedMatch'] as Map<String, dynamic>),
      recordedMatch: json['recordedMatch'] == null
          ? null
          : MatchApiModel.fromJson(
              json['recordedMatch'] as Map<String, dynamic>,
            ),
      matchInfoList: (json["matchInfoList"] as List<dynamic>)
          .map((item) => TextWithRedirect.fromJson(item))
          .toList(),
    );
  }
}

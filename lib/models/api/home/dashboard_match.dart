import 'package:trus_app/models/api/football/detail/football_match_detail.dart';

import '../helper/redirect/text_with_redirect.dart';

class DashboardMatch {
  final FootballMatchDetail? match;
  final List<TextWithRedirect> matchInfoList;

  DashboardMatch({
    required this.match,
    required this.matchInfoList,
  });

  factory DashboardMatch.fromJson(Map<String, dynamic> json) {
    return DashboardMatch(
      match: json["match"] != null
          ? FootballMatchDetail.fromJson(json["match"])
          : null,
      matchInfoList: (json["matchInfoList"] as List<dynamic>)
          .map((item) => TextWithRedirect.fromJson(item))
          .toList(),
    );
  }
}
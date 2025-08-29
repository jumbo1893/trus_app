
import 'package:trus_app/features/general/cache/i_endpoint_id.dart';
import 'package:trus_app/models/api/football/detail/football_match_detail.dart';

import 'chart.dart';

class HomeSetup implements IEndpointId {
  String nextBirthday;
  List<String> randomFacts;
  Chart? chart;
  List<FootballMatchDetail?> nextAndLastFootballMatch;
  final List<Chart> charts;
  static const endpointId = "home_setup";


  HomeSetup({
    required this.nextBirthday,
    required this.randomFacts,
    required this.chart,
    required this.nextAndLastFootballMatch,
    required this.charts
  });


  @override
  factory HomeSetup.fromJson(Map<String, dynamic> json) {
    return HomeSetup(
      nextBirthday: json["nextBirthday"] ?? "",
      randomFacts: (json['randomFacts'] as List).cast<String>(),
      chart: json["chart"] != null ? Chart.fromJson(json["chart"]) : null,
      nextAndLastFootballMatch: (json['nextAndLastFootballMatch'] as List<dynamic>)
          .map((item) => item != null ? FootballMatchDetail.fromJson(item) : null)
          .toList(),
      charts: List<Chart>.from((json['charts'] as List<dynamic>).map((fine) => Chart.fromJson(fine))),
    );
  }

  @override
  String getEndpointId() {
    return endpointId;
  }

}

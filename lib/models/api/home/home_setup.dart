
import '../pkfl/pkfl_match_api_model.dart';
import 'chart.dart';

class HomeSetup {
  String nextBirthday;
  List<String> randomFacts;
  Chart? chart;
  List<PkflMatchApiModel?> nextAndLastPkflMatch;
  List<Chart>? charts;


  HomeSetup({
    required this.nextBirthday,
    required this.randomFacts,
    required this.chart,
    required this.nextAndLastPkflMatch,
    required this.charts
  });


  @override
  factory HomeSetup.fromJson(Map<String, dynamic> json) {
    return HomeSetup(
      nextBirthday: json["nextBirthday"] ?? "",
      randomFacts: (json['randomFacts'] as List).cast<String>(),
      chart: json["chart"] != null ? Chart.fromJson(json["chart"]) : null,
      nextAndLastPkflMatch: (json['nextAndLastPkflMatch'] as List<dynamic>)
          .map((item) => item != null ? PkflMatchApiModel.fromJson(item) : null)
          .toList(),
      charts: List<Chart>.from((json['charts'] as List<dynamic>).map((fine) => Chart.fromJson(fine))),
    );
  }

}

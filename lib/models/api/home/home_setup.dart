
import '../pkfl/pkfl_match_api_model.dart';
import 'chart.dart';

class HomeSetup {
  String nextBirthday;
  List<String> randomFacts;
  Chart? chart;
  List<PkflMatchApiModel?> nextAndLastPkflMatch;


  HomeSetup({
    required this.nextBirthday,
    required this.randomFacts,
    required this.chart,
    required this.nextAndLastPkflMatch
  });


  @override
  factory HomeSetup.fromJson(Map<String, dynamic> json) {
    return HomeSetup(
      nextBirthday: json["nextBirthday"] ?? "",
      randomFacts: (json['randomFacts'] as List).cast<String>(),
      chart: json["chart"] != null ? Chart.fromJson(json["chart"]) : null,
      nextAndLastPkflMatch: List<PkflMatchApiModel>.from((json['nextAndLastPkflMatch'] as List<dynamic>).map((fine) => PkflMatchApiModel.fromJson(fine))),
    );
  }

}

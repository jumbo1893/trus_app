
import 'chart.dart';

class HomeSetup {
  String nextBirthday;
  List<String> randomFacts;
  Chart? chart;


  HomeSetup({
    required this.nextBirthday,
    required this.randomFacts,
    required this.chart,
  });


  @override
  factory HomeSetup.fromJson(Map<String, dynamic> json) {
    return HomeSetup(
      nextBirthday: json["nextBirthday"] ?? "",
      randomFacts: (json['randomFacts'] as List).cast<String>(),
      chart: json["chart"] != null ? Chart.fromJson(json["chart"]) : null,
    );
  }

}

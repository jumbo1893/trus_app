
import '../interfaces/confirm_to_string.dart';

class GoalMultiAddResponse implements ConfirmToString {
  final int totalGoalsAdded;
  final int totalAssistAdded;
  final String match;

  GoalMultiAddResponse({
    required this.totalGoalsAdded,
    required this.totalAssistAdded,
    required this.match,
  });

  Map<String, dynamic> toJson() {
    return {
      "totalGoalsAdded": totalGoalsAdded,
      "totalAssistAdded": totalAssistAdded,
      "match": match,
    };
  }

  factory GoalMultiAddResponse.fromJson(Map<String, dynamic> json) {
    return GoalMultiAddResponse(
      totalGoalsAdded: json["totalGoalsAdded"] ?? 0,
      totalAssistAdded: json["totalAssistAdded"] ?? 0,
      match: json["match"] ?? "",
    );
  }

  @override
  String toString() {
    return 'V zápase proti $match bylo přidáno celkem $totalGoalsAdded gólů a $totalAssistAdded asistencí';
  }

  @override
  String toStringForSnackBar() {
    return toString();
  }


}

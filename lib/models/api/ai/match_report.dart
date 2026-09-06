class MatchReport {
  const MatchReport({
    required this.id,
    required this.footballMatchId,
    required this.text,
    required this.generatedAt,
  });
  final int id;
  final int footballMatchId;
  final String text;
  final DateTime generatedAt;
  factory MatchReport.fromJson(Map<String, dynamic> json) => MatchReport(
    id: json['id'] as int,
    footballMatchId: json['footballMatchId'] as int,
    text: json['text'] as String,
    generatedAt: DateTime.parse(json['generatedAt'] as String),
  );
}

class MatchReportState {
  const MatchReportState({
    this.report,
    required this.canGenerate,
    this.generating = false,
  });
  final MatchReport? report;
  final bool canGenerate;
  final bool generating;
  factory MatchReportState.fromJson(Map<String, dynamic> json) =>
      MatchReportState(
        report: json['report'] == null
            ? null
            : MatchReport.fromJson(
                (json['report'] as Map).cast<String, dynamic>(),
              ),
        canGenerate: json['canGenerate'] == true,
        generating: json['generating'] == true,
      );
}

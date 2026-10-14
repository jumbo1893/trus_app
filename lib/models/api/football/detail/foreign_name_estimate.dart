class ForeignNameEstimate {
  final int? rosterPercent;
  final int? lastMatchPercent;

  const ForeignNameEstimate({this.rosterPercent, this.lastMatchPercent});

  factory ForeignNameEstimate.fromJson(Map<String, dynamic> json) =>
      ForeignNameEstimate(
        rosterPercent: json['rosterPercent'] as int?,
        lastMatchPercent: json['lastMatchPercent'] as int?,
      );

  String get summary {
    final roster = rosterPercent == null
        ? 'podíl cizinců nelze určit'
        : 'pravděpodobně $rosterPercent % cizinců';
    final lastMatch = lastMatchPercent == null
        ? 'podíl nelze určit'
        : '$lastMatchPercent %';
    return '$roster, v posledním zápase $lastMatch';
  }
}

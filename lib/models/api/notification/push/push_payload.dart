class PushPayload {
  final String title;
  final String body;
  final String? screenId;
  final String? notificationType;
  final String? navigateText;
  final int? matchId;
  final int? footballMatchId;
  final int? playerId;
  final int? appTeamId;
  final int? playerAchievementId;
  final int? recapId;

  const PushPayload({
    required this.title,
    required this.body,
    required this.screenId,
    required this.notificationType,
    required this.matchId,
    required this.footballMatchId,
    required this.playerId,
    required this.navigateText,
    this.appTeamId,
    this.playerAchievementId,
    this.recapId,
  });

  factory PushPayload.fromData(Map<String, dynamic> data) {
    return PushPayload(
      title: data['title']?.toString() ?? 'Notifikace',
      body: data['body']?.toString() ?? '',
      screenId: data['screenId']?.toString(),
      notificationType: data['notificationType']?.toString(),
      matchId: _toInt(data['matchId']),
      footballMatchId: _toInt(data['footballMatchId']),
      playerId: _toInt(data['playerId']),
      appTeamId: _toInt(data['appTeamId']),
      playerAchievementId: _toInt(data['playerAchievementId']),
      recapId: _toInt(data['recapId']),
      navigateText: data['navigateText']?.toString(),
    );
  }

  bool get hasNavigationTarget => screenId != null && screenId!.isNotEmpty;

  static int? _toInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

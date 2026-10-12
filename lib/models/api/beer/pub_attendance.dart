class PubAttendance {
  final int matchId;
  final bool configured;
  final Set<int> guestIds;
  final Set<int> leftIds;

  const PubAttendance({
    required this.matchId,
    required this.configured,
    required this.guestIds,
    required this.leftIds,
  });

  factory PubAttendance.fromJson(Map<String, dynamic> json) => PubAttendance(
    matchId: json['matchId'] as int,
    configured: json['configured'] as bool? ?? false,
    guestIds: (json['guestIds'] as List<dynamic>? ?? []).cast<int>().toSet(),
    leftIds: (json['leftIds'] as List<dynamic>? ?? []).cast<int>().toSet(),
  );

  Map<String, dynamic> toJson() => {
    'matchId': matchId,
    'configured': configured,
    'guestIds': guestIds.toList(),
    'leftIds': leftIds.toList(),
  };
}

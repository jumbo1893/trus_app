class StatisticsFilter {
  final Set<int> seasonIds;
  final Set<int> playerIds;
  final Set<int> fineIds;
  final Set<String> opponentNames;
  final bool descending;

  const StatisticsFilter({
    this.seasonIds = const {},
    this.playerIds = const {},
    this.fineIds = const {},
    this.opponentNames = const {},
    this.descending = true,
  });

  int get activeCount => [
    seasonIds,
    playerIds,
    fineIds,
    opponentNames,
  ].where((values) => values.isNotEmpty).length;

  StatisticsFilter copyWith({
    Set<int>? seasonIds,
    Set<int>? playerIds,
    Set<int>? fineIds,
    Set<String>? opponentNames,
    bool? descending,
  }) => StatisticsFilter(
    seasonIds: Set.unmodifiable(seasonIds ?? this.seasonIds),
    playerIds: Set.unmodifiable(playerIds ?? this.playerIds),
    fineIds: Set.unmodifiable(fineIds ?? this.fineIds),
    opponentNames: Set.unmodifiable(opponentNames ?? this.opponentNames),
    descending: descending ?? this.descending,
  );

  // Indexed parameters preserve names containing commas during Spring binding.
  Map<String, String> toQueryParameters() {
    final result = <String, String>{};
    void add(String key, Iterable<Object> values) {
      var index = 0;
      for (final value in values) {
        result['$key[${index++}]'] = value.toString();
      }
    }

    add('seasonIds', seasonIds);
    add('playerIds', playerIds);
    add('fineIds', fineIds);
    add('opponentNames', opponentNames);
    return result;
  }
}

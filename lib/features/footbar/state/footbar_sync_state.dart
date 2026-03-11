

class FootbarSyncState {
  final String lastSync;

  FootbarSyncState({
    required this.lastSync,
  });

  factory FootbarSyncState.initial() => FootbarSyncState(
    lastSync: "Ještě neproběhla",
      );

  FootbarSyncState copyWith({
    String? lastSync,
  }) {
    return FootbarSyncState(
      lastSync: lastSync ?? this.lastSync,
        );
  }
}

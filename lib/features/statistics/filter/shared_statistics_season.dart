import 'package:flutter_riverpod/flutter_riverpod.dart';

// Null means not initialized yet; an empty set explicitly means all seasons.
final statisticsSeasonSelectionProvider = StateProvider<Set<int>?>(
  (ref) => null,
);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final beerViewPreferenceProvider =
    StateNotifierProvider<BeerViewPreferenceNotifier, bool>((ref) {
      return BeerViewPreferenceNotifier()..load();
    });

/// False shows the visual account, true shows tally marks.
class BeerViewPreferenceNotifier extends StateNotifier<bool> {
  BeerViewPreferenceNotifier() : super(false);

  static const key = 'beer.view.draw_mode';
  bool _changedDuringLoad = false;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted && !_changedDuringLoad) state = prefs.getBool(key) ?? false;
  }

  Future<void> setDrawMode(bool draw) async {
    _changedDuringLoad = true;
    state = draw;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, draw);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appearanceNotifierProvider =
    StateNotifierProvider<AppearanceNotifier, ThemeMode>((ref) {
  return AppearanceNotifier()..load();
});

class AppearanceNotifier extends StateNotifier<ThemeMode> {
  static const String _themeModeKey = 'appearance.theme_mode';

  AppearanceNotifier() : super(ThemeMode.system);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_themeModeKey);
    state = _fromStoredValue(stored);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  ThemeMode _fromStoredValue(String? value) {
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.system,
    );
  }
}

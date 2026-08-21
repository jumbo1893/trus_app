import 'package:shared_preferences/shared_preferences.dart';

class StepSyncPreferences {
  static const _enabledKey = 'steps.sync.enabled';
  static const _teamIdKey = 'steps.sync.appTeamId';
  static const _lastCountKey = 'steps.sync.lastCount';

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getBool(_enabledKey) ?? false;
  }

  Future<int?> teamId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getInt(_teamIdKey);
  }

  Future<int> lastCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getInt(_lastCountKey) ?? 0;
  }

  Future<void> enable(int appTeamId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, true);
    await prefs.setInt(_teamIdKey, appTeamId);
  }

  Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, false);
    await prefs.remove(_lastCountKey);
  }

  Future<void> setLastCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastCountKey, count);
  }
}

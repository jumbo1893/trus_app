import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:trus_app/models/api/auth/user_api_model.dart';

class SharedPrefsHelper {
  Future<bool> isForegroundServiceStarted() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getBool("foregroundServiceStart") ?? false;
  }

  Future<void> setIsForegroundServiceStarted(bool started) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool("foregroundServiceStart", started);
  }

  Future<void> setEmail(String email) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("userEmail", email);
    await pref.remove("userPassword");
  }

  Future<UserApiModel> getUserWithEmailOnly() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    UserApiModel userApiModel = UserApiModel();
    String email = pref.getString("userEmail") ?? "";
    await pref.remove("userPassword");
    userApiModel.mail = email;
    userApiModel.password = "";
    return userApiModel;
  }

  Future<String> getOrCreateClientDeviceId() async {
    final pref = await SharedPreferences.getInstance();

    final existing = pref.getString("clientDeviceId");
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    final id = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    await pref.setString("clientDeviceId", id);
    return id;
  }
}

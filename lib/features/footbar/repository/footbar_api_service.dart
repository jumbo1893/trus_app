
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/footbar/footbar_profile.dart';
import 'package:trus_app/models/api/footbar/footbar_session_setup.dart';

import '../../general/repository/crud_api_service.dart';

final footbarApiServiceProvider =
    Provider<FootbarApiService>((ref) => FootbarApiService(ref));

class FootbarApiService extends CrudApiService {
  FootbarApiService(super.ref);

  Future<FootbarSessionSetup> getSessionSetup(int? seasonId) async {
    final String url = seasonId == null
        ? "$serverUrl/$footbarApi/sessions/setup"
        : "$serverUrl/$footbarApi/sessions/setup?seasonId=$seasonId";
    final FootbarSessionSetup footbarSessionSetup = await executeGetRequest(
        Uri.parse(url), (dynamic json) => FootbarSessionSetup.fromJson(json), null);
    return footbarSessionSetup;
  }

  Future<void> syncActivities() async {
    const String url = "$serverUrl/$stravaApi/sync";
    return await executePostRequest(Uri.parse(url), (_) => null, jsonEncode(null));
  }

  Future<String> connectToFootbar() async {
    const String url = "$serverUrl/$footbarApi/connect";
    return await executeGetRequest<String>(
      Uri.parse(url),
          (json) => json["url"] as String,
      null,
    );
  }

  Future<bool> exchangeCode(String code) async {
    const String url = "$serverUrl/$footbarApi/connect/exchange";
    return await executePostRequest(Uri.parse(url), (json) => json["connected"] as bool, jsonEncode({"code": code}));
  }

  Future<FootbarProfile> getCurrentProfile() async {
    const String url = "$serverUrl/$footbarApi/profile";
    final FootbarProfile footbarProfile = await executeGetRequest(
        Uri.parse(url), (dynamic json) => FootbarProfile.fromJson(json), null);
    return footbarProfile;
  }

  Future<DateTime?> getSessionLastSyncDate() async {
    const String url = "$serverUrl/$footbarApi/sync/date";
    final DateTime? dateTime = await executeGetRequest(
        Uri.parse(url), (json) => parseApiDate(json['date']), null);
    return dateTime;
  }

  Future<DateTime?> syncAppTeamActivites() async {
    const String url = "$serverUrl/$footbarApi/sync";
    return await executePostRequest(Uri.parse(url), (json) => parseApiDate(json['date']), jsonEncode({}));
  }

  DateTime? parseApiDate(dynamic v) {
    if (v == null) return null;
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v, isUtc: true).toLocal();
    if (v is String && v.isNotEmpty) return DateTime.parse(v).toLocal();
    return null;
  }
}

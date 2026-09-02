import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/features/general/repository/request_executor.dart';
import 'package:trus_app/models/api/auth/team_administration_api_model.dart';

final teamAdministrationRepositoryProvider = Provider(
  (ref) => TeamAdministrationRepository(ref),
);

class TeamAdministrationRepository extends RequestExecutor {
  TeamAdministrationRepository(super.ref);

  Uri get _administrationUrl =>
      Uri.parse('$serverUrl/$appTeamApi/administration');

  Future<TeamAdministrationApiModel> getAdministration() {
    return executeGetRequest(
      _administrationUrl,
      (json) => TeamAdministrationApiModel.fromJson(json),
      null,
    );
  }

  Future<TeamAdministrationApiModel> updateJoinCode(String role, String code) {
    return executePutRequest(
      Uri.parse('$_administrationUrl/codes/$role'),
      (json) => TeamAdministrationApiModel.fromJson(json),
      jsonEncode({'code': code}),
    );
  }

  Future<TeamAdministrationApiModel> updateMemberRole(
    int userTeamRoleId,
    String role,
  ) {
    return executePutRequest(
      Uri.parse('$_administrationUrl/members/$userTeamRoleId/role'),
      (json) => TeamAdministrationApiModel.fromJson(json),
      jsonEncode({'role': role}),
    );
  }
}

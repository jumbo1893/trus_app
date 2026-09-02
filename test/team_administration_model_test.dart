import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/models/api/auth/app_team_join_result.dart';
import 'package:trus_app/models/api/auth/team_administration_api_model.dart';
import 'package:trus_app/models/api/auth/team_member_api_model.dart';
import 'package:trus_app/models/api/auth/user_team_role_api_model.dart';

void main() {
  test('parses both join codes and founder protection flag', () {
    final administration = TeamAdministrationApiModel.fromJson({
      'appTeamId': 12,
      'teamName': 'Nový tým',
      'ownerId': 7,
      'ownerName': 'Zakladatel',
      'currentUserId': 7,
      'readerCode': 'READ-CODE',
      'editorCode': 'EDIT-CODE',
      'members': [
        {
          'userTeamRoleId': 20,
          'userId': 7,
          'userName': 'Zakladatel',
          'mail': 'owner@example.cz',
          'role': 'ADMIN',
          'owner': true,
        },
      ],
    });

    expect(administration.readerCode, 'READ-CODE');
    expect(administration.editorCode, 'EDIT-CODE');
    expect(administration.currentUserId, 7);
    expect(administration.members.single.owner, isTrue);
    expect(administration.members.single.isAdministrator, isTrue);
  });

  test('parses code join result with assigned team and role', () {
    final result = AppTeamJoinResult.fromJson({
      'user': {'id': 7, 'name': 'Hráč', 'teamRoles': []},
      'appTeamId': 12,
      'assignedRole': 'EDITOR',
    });

    expect(result.user.id, 7);
    expect(result.appTeamId, 12);
    expect(result.assignedRole, 'EDITOR');
  });

  test('editor role has a Czech label', () {
    final member = TeamMemberApiModel.fromJson({
      'userTeamRoleId': 20,
      'userId': 7,
      'userName': 'Hráč',
      'role': 'EDITOR',
      'owner': false,
    });
    final role = UserTeamRoleApiModel.fromJson({
      'id': 20,
      'userId': 7,
      'role': 'EDITOR',
      'appTeam': {
        'id': 12,
        'name': 'Nový tým',
        'ownerName': 'Zakladatel',
        'team': {'id': 12, 'name': 'Nový tým'},
      },
    });

    expect(member.roleLabel, 'Může editovat');
    expect(role.roleToString(), 'pro editaci');
  });
}

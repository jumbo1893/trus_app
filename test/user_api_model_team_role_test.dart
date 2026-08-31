import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/models/api/auth/app_team_api_model.dart';
import 'package:trus_app/models/api/auth/user_api_model.dart';
import 'package:trus_app/models/api/auth/user_team_role_api_model.dart';
import 'package:trus_app/models/api/football/team_api_model.dart';

void main() {
  test(
    'single team role is used when selected app team is not initialized',
    () {
      final role = _role(id: 1, appTeamId: 10, name: 'Liščí Trus');
      final user = UserApiModel(teamRoles: [role]);

      expect(user.getCurrentUserTeamRole(null), same(role));
    },
  );

  test('all roles other than selected team are returned', () {
    final selected = _role(id: 1, appTeamId: 10, name: 'Liščí Trus');
    final second = _role(id: 2, appTeamId: 20, name: 'Druhý tým');
    final third = _role(id: 3, appTeamId: 30, name: 'Třetí tým');
    final user = UserApiModel(teamRoles: [selected, second, third]);

    expect(user.getAllOtherThanCurrentTeamRole(selected.appTeam.id), [
      second,
      third,
    ]);
  });
}

UserTeamRoleApiModel _role({
  required int id,
  required int appTeamId,
  required String name,
}) {
  return UserTeamRoleApiModel(
    id: id,
    userId: 100,
    role: 'READER',
    appTeam: AppTeamApiModel(
      id: appTeamId,
      name: name,
      ownerName: 'Admin',
      team: TeamApiModel(id: appTeamId, name: name),
    ),
  );
}

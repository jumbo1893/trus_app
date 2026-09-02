import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/team_administration/controller/team_administration_provider.dart';
import 'package:trus_app/features/team_administration/screens/team_administration_screen.dart';
import 'package:trus_app/models/api/auth/team_administration_api_model.dart';
import 'package:trus_app/models/api/auth/team_member_api_model.dart';

void main() {
  testWidgets('shows both codes and keeps the founder locked', (tester) async {
    const administration = TeamAdministrationApiModel(
      appTeamId: 12,
      teamName: 'Nový tým',
      ownerId: 7,
      ownerName: 'Zakladatel',
      currentUserId: 7,
      readerCode: 'READ-CODE',
      editorCode: 'EDIT-CODE',
      members: [
        TeamMemberApiModel(
          userTeamRoleId: 20,
          userId: 7,
          userName: 'Zakladatel',
          mail: 'owner@example.cz',
          role: 'ADMIN',
          owner: true,
        ),
        TeamMemberApiModel(
          userTeamRoleId: 21,
          userId: 8,
          userName: 'Čtenář',
          mail: 'reader@example.cz',
          role: 'READER',
          owner: false,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          teamAdministrationProvider.overrideWith(
            (ref) async => administration,
          ),
        ],
        child: const MaterialApp(home: TeamAdministrationScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('READ-CODE'), findsOneWidget);
    expect(find.text('EDIT-CODE'), findsOneWidget);
    expect(find.text('Zakladatel · Administrátor'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.text('Odebrat administrátora'), findsNothing);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
  });
}

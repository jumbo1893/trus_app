import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/team_administration/controller/team_administration_provider.dart';
import 'package:trus_app/features/team_administration/screens/team_administration_screen.dart';
import 'package:trus_app/models/api/auth/team_administration_api_model.dart';
import 'package:trus_app/models/api/auth/team_member_api_model.dart';

void main() {
  testWidgets('push target appears at the top of administration', (
    tester,
  ) async {
    const administration = TeamAdministrationApiModel(
      appTeamId: 12,
      teamName: 'Tým',
      ownerId: 1,
      ownerName: 'Admin',
      currentUserId: 1,
      readerCode: 'READ-CODE',
      editorCode: 'EDIT-CODE',
      members: [
        TeamMemberApiModel(
          userTeamRoleId: 40,
          userId: 2,
          userName: 'Petr',
          mail: 'petr@example.cz',
          role: 'VIEWER',
          owner: false,
          roleApproved: false,
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          teamAdministrationProvider.overrideWith(
            (ref) async => administration,
          ),
          pendingTeamMemberTargetProvider.overrideWith((ref) => 40),
        ],
        child: const MaterialApp(home: TeamAdministrationScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Noví hráči'), findsOneWidget);
    expect(find.text('Petr'), findsOneWidget);
    expect(find.byIcon(Icons.error), findsOneWidget);
  });

  testWidgets('pending section is hidden after rights are confirmed', (
    tester,
  ) async {
    const administration = TeamAdministrationApiModel(
      appTeamId: 12,
      teamName: 'Tým',
      ownerId: 1,
      ownerName: 'Admin',
      currentUserId: 1,
      readerCode: 'READ-CODE',
      editorCode: 'EDIT-CODE',
      members: [
        TeamMemberApiModel(
          userTeamRoleId: 40,
          userId: 2,
          userName: 'Petr',
          mail: 'petr@example.cz',
          role: 'VIEWER',
          owner: false,
          roleApproved: true,
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

    expect(find.text('Noví hráči'), findsNothing);
    expect(find.text('Členové týmu'), findsOneWidget);
    expect(find.text('Petr'), findsOneWidget);
  });

  testWidgets('shows both codes and keeps the founder locked', (tester) async {
    final administration = TeamAdministrationApiModel(
      appTeamId: 12,
      teamName: 'Nový tým',
      ownerId: 7,
      ownerName: 'Zakladatel',
      currentUserId: 7,
      readerCode: 'READ-CODE',
      editorCode: 'EDIT-CODE',
      members: [
        const TeamMemberApiModel(
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
          role: 'VIEWER',
          owner: false,
          hidden: true,
          roleApproved: false,
          lastLoginAt: DateTime(2026, 11, 7, 18, 30),
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
    expect(find.text('Odebrat administrátora'), findsNothing);
    expect(find.text('Poslední přihlášení: 7. 11. 2026 18:30'), findsOneWidget);
    expect(find.text('Skrytý uživatel'), findsOneWidget);
    expect(find.text('Čeká na potvrzení práv'), findsOneWidget);
    expect(find.byIcon(Icons.error), findsOneWidget);
    expect(find.byType(PopupMenuButton<String>), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('Odkrýt uživatele'), findsOneWidget);
    expect(find.text('Bez práv'), findsNWidgets(2));
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pumpAndSettle();
    expect(find.text('Zakladatel · Administrátor'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
  });
}

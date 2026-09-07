import 'package:trus_app/features/statistics/repository/stats_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/main/controller/navigation_guard.dart';
import 'package:trus_app/features/main/controller/screen_notifier.dart';
import 'package:trus_app/features/main/menu/upper_sheet_navigation_manager.dart';
import 'package:trus_app/features/main/widget/navigation_shell.dart';
import 'package:trus_app/features/main/widget/appbar/player_stats_app_bar_text.dart';
import 'package:trus_app/features/main/section_screen.dart';
import 'package:trus_app/features/beer/screens/beer_simple_screen.dart';
import 'package:trus_app/features/home/screens/rotating_stats_widget.dart';
import 'package:trus_app/models/api/home/stats_board_data.dart';
import 'package:trus_app/features/statistics/statistics_navigation.dart';
import 'package:trus_app/features/statistics/filter/statistics_filter_options.dart';
import 'package:trus_app/features/membership/repository/membership_api_service.dart';
import 'package:trus_app/features/team_administration/screens/team_administration_screen.dart';
import 'package:trus_app/features/user/screens/view_user_screen.dart';
import 'dart:async';
import 'package:trus_app/models/api/membership/membership.dart';
import 'package:trus_app/models/api/season_api_model.dart';
import 'package:trus_app/models/api/player/stats/player_stats.dart';
import 'ux_preview_capture.dart';

class _StatsApi implements StatsApiService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(loadPreviewFont);
  testWidgets('statistics combine categories and player or match views', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statsApiServiceProvider.overrideWithValue(_StatsApi()),
          statisticsSeasonsProvider.overrideWith(
            (ref) => Completer<List<SeasonApiModel>>().future,
          ),
        ],
        child: MaterialApp(
          theme: previewTheme(),
          home: const Scaffold(
            body: SectionScreen(section: 'statistics-hub', title: 'Statistiky'),
          ),
        ),
      ),
    );
    expect(find.byType(ChoiceChip), findsNWidgets(5));
    expect(find.text('Hráči'), findsOneWidget);
    expect(find.text('Zápasy'), findsOneWidget);
    expect(find.text('Podrobnosti'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Góly'));
    await tester.pump();
    expect(find.text('Podrobnosti'), findsNothing);
    await tester.tap(find.text('Zápasy'));
    await tester.pump();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SectionScreen)),
    );
    expect(
      container.read(statisticsSelectionProvider).category,
      StatisticsCategory.goal,
    );
    expect(container.read(statisticsSelectionProvider).view, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('upper menu keeps team administration with profile actions', (
    tester,
  ) async {
    String? selectedScreen;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          membershipProvider.overrideWith(
            (ref) async => Membership.fromJson(const {}),
          ),
        ],
        child: MaterialApp(
          theme: previewTheme(),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => UpperSheetNavigationManager(context, null)
                    .showBottomSheetNavigation(
                      (id) => selectedScreen = id,
                      'Uživatel',
                      null,
                      () {},
                      (_) {},
                      true,
                    ),
                child: const Text('Otevřít profil'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Otevřít profil'));
    await tester.pumpAndSettle();

    expect(find.text('PROFIL'), findsOneWidget);
    expect(find.text('Administrace týmu'), findsOneWidget);
    expect(find.text('SPRÁVA TÝMU'), findsNothing);
    expect(find.text('Smazat účet'), findsNothing);

    await tester.tap(find.text('Administrace týmu'));
    expect(selectedScreen, TeamAdministrationScreen.id);
    expect(tester.takeException(), isNull);
  });

  testWidgets('account deletion is hidden in user settings', (tester) async {
    var deleteRequested = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: previewTheme(),
        home: Scaffold(
          body: AccountDeletionOptions(onDelete: () => deleteRequested = true),
        ),
      ),
    );

    final moreOptions = find.text('Další možnosti účtu');
    expect(moreOptions, findsOneWidget);
    expect(find.text('Smazat účet'), findsNothing);

    await tester.ensureVisible(moreOptions);
    await tester.tap(moreOptions);
    await tester.pumpAndSettle();

    expect(find.text('Smazat účet'), findsOneWidget);
    await tester.tap(find.text('Smazat účet'));
    expect(deleteRequested, isTrue);
    expect(tester.takeException(), isNull);
  });

  test(
    'beer and fine tabs have direct destinations and back returns home',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final nav = container.read(screenNotifierProvider.notifier);
      await nav.changeByFragmentId('fine-match-screen');
      expect(
        container.read(screenNotifierProvider).selectedBottomSheetIndex,
        1,
      );
      await nav.changeByFragmentId(BeerSimpleScreen.id);
      expect(
        container.read(screenNotifierProvider).selectedBottomSheetIndex,
        2,
      );
      await nav.onBackButtonTap();
      expect(
        container.read(screenNotifierProvider).currentScreenId,
        'home-screen',
      );
    },
  );
  test(
    'back returns to the section of origin and tab changes clear history',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final nav = container.read(screenNotifierProvider.notifier);
      await nav.changeByFragmentId('more-hub');
      await nav.changeByFragmentId('player-screen');
      await nav.onBackButtonTap();
      expect(
        container.read(screenNotifierProvider).currentScreenId,
        'more-hub',
      );
      expect(
        container.read(screenNotifierProvider).selectedBottomSheetIndex,
        4,
      );
      await nav.changeByFragmentId('statistics-hub');
      expect(
        container.read(screenNotifierProvider).backButtonFragmentList,
        isEmpty,
      );
    },
  );

  test(
    'a rejected guard blocks back and home, an accepted guard continues',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final nav = container.read(screenNotifierProvider.notifier);
      await nav.changeByFragmentId(BeerSimpleScreen.id);
      container.read(navigationGuardProvider).guard = () async => false;
      await nav.onBackButtonTap();
      await nav.changeByFragmentId('home-screen');
      expect(
        container.read(screenNotifierProvider).currentScreenId,
        BeerSimpleScreen.id,
      );
      container.read(navigationGuardProvider).guard = () async => true;
      await nav.changeByFragmentId('fine-match-screen');
      expect(
        container.read(screenNotifierProvider).currentScreenId,
        'fine-match-screen',
      );
    },
  );

  for (final width in [320.0, 430.0]) {
    testWidgets('root navigation and focused editor at width $width', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(width, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var aiOpened = false;
      Widget shell(String id, Widget child) => ProviderScope(
        child: MaterialApp(
          theme: previewTheme(),
          home: NavigationShell(
            screenId: id,
            title: 'Více',
            teamName: 'Liščí Trus',
            selectedIndex: 4,
            onBack: () {},
            onHome: () {},
            onAccount: () {},
            onAi: () => aiOpened = true,
            onNotifications: () {},
            onDestination: (_) {},
            child: child,
          ),
        ),
      );
      await tester.pumpWidget(
        shell(
          'more-hub',
          const SectionScreen(section: 'more-hub', title: 'Více'),
        ),
      );
      expect(find.byType(BottomAppBar), findsOneWidget);
      expect(find.byKey(const ValueKey('beer_button')), findsOneWidget);
      expect(
        tester.getCenter(find.byKey(const ValueKey('beer_button'))).dy,
        lessThan(tester.getCenter(find.byType(BottomAppBar)).dy),
      );
      expect(find.text('Kroky'), findsOneWidget);
      expect(find.text('Achievementy'), findsOneWidget);
      expect(find.text('Upozornění na zápasy'), findsNothing);
      expect(find.text('Sezony'), findsNothing);
      expect(find.byTooltip('Oznámení'), findsNothing);
      expect(find.text('Zápasy'), findsOneWidget);
      expect(find.text('Odehrané'), findsNothing);
      expect(find.text('Správa týmu'), findsOneWidget);
      expect(find.text('Sazebník pokut'), findsNothing);
      expect(find.byTooltip('Účet a nastavení týmu'), findsOneWidget);
      expect(find.byIcon(Icons.manage_accounts), findsOneWidget);
      await tester.tap(find.byTooltip('AI asistent · TrusBot'));
      expect(aiOpened, isTrue);
      expect(find.byKey(const ValueKey('account_divider')), findsOneWidget);
      expect(find.byType(CircleAvatar), findsNothing);
      final appBarTitle = find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Více'),
      );
      expect(
        tester.getCenter(find.byKey(const ValueKey('account_button'))).dx,
        greaterThan(tester.getCenter(appBarTitle).dx),
      );
      expect(find.byType(BackButton), findsNothing);
      expect(tester.takeException(), isNull);
      await capturePreview(tester, 'entries-${width.toInt()}');
      await tester.tap(find.text('Správa týmu'));
      await tester.pumpAndSettle();
      expect(find.text('Sazebník pokut'), findsOneWidget);
      expect(find.text('Hráči'), findsOneWidget);
      expect(find.text('Sezony'), findsOneWidget);
      await tester.tap(find.text('Zápasy'));
      await tester.pumpAndSettle();
      expect(find.text('Odehrané'), findsOneWidget);
      expect(find.text('Program'), findsOneWidget);
      expect(find.text('Tabulka'), findsOneWidget);
      for (final editor in [
        'goal-screen',
        'beer-simple-screen',
        'fine-match-screen',
        'statistics-hub',
      ]) {
        await tester.pumpWidget(shell(editor, const Text('Obsah zápisu')));
        expect(find.byType(BottomAppBar), findsNothing);
        expect(find.byTooltip('Účet a nastavení týmu'), findsNothing);
        expect(find.byTooltip('Oznámení'), findsNothing);
        expect(find.byType(BackButton), findsOneWidget);
        expect(find.byTooltip('Zpět na přehled'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets(
    'root app bar displays the rotating current-season player stats',
    (tester) async {
      final stats = PlayerStats.fromJson({
        'playerAchievementCount': {
          'totalAchievements': 7,
          'accomplishedAchievements': 2,
        },
        'playerBeerCount': {'totalBeers': 4, 'totalLiquors': 1},
        'playerFineCount': {'totalFines': 150},
        'playerGoalCount': {'totalGoals': 3, 'totalAssists': 5},
        'playerFootbarCount': {'totalDistance': 12300.0},
        'season': {
          'id': 42,
          'name': 'Jaro 2026',
          'fromDate': '2026-03-01T00:00:00.000+01:00',
          'toDate': '2026-06-30T23:59:59.999+02:00',
        },
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: previewTheme(),
          home: NavigationShell(
            screenId: 'home-screen',
            title: 'Přehled',
            titleWidget: PlayerStatsAppBarText(stats: stats),
            teamName: 'Liščí Trus',
            selectedIndex: 0,
            onBack: () {},
            onHome: () {},
            onAccount: () {},
            onNotifications: () {},
            onDestination: (_) {},
            child: const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.text('Jaro 2026 | '), findsOneWidget);
      expect(find.text('2 / 7'), findsOneWidget);
      expect(find.text('Liščí Trus'), findsOneWidget);
      expect(find.byKey(const ValueKey('account_divider')), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('dashboard statistics remain stable until explicitly selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: previewTheme(),
        home: Scaffold(
          body: RotatingStatsWidget(
            statsBoards: [
              StatsBoardData.fromJson({
                'title': 'Piva',
                'headers': [],
                'rows': [],
              }),
              StatsBoardData.fromJson({
                'title': 'Góly',
                'headers': [],
                'rows': [],
              }),
            ],
            onRedirect: (_) {},
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 30));
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Piva'))
          .selected,
      isTrue,
    );
    await tester.tap(find.widgetWithText(ChoiceChip, 'Góly'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Góly'))
          .selected,
      isTrue,
    );
  });
}

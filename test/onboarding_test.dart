import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:trus_app/theme/app_theme.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/auth/repository/auth_repository.dart';
import 'package:trus_app/features/onboarding/onboarding_card.dart';
import 'package:trus_app/features/onboarding/onboarding_entry.dart';
import 'package:trus_app/common/repository/exception/server_exception.dart';
import 'package:trus_app/features/onboarding/onboarding_permissions.dart';
import 'package:trus_app/features/onboarding/onboarding_repository.dart';
import 'package:trus_app/features/onboarding/onboarding_screen.dart';
import 'package:trus_app/features/notification/repository/notification_api_service.dart';
import 'package:trus_app/models/api/notification/push/enabled_push_notification.dart';
import 'package:trus_app/models/api/notification/push/notification_type.dart';
import 'package:trus_app/models/helper/title_and_text.dart';

class FakeOnboarding extends Fake implements OnboardingRepository {
  int? pairedPlayerId;
  int? pairedFootballId;
  @override
  Future<PlayerApiModel> pair({
    int? footballPlayerId,
    int? playerId,
    String? name,
    DateTime? birthday,
    bool fan = false,
  }) async {
    pairedPlayerId = playerId;
    pairedFootballId = footballPlayerId;
    throw ServerException('Test stops after request capture');
  }

  final List<OnboardingStep?> advances = [];
  bool failProfiles = false;
  bool failStart = false;
  Completer<OnboardingProfiles>? pendingProfiles;
  OnboardingProgress progress = const OnboardingProgress(
    available: true,
    autoShow: true,
    completed: {},
  );
  @override
  Future<OnboardingProgress> load() async => progress;
  @override
  Future<OnboardingProgress> start() async {
    if (failStart) throw ServerException('Endpoint není dostupný');
    return advance();
  }

  @override
  Future<OnboardingProgress> advance([OnboardingStep? step]) async {
    advances.add(step);
    progress = OnboardingProgress(
      available: true,
      autoShow: false,
      completed: {...progress.completed, if (step != null) step},
    );
    return progress;
  }

  @override
  Future<OnboardingProfiles> profiles() async {
    if (pendingProfiles != null) return pendingProfiles!.future;
    if (failProfiles) throw StateError('offline');
    return OnboardingProfiles({
      'name': 'Matěj',
      'currentPlayer': null,
      'footballPlayers': [
        {'id': 30, 'name': 'Fotbalista', 'linkedPlayerId': null},
        {'id': 31, 'name': 'Zabraný fotbalista', 'linkedPlayerId': 99},
      ],
      'candidates': [
        {
          'player': {'id': 1, 'name': 'Volný', 'birthday': '1995-01-01'},
          'occupied': false,
          'score': 80,
        },
        {
          'player': {'id': 2, 'name': 'Obsazený', 'birthday': '1995-01-01'},
          'occupied': true,
          'score': 100,
        },
      ],
    });
  }
}

class FakePermissions extends Fake implements OnboardingPermissions {
  final List<String> events;
  bool allowed = true;
  FakePermissions(this.events);
  @override
  Future<bool> notifications() async {
    events.add('permission');
    return allowed;
  }

  @override
  Future<bool> steps() async {
    events.add('steps');
    return allowed;
  }
}

class FakeNotifications extends Fake implements NotificationApiService {
  final List<String> events;
  bool failSave = false;
  List<EnabledPushNotification>? saved;
  FakeNotifications(this.events);
  @override
  Future<List<EnabledPushNotification>> getEnabledNotifications() async => [
    for (final type in [
      NotificationType.global,
      NotificationType.playerAchievement,
    ])
      EnabledPushNotification(
        id: type.index,
        type: type,
        enabled: true,
        userId: 1,
        modificationTime: DateTime(2026),
      ),
  ];
  @override
  Future<TitleAndText> editNotificationsPermit(
    List<EnabledPushNotification> items,
  ) async {
    events.add('save');
    if (failSave) throw StateError('offline');
    saved = items;
    return TitleAndText(title: '', text: '');
  }
}

class FakeAuth extends Fake implements AuthRepository {
  @override
  String returnUserId() => 'user-1';
}

void main() {
  late FakeOnboarding repo;
  late FakePermissions permissions;
  late FakeNotifications notifications;
  late List<String> events;
  setUp(() {
    events = [];
    repo = FakeOnboarding();
    permissions = FakePermissions(events);
    notifications = FakeNotifications(events);
  });

  Future<void> showStep(WidgetTester tester, OnboardingStep step) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingRepositoryProvider.overrideWithValue(repo),
          onboardingPermissionsProvider.overrideWithValue(permissions),
          notificationApiServiceProvider.overrideWithValue(notifications),
        ],
        child: MaterialApp(
          home: OnboardingScreen(
            initial: OnboardingProgress(
              available: true,
              autoShow: false,
              completed: OnboardingStep.values.take(step.index).toSet(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  test('progress tolerates future steps and resumes first incomplete step', () {
    final progress = OnboardingProgress.fromJson({
      'available': true,
      'autoShow': false,
      'completed': ['INTRO', 'FUTURE'],
    });
    expect(progress.nextIndex, 0);
    expect(progress.finished, false);
    expect(progress.completed, {OnboardingStep.intro});
  });

  testWidgets(
    'occupied profile is disabled and free profile requires explicit confirmation',
    (tester) async {
      await showStep(tester, OnboardingStep.profile);
      final occupied = tester.widget<ListTile>(
        find.widgetWithText(ListTile, 'Obsazený'),
      );
      expect(occupied.onTap, isNull);
      await tester.tap(find.text('Volný'));
      await tester.tap(find.text('Pokračovat'));
      // The guarded action keeps a progress indicator alive behind the dialog.
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('Je to opravdu tvůj profil?'), findsOneWidget);
      await tester.tap(find.text('Zpět'));
      await tester.pumpAndSettle();
      expect(repo.advances, isEmpty);
      expect(events, isEmpty);
    },
  );

  testWidgets(
    'missing player validation stays visible outside the scrolling list',
    (tester) async {
      await showStep(tester, OnboardingStep.profile);
      await tester.tap(find.text('Pokračovat'));
      await tester.pumpAndSettle();
      expect(find.text('Musíš si vybrat hráče.'), findsOneWidget);
      final error = tester.getRect(
        find.byKey(const ValueKey('onboarding-validation')),
      );
      final list = tester.getRect(
        find.byKey(const ValueKey('onboarding-list')),
      );
      final footer = tester.getRect(
        find.byKey(const ValueKey('onboarding-footer')),
      );
      expect(error.top, greaterThanOrEqualTo(list.bottom));
      expect(error.bottom, lessThanOrEqualTo(footer.top));
    },
  );

  testWidgets(
    'football selection is only available for a new profile and cleared when switching back',
    (tester) async {
      await showStep(tester, OnboardingStep.profile);
      await tester.tap(find.text('Volný'));
      await tester.pumpAndSettle();
      final dropdown = find.byType(DropdownButtonFormField<int>);
      expect(dropdown, findsNothing);
      final create = find.text('Nejsem v seznamu – vytvořit nový profil');
      await tester.ensureVisible(create);
      await tester.tap(create);
      await tester.pumpAndSettle();
      final listScrollable = find.descendant(
        of: find.byKey(const ValueKey('onboarding-list')),
        matching: find.byType(Scrollable),
      ).first;
      await tester.scrollUntilVisible(dropdown, 200, scrollable: listScrollable);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      final occupied = tester.widget<DropdownMenuItem<int>>(
        find
            .widgetWithText(
              DropdownMenuItem<int>,
              'Zabraný fotbalista · Už propojeno',
            )
            .last,
      );
      expect(occupied.enabled, false);
      await tester.tap(find.text('Fotbalista').last);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(create, -200, scrollable: listScrollable);
      await tester.tap(create);
      await tester.pumpAndSettle();
      expect(dropdown, findsNothing);
      await tester.tap(find.text('Pokračovat'));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.tap(find.text('Ano, to jsem já'));
      await tester.pumpAndSettle();
      expect(repo.pairedPlayerId, 1);
      expect(repo.pairedFootballId, isNull);
    },
  );

  for (final dark in [false, true]) {
    testWidgets(
      'opaque chrome and visible name field in ${dark ? 'dark' : 'light'} theme',
      (tester) async {
        final theme = dark ? AppTheme.dark() : AppTheme.light();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [onboardingRepositoryProvider.overrideWithValue(repo)],
            child: MaterialApp(
              theme: theme,
              home: const OnboardingScreen(
                initial: OnboardingProgress(
                  available: true,
                  autoShow: false,
                  completed: {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester.widget<AppBar>(find.byType(AppBar)).backgroundColor,
          theme.colorScheme.surface,
        );
        expect(
          tester
              .widget<Material>(find.byKey(const ValueKey('onboarding-footer')))
              .color,
          theme.colorScheme.surface,
        );
        final create = find.text('Nejsem v seznamu – vytvořit nový profil');
        await tester.ensureVisible(create);
        await tester.tap(create);
        await tester.pumpAndSettle();
        final name = tester.widget<TextField>(
          find.byKey(const ValueKey('onboarding-player-name')),
        );
        expect(name.decoration!.filled, true);
        expect(
          (name.decoration!.enabledBorder as OutlineInputBorder)
              .borderSide
              .style,
          BorderStyle.solid,
        );
        expect(name.style!.color, theme.colorScheme.onSurface);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Rozumím stays on one line on narrow display with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await showStep(tester, OnboardingStep.intro);
    final text = tester.widget<Text>(find.text('Rozumím'));
    expect(text.softWrap, false);
    final paragraph = tester.renderObject<RenderParagraph>(
      find.text('Rozumím'),
    );
    expect(paragraph.didExceedMaxLines, false);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'all steps can be skipped without permissions or marking completion',
    (tester) async {
      await showStep(tester, OnboardingStep.profile);
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('Přeskočit'));
        await tester.pumpAndSettle();
      }
      expect(find.text('Máš Footbar?'), findsOneWidget);
      expect(repo.advances, isEmpty);
      expect(events, isEmpty);
    },
  );

  testWidgets('failed profile load is skippable', (tester) async {
    repo.failProfiles = true;
    await showStep(tester, OnboardingStep.profile);
    expect(find.textContaining('Akci se nepodařilo'), findsOneWidget);
    await tester.tap(find.text('Přeskočit'));
    await tester.pumpAndSettle();
    expect(find.text('Co v appce najdeš'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'slow profile lookup can be skipped and its late error is ignored',
    (tester) async {
      repo.pendingProfiles = Completer<OnboardingProfiles>();
      await showStep(tester, OnboardingStep.profile);
      await tester.tap(find.text('Přeskočit'));
      await tester.pumpAndSettle();
      expect(find.text('Co v appce najdeš'), findsOneWidget);
      repo.pendingProfiles!.completeError(StateError('late network error'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Akci se nepodařilo'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('notifications save selected categories before permission', (
    tester,
  ) async {
    await showStep(tester, OnboardingStep.notifications);
    expect(events, isEmpty);
    await tester.tap(find.text('Když dostanu achievement'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Uložit volby'));
    await tester.pumpAndSettle();
    expect(events, ['save', 'permission']);
    expect(notifications.saved!.last.enabled, false);
    expect(repo.advances, [OnboardingStep.notifications]);
    expect(find.text('Každý krok se počítá'), findsOneWidget);
  });

  testWidgets('global opt-out never requests OS permission', (tester) async {
    await showStep(tester, OnboardingStep.notifications);
    await tester.tap(find.text('Chci dostávat upozornění'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Uložit volby'));
    await tester.pumpAndSettle();
    expect(events, ['save']);
    expect(notifications.saved!.first.enabled, false);
  });

  testWidgets('failed category save never asks for permission', (tester) async {
    notifications.failSave = true;
    await showStep(tester, OnboardingStep.notifications);
    await tester.tap(find.text('Uložit volby'));
    await tester.pumpAndSettle();
    expect(events, ['save']);
    expect(repo.advances, isEmpty);
    expect(find.text('Oznámení podle tebe'), findsOneWidget);
  });

  testWidgets('denied permission stays on step and remains skippable', (
    tester,
  ) async {
    permissions.allowed = false;
    await showStep(tester, OnboardingStep.notifications);
    await tester.tap(find.text('Uložit volby'));
    await tester.pumpAndSettle();
    expect(repo.advances, isEmpty);
    expect(find.textContaining('systém oznámení nepovolil'), findsOneWidget);
    await tester.tap(find.text('Přeskočit'));
    await tester.pumpAndSettle();
    expect(find.text('Každý krok se počítá'), findsOneWidget);
  });

  testWidgets('steps ask only after explicit action and advance on success', (
    tester,
  ) async {
    await showStep(tester, OnboardingStep.steps);
    expect(events, isEmpty);
    await tester.tap(find.text('Povolit kroky'));
    await tester.pumpAndSettle();
    expect(events, ['steps']);
    expect(repo.advances, [OnboardingStep.steps]);
    expect(find.text('Máš Footbar?'), findsOneWidget);
  });

  testWidgets('denied health permission does not complete the step', (
    tester,
  ) async {
    permissions.allowed = false;
    await showStep(tester, OnboardingStep.steps);
    await tester.tap(find.text('Povolit kroky'));
    await tester.pumpAndSettle();
    expect(repo.advances, isEmpty);
    expect(
      find.textContaining('Přístup ke krokům nebyl udělen'),
      findsOneWidget,
    );
  });

  testWidgets(
    'small screen with large text remains scrollable without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await showStep(tester, OnboardingStep.notifications);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('settings offers incomplete onboarding without opening it', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingRepositoryProvider.overrideWithValue(repo),
          authRepositoryProvider.overrideWithValue(FakeAuth()),
        ],
        child: const MaterialApp(home: Scaffold(body: OnboardingCard())),
      ),
    );
    await tester.pumpAndSettle();
    expect(repo.advances, isEmpty);
    await tester.pump();
    expect(repo.advances, isEmpty);
    expect(find.text('Dokončit nastavení'), findsOneWidget);
  });

  for (final available in [true, false]) {
    testWidgets(
      'settings hides ${available ? 'completed' : 'legacy'} onboarding',
      (tester) async {
        repo.progress = OnboardingProgress(
          available: available,
          autoShow: false,
          completed: available ? OnboardingStep.values.toSet() : {},
        );
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              onboardingRepositoryProvider.overrideWithValue(repo),
              authRepositoryProvider.overrideWithValue(FakeAuth()),
            ],
            child: const MaterialApp(home: Scaffold(body: OnboardingCard())),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Dokončit nastavení'), findsNothing);
        expect(repo.advances, isEmpty);
      },
    );
  }

  Future<void> showRegistration(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [onboardingRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const OnboardingEntry(),
                    ),
                  );
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            const Scaffold(body: Text('Hlavní aplikace')),
                      ),
                    );
                  }
                },
                child: const Text('Dokončit výběr týmu'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Dokončit výběr týmu'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'registration shows guide before main and Later continues into app',
    (tester) async {
      await showRegistration(tester);
      expect(find.text('Kdo jsi v týmu?'), findsOneWidget);
      expect(find.text('Hlavní aplikace'), findsNothing);
      expect(repo.advances, [null]);
      await tester.tap(find.text('Později'));
      await tester.pumpAndSettle();
      expect(find.text('Hlavní aplikace'), findsOneWidget);
    },
  );

  testWidgets('failed start is retryable and does not block entry into app', (
    tester,
  ) async {
    repo.failStart = true;
    await showRegistration(tester);
    expect(find.textContaining('Endpoint není dostupný'), findsOneWidget);
    expect(find.text('Zkusit znovu'), findsOneWidget);
    await tester.tap(find.text('Dokončit později'));
    await tester.pumpAndSettle();
    expect(find.text('Hlavní aplikace'), findsOneWidget);
  });

  testWidgets(
    'retry of failed start opens guide without repeating registration',
    (tester) async {
      repo.failStart = true;
      await showRegistration(tester);
      repo.failStart = false;
      await tester.tap(find.text('Zkusit znovu'));
      await tester.pumpAndSettle();
      expect(find.text('Kdo jsi v týmu?'), findsOneWidget);
      expect(repo.advances, [null]);
    },
  );
}

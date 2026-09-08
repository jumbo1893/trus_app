import '../../common/widgets/entry_draft_scope.dart';
import 'widget/navigation_shell.dart';
import '../ai/screens/ai_assistant_screen.dart';
import 'controller/navigation_guard.dart';
import '../beer/controller/beer_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/bottomsheet/fine_stats_detail_bottom_sheet.dart';
import 'package:trus_app/common/widgets/bottomsheet/loading_bottom_sheet.dart';
import 'package:trus_app/common/widgets/bottomsheet/simple_bottom_sheet.dart';
import 'package:trus_app/common/widgets/bottomsheet/stats_detail_bottom_sheet.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:trus_app/features/auth/login/screens/login_screen.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/features/main/screens.dart';
import 'package:trus_app/features/main/state/main_state.dart';
import 'package:trus_app/features/main/menu/statistics_sheet_navigation_manager.dart';
import 'package:trus_app/features/main/ui/ui_effect.dart';
import 'package:trus_app/features/main/ui/ui_feedback_notifier.dart';
import 'package:trus_app/features/main/ui/ui_feedback_state.dart';
import 'package:trus_app/features/main/menu/upper_sheet_navigation_manager.dart';
import 'package:trus_app/features/main/widget/appbar/player_stats_app_bar_text.dart';

import '../../common/utils/utils.dart';
import '../../common/widgets/bottomsheet/confirm_action_bottom_sheet.dart';
import '../../common/widgets/bottomsheet/push_notification_bottom_sheet.dart';
import '../../common/widgets/confirmation_dialog.dart';
import '../../models/api/player/player_api_model.dart';
import '../../services/push/push_navigation_handler.dart';
import '../auth/controller/auth_controller.dart';

import '../beer/screens/beer_simple_screen.dart';
import '../general/error/api_executor.dart';
import '../home/screens/home_screen.dart';
import '../notification/screen/notification_screen.dart';
import '../steps/service/step_sync_scheduler.dart';
import 'menu/bottom_sheet_navigation_manager.dart';
import 'controller/back_handler.dart';
import 'controller/main_notifier.dart';
import 'controller/screen_notifier.dart';
import 'main_ui_event_type.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  static const routeName = '/main-screen';

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final PageController pageController = PageController();

  late BottomSheetNavigationManager _bottomSheetNavigationManager;
  late UpperSheetNavigationManager _upperSheetNavigationManager;
  late StatisticsSheetNavigationManager _statisticsSheetNavigationManager;

  late final ProviderSubscription<MainState> _mainSub;
  late final ProviderSubscription<int> _pageSub;
  late final ProviderSubscription<UiFeedbackState> _uiSub;
  bool _loadingSheetVisible = false;
  late final VoidCallback _unregisterNavigationGuard;

  @override
  void initState() {
    super.initState();
    _unregisterNavigationGuard = ref
        .read(navigationGuardProvider)
        .register(_confirmLeave);

    final appTeam = ref.read(globalVariablesControllerProvider).appTeam;
    ref.read(stepSyncSchedulerProvider).startForegroundMonitoring();

    _bottomSheetNavigationManager = BottomSheetNavigationManager(
      context,
      appTeam,
    );
    _upperSheetNavigationManager = UpperSheetNavigationManager(
      context,
      appTeam,
    );
    _statisticsSheetNavigationManager = StatisticsSheetNavigationManager(
      context,
      appTeam,
    );
    _mainSub = ref.listenManual<MainState>(mainNotifierProvider, (prev, next) {
      final ev = next.uiEvent;
      if (ev == null) return;

      if (prev?.uiEvent?.id == ev.id) return;

      // ✅ UI věci až po vykreslení frame
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        // 1) clear hned, aby se to neopakovalo
        ref.read(mainNotifierProvider.notifier).clearUiEvent();

        switch (ev.type) {
          case MainUiEventType.openBottomMenu:
            showBottomSheetNavigation(next.userName);
            break;
          case MainUiEventType.openUpperMenu:
            await showUpperSheetNavigation(next.userName);
            break;
          case MainUiEventType.openStatsMenu:
            showStatisticsSheetNavigation();
            break;
          case MainUiEventType.confirmDelete:
            showDeleteConfirmationDialog();
            break;
          case MainUiEventType.pop:
            Navigator.of(context).pop();
            break;
          default:
            break;
        }
      });
    });

    _pageSub = ref.listenManual<int>(
      screenNotifierProvider.select((s) => s.currentPageIndex),
      (prev, next) {
        if (prev == next) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          pageController.jumpToPage(next);
        });
      },
    );

    // ať skočíš i na start (pokud currentPageIndex != 0 nebo chceš jistotu):
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !pageController.hasClients) return;
      final idx = ref.read(screenNotifierProvider).currentPageIndex;
      pageController.jumpToPage(idx);
    });

    _uiSub = ref.listenManual<UiFeedbackState>(uiFeedbackProvider, (
      prev,
      next,
    ) {
      if (next.effects.isEmpty) return;

      // ✅ vezmu první efekt
      final effect = next.effects.first;

      // ✅ a hned ho "consume", aby už nikdy nemohl spustit další callback
      final ui = ref.read(uiFeedbackProvider.notifier);
      ui.consumeFirstEffect();

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        switch (effect) {
          case UiSnack():
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(effect.message),
                duration: effect.duration,
                action: effect.actionLabel != null && effect.onAction != null
                    ? SnackBarAction(
                        label: effect.actionLabel!,
                        onPressed: effect.onAction!,
                      )
                    : null,
                behavior: SnackBarBehavior.floating,
              ),
            );
            break;

          case UiErrorDialog():
            await showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(effect.title),
                content: Text(effect.message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("OK"),
                  ),
                ],
              ),
            );
            break;
          case UiConfirmationDialog():
            await showDialog(
              context: context,
              builder: (_) =>
                  ConfirmationDialog(effect.message, effect.continueCallBack),
            );
            break;
          case UiConfirmationSheet():
            ConfirmActionBottomSheet.show(
              context,
              title: "Potvrdit akci",
              message: effect.message,
              confirmText: "Potvrdit",
              cancelText: "Zrušit",
              icon: Icons.done,
              isDanger: true,
              onConfirm: () async => effect.continueCallBack,
            );
          case UiLoadingSheet():
            if (_loadingSheetVisible) return;

            _loadingSheetVisible = true;

            LoadingBottomSheet.show(
              context,
              title: effect.message,
            ).whenComplete(() {
              _loadingSheetVisible = false;
            });
            break;

          case UiHideLoadingSheet():
            if (_loadingSheetVisible && mounted) {
              Navigator.of(context, rootNavigator: true).pop();
            }
            break;
          case UiSimpleSheet():
            SimpleBottomSheet.show(
              context,
              title: effect.title,
              message: effect.message,
            );
          case UiStatsBottomSheet():
            StatsDetailBottomSheet.show(
              context,
              title: effect.title,
              subtitle: effect.subtitle,
              items: effect.items,
            );
          case UiFineStatsBottomSheet():
            FineStatsDetailBottomSheet.show(
              context,
              title: effect.title,
              subtitle: effect.subtitle,
              response: effect.response,
            );
          case UiPushNotificationSheet():
            PushNotificationBottomSheet.show(
              context,
              title: effect.payload.title,
              message: effect.payload.body,
              navigateText: effect.payload.navigateText ?? "Mrknu na to!",
              onOk: () {
                Navigator.of(context).pop();
              },
              onGo: () {
                Navigator.of(context).pop();
                PushNavigationHandler.navigate(
                  PushNavigationRef(read: ref.read, invalidate: ref.invalidate),
                  effect.payload,
                );
              },
            );
            break;
        }
      });
    });
  }

  @override
  void dispose() {
    _unregisterNavigationGuard();
    pageController.dispose();
    _mainSub.close();
    _pageSub.close();
    _uiSub.close();
    super.dispose();
  }

  /// Odhlásí uživatele a přepne na Login obrazovku
  Future<void> signOut() async {
    bool? result = await executeApi<bool?>(
      () async {
        return await ref.read(authControllerProvider).signOut();
      },
      () => showBottomSheetNavigation(""),
      context,
      true,
    );

    if (result != null && result) {
      ref.read(screenNotifierProvider.notifier).resetTo(HomeScreen.id);
      Navigator.pushNamedAndRemoveUntil(
        context,
        LoginScreen.routeName,
        (route) => false,
      );
      showSnackBarWithPostFrame(
        context: context,
        content: "Děkujeme, přijďte zas",
      );
    }
  }

  PlayerApiModel? getPlayerSelectedInUserProfile() {
    return ref.read(globalVariablesControllerProvider).playerApiModel;
  }

  Future<void> showDeleteConfirmationDialog() async {
    var dialog = ConfirmationDialog(
      "Opravdu chcete smazat tento účet?",
      () async {
        await executeApi<void>(
          () async {
            return await ref.read(authControllerProvider).deleteAccount();
          },
          () {},
          context,
          true,
        ).then((value) => signOut());
      },
    );
    showDialog(context: context, builder: (BuildContext context) => dialog);
  }

  /// Zobrazí postraní menu
  void showBottomSheetNavigation(String name) {
    _bottomSheetNavigationManager.showBottomSheetNavigation(
      (id) => ref
          .read(mainNotifierProvider.notifier)
          .onModalBottomSheetMenuTapped(id),
      name,
      () => signOut(),
    );
  }

  /// Zobrazí postraní menu
  Future<void> showUpperSheetNavigation(String name) async {
    bool isTeamAdministrator = false;
    try {
      final user = await ref.read(authControllerProvider).getUserData();
      final currentAppTeamId = ref
          .read(globalVariablesControllerProvider)
          .appTeam
          ?.id;
      isTeamAdministrator =
          user?.getCurrentUserTeamRole(currentAppTeamId)?.role == 'ADMIN';
    } catch (_) {
      // Nastavení profilu zůstane dostupné i při dočasném výpadku kontroly role.
    }
    if (!mounted) return;
    _upperSheetNavigationManager.showBottomSheetNavigation(
      (id) => ref
          .read(mainNotifierProvider.notifier)
          .onModalBottomSheetMenuTapped(id),
      name,
      getPlayerSelectedInUserProfile(),
      () => signOut(),
      (player) =>
          ref.read(screenVariablesNotifierProvider.notifier).setPlayer(player),
      isTeamAdministrator,
    );
  }

  void showStatisticsSheetNavigation() {
    _statisticsSheetNavigationManager.showBottomSheetNavigation(
      (id) => ref
          .read(mainNotifierProvider.notifier)
          .onModalBottomSheetMenuTapped(id),
    );
  }

  Future<bool> _confirmLeave() async {
    final session = ref.read(
      entrySessionsProvider,
    )[ref.read(screenNotifierProvider).currentScreenId];
    if (session != null) return session.confirmLeave();
    if (ref.read(screenNotifierProvider).currentScreenId !=
            BeerSimpleScreen.id ||
        !ref.read(beerNotifierProvider).hasChanges)
      return true;
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Neuložené změny'),
        content: const Text(
          'V zápisu piv máš neuložené změny. Chceš je před odchodem uložit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'stay'),
            child: const Text('Zůstat'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'discard'),
            child: const Text('Zahodit'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'save'),
            child: const Text('Uložit'),
          ),
        ],
      ),
    );
    if (!mounted) return false;
    if (choice == 'discard') {
      ref.read(beerNotifierProvider.notifier).discardChanges();
      return true;
    }
    if (choice != 'save') return false;
    try {
      await ref.read(beerNotifierProvider.notifier).changeBeers();
      return !ref.read(beerNotifierProvider).hasChanges;
    } catch (_) {
      return false;
    }
  }

  void _handleBack() {
    final handler = ref.read(backHandlerProvider);

    if (ref.read(screenNotifierProvider).currentScreenId !=
            BeerSimpleScreen.id &&
        handler != null &&
        handler.onBack()) {
      return;
    }

    ref.read(screenNotifierProvider.notifier).onBackButtonTap();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenState = ref.watch(screenNotifierProvider);
    final mainState = ref.watch(mainNotifierProvider);
    final notifier = ref.read(mainNotifierProvider.notifier);
    final screenNotifier = ref.read(screenNotifierProvider.notifier);
    final uiState = ref.watch(uiFeedbackProvider);
    final teamName = ref.watch(globalVariablesControllerProvider).appTeam?.name;
    final pageTitle = screenState.currentScreenId == HomeScreen.id
        ? 'Přehled'
        : screenState.appBarTitleText;

    return Stack(
      children: [
        AbsorbPointer(
          absorbing: uiState.isLoading,
          // MainScreen is the authenticated root of the app and must never be
          // popped by the system back gesture/button. Back only navigates the
          // in-app screen history; on the dashboard that history is empty, so
          // back intentionally does nothing. Routes above MainScreen (dialogs,
          // sheets and the authentication flow) keep their own pop behaviour.
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) _handleBack();
            },
            child: NavigationShell(
              screenId: screenState.currentScreenId,
              title: pageTitle,
              titleWidget: screenState.showPlayerStatsTitle
                  ? mainState.playerStats.when(
                      data: (stats) => PlayerStatsAppBarText(stats: stats),
                      loading: () => Text(pageTitle),
                      error: (_, __) => Text(pageTitle),
                    )
                  : null,
              teamName: teamName,
              selectedIndex: screenState.selectedBottomSheetIndex,
              onBack: _handleBack,
              onHome: () => screenNotifier.changeByFragmentId(HomeScreen.id),
              onAccount: notifier.onUpperMenuTapped,
              onAi: () =>
                  screenNotifier.changeByFragmentId(AiAssistantScreen.id),
              onNotifications: () =>
                  screenNotifier.changeByFragmentId(NotificationScreen.id),
              onDestination: notifier.onBottomMenuTapped,
              child: PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: widgetList,
              ),
            ),
          ),
        ),
        if (uiState.isLoading)
          Container(
            color: appColors.overlayBackground,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: colorScheme.onPrimary),
                    if (uiState.loadingMessage != null) ...[
                      SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 250),
                        child: Text(
                          uiState.loadingMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: appColors.buttonForeground,
                            fontSize: 15,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

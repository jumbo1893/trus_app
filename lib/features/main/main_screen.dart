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
import '../notification/screen/notification_screen.dart';
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

  @override
  void initState() {
    super.initState();
    final appTeam = ref.read(globalVariablesControllerProvider).appTeam;

    _bottomSheetNavigationManager = BottomSheetNavigationManager(context, appTeam);
    _upperSheetNavigationManager = UpperSheetNavigationManager(context, appTeam);
    _statisticsSheetNavigationManager = StatisticsSheetNavigationManager(context, appTeam);
    _mainSub = ref.listenManual<MainState>(
      mainNotifierProvider,
          (prev, next) {
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
              showUpperSheetNavigation(next.userName);
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
      },
    );

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
      final idx = ref.read(screenNotifierProvider).currentPageIndex;
      pageController.jumpToPage(idx);
    });

    _uiSub = ref.listenManual<UiFeedbackState>(
      uiFeedbackProvider,
          (prev, next) {
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
                builder: (_) => ConfirmationDialog(
                    effect.message, effect.continueCallBack
                ),
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
                  items: effect.items
              );
            case UiFineStatsBottomSheet():
              FineStatsDetailBottomSheet.show(
                  context,
                  title: effect.title,
                  subtitle: effect.subtitle,
                  response: effect.response
              );
            case UiPushNotificationSheet():
              PushNotificationBottomSheet.show(
                context,
                title: effect.payload.title,
                message: effect.payload.body,
                navigateText: effect.payload.navigateText?? "Mrknu na to!",
                onOk: () {
                  Navigator.of(context).pop();
                },
                onGo: () {
                  Navigator.of(context).pop();
                  PushNavigationHandler.navigate(ref, effect.payload);
                },
              );
              break;
          }
        });
      },
    );
  }

  @override
  void dispose() {
    _mainSub.close();
    _pageSub.close();
    _uiSub.close();
    super.dispose();
  }

  /// Odhlásí uživatele a přepne na Login obrazovku
  Future<void> signOut() async {
    bool? result = await executeApi<bool?>(() async {
      return await ref.read(authControllerProvider).signOut();
    }, () => showBottomSheetNavigation(""), context, true);

    if (result != null && result) {
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
        await executeApi<void>(() async {
          return await ref.read(authControllerProvider).deleteAccount();
        }, () {}, context, true).then((value) => signOut());
      },
    );
    showDialog(
      context: context,
      builder: (BuildContext context) => dialog,
    );
  }

  /// Zobrazí postraní menu
  void showBottomSheetNavigation(String name) {
    _bottomSheetNavigationManager.showBottomSheetNavigation(
          (id) => ref.read(mainNotifierProvider.notifier).onModalBottomSheetMenuTapped(id),
      name,
          () => signOut(),
    );
  }

  /// Zobrazí postraní menu
  void showUpperSheetNavigation(String name) {
    _upperSheetNavigationManager.showBottomSheetNavigation(
          (id) => ref.read(mainNotifierProvider.notifier).onModalBottomSheetMenuTapped(id),
      name,
      getPlayerSelectedInUserProfile(),
          () => signOut(),
          (player) => ref.read(screenVariablesNotifierProvider.notifier).setPlayer(player),
    );
  }

  void showStatisticsSheetNavigation() {
    _statisticsSheetNavigationManager.showBottomSheetNavigation(
          (id) => ref.read(mainNotifierProvider.notifier).onModalBottomSheetMenuTapped(id),
    );
  }

  Future<bool> _onWillPop() async {
    final handler = ref.read(backHandlerProvider);

    if (handler != null && handler.onBack()) {
      return false;
    }

    ref.read(screenNotifierProvider.notifier).onBackButtonTap();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenState = ref.watch(screenNotifierProvider);
    final state = ref.watch(mainNotifierProvider);
    final notifier = ref.read(mainNotifierProvider.notifier);
    final screenNotifier = ref.read(screenNotifierProvider.notifier);
    final uiState = ref.watch(uiFeedbackProvider);

    return Stack(
      children: [
        AbsorbPointer(
          absorbing: uiState.isLoading,
          child: WillPopScope(
            onWillPop: _onWillPop,
            child:
            Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                leading: screenState.backButtonVisible
                    ? BackButton(
                  onPressed: () {
                    final handler = ref.read(backHandlerProvider);
                    if (handler != null && handler.onBack()) {
                      return;
                    }
                    screenNotifier.onBackButtonTap();
                  },
                )
                    : null,
                title: screenState.showPlayerStatsTitle
                    ? state.playerStats.when(
                  data: (stats) => PlayerStatsAppBarText(stats: stats),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                )
                    : FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(screenState.appBarTitleText),
                ),
                actions: [
                  IconButton(
                    key: const ValueKey('account_button'),
                    onPressed: notifier.onUpperMenuTapped,
                    icon: const Icon(Icons.manage_accounts),
                  ),
                  IconButton(
                    key: const ValueKey('notifications_button'),
                    onPressed: () => screenNotifier.changeByFragmentId(NotificationScreen.id),
                    icon: const Icon(Icons.notifications),
                  ),
                ],
              ),
              body: PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: widgetList,
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => screenNotifier.changeByFragmentId(BeerSimpleScreen.id),
                key: const ValueKey('beer_button'),
                child: const Icon(Icons.sports_bar_outlined),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: BottomNavigationBar(
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.home, key: ValueKey('home_button')),
                    label: "Přehled",
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.savings, key: ValueKey('fine_button')),
                    label: "Pokuty",
                  ),
                  BottomNavigationBarItem(label: "", icon: Container()),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.equalizer, key: ValueKey('stats_button')),
                    label: "Statistiky",
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.menu, key: ValueKey('menu_button')),
                    label: "Menu",
                  ),
                ],
                currentIndex: screenState.selectedBottomSheetIndex,
                onTap: notifier.onBottomMenuTapped,
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

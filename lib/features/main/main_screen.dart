import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/features/auth/login/screens/login_screen.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';
import 'package:trus_app/features/general/screen_name.dart';
import 'package:trus_app/features/goal/screen/goal_screen.dart';
import 'package:trus_app/features/main/controller/main_controller.dart';
import 'package:trus_app/features/main/screen_controller.dart';
import 'package:trus_app/features/main/statistics_sheet_navigation_manager.dart';
import 'package:trus_app/features/main/upper_sheet_navigation_manager.dart';
import 'package:trus_app/features/main/widget/appbar/player_stats_app_bar_text.dart';
import 'package:trus_app/features/statistics/screens/beer/beer_match_statistic_screen.dart';
import 'package:trus_app/features/statistics/screens/beer/beer_player_statistic_screen.dart';
import 'package:trus_app/features/statistics/screens/fine/fine_match_statistic_screen.dart';
import 'package:trus_app/features/statistics/screens/fine/fine_player_statistic_screen.dart';
import 'package:trus_app/features/statistics/screens/goal/goal_match_statistic_screen.dart';
import 'package:trus_app/features/statistics/screens/goal/goal_player_statistic_screen.dart';

import '../../common/utils/utils.dart';
import '../../common/widgets/confirmation_dialog.dart';
import '../../common/widgets/loader.dart';
import '../../models/api/player/player_api_model.dart';
import '../auth/controller/auth_controller.dart';
import '../beer/screens/beer_simple_screen.dart';
import '../fine/match/screens/fine_match_screen.dart';
import '../general/app_bar_title.dart';
import '../general/error/api_executor.dart';
import '../home/screens/home_screen.dart';
import '../notification/screen/notification_screen.dart';
import 'bottom_sheet_navigation_manager.dart';
import 'controller/back_handler.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  static const routeName = '/main-screen';

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  String _selectedBottomSheetScreenId = HomeScreen.id;
  PageController pageController = PageController();
  final List<String> fragmentList = [];
  bool backButtonVisibility = false;
  bool backButtonTapped = false;
  String _currentScreenId = HomeScreen.id;
  int? pageIndexWhenPlusButtonTapped;
  late BottomSheetNavigationManager _bottomSheetNavigationManager;
  late UpperSheetNavigationManager _upperSheetNavigationManager;
  late StatisticsSheetNavigationManager _statisticsSheetNavigationManager;
  bool changedMatch = false;

  @override
  void initState() {
    super.initState();
    _bottomSheetNavigationManager = BottomSheetNavigationManager(
        context, ref.read(globalVariablesControllerProvider).appTeam);
    _upperSheetNavigationManager = UpperSheetNavigationManager(
        context, ref.read(globalVariablesControllerProvider).appTeam);
    _statisticsSheetNavigationManager = StatisticsSheetNavigationManager(
        context, ref.read(globalVariablesControllerProvider).appTeam);
  }

  /// Odhlásí uživatele a přepne na Login obrazovku
  Future<void> signOut() async {
    bool? result = await executeApi<bool?>(() async {
      return await ref.read(authControllerProvider).signOut();
    }, () => showBottomSheetNavigation(), context, true);
    if (result != null && result) {
      Navigator.pushNamedAndRemoveUntil(
          context, LoginScreen.routeName, (route) => false);
      showSnackBarWithPostFrame(
          context: context, content: "Děkujeme, přijďte zas");
    }
  }

  String getUserName() {
    String? name = ref.read(authControllerProvider).getCurrentUserName();
    if (name == null) {
      return "Uživatel neznámý trouba";
    }
    return "píč $name";
  }

  PlayerApiModel? getPlayerSelectedInUserProfile() {
    return ref.read(globalVariablesControllerProvider).playerApiModel;
  }

  void setPlayerInScreenVariables(PlayerApiModel player) {
    return ref.read(screenControllerProvider).setPlayer(player);
  }

  Future<void> showDeleteConfirmationDialog() async {
    var dialog = ConfirmationDialog(
      "Opravdu chcete smazat tento účet?",
      () async {
        await executeApi<void>(() async {
          return await ref.read(authControllerProvider).deleteAccount();
        }, () {}, context, true)
            .then((value) => signOut());
      },
    );
    showDialog(
      context: context,
      builder: (BuildContext context) => dialog,
    );
  }

  /// Zobrazí postraní menu
  void showBottomSheetNavigation() {
    _bottomSheetNavigationManager.showBottomSheetNavigation(
        (id) => onModalBottomSheetMenuTapped(id), getUserName(), () {
      signOut();
    });
  }

  /// Zobrazí postraní menu
  void showUpperSheetNavigation() {
    _upperSheetNavigationManager.showBottomSheetNavigation(
        (id) => onModalBottomSheetMenuTapped(id),
        getUserName(),
        getPlayerSelectedInUserProfile(), () {
      signOut();
    }, (player) => setPlayerInScreenVariables(player));
  }

  void showStatisticsSheetNavigation() {
    _statisticsSheetNavigationManager.showBottomSheetNavigation(
            (id) => onModalBottomSheetMenuTapped(id));
  }

  /// Funkce zmanaguje zpětné tlačítko, změní barvu dolního menu a přepne fragment
  void changeFragment(Widget widget) {
    int index = ref.read(screenControllerProvider).widgetList.indexOf(widget);
    String screenId = (widget as ScreenName).screenName();
    if (!backButtonTapped) {
      manageBackButton(screenId);
    }
    backButtonTapped = false;
    changeBottomSheetColor(screenId);
    pageController.jumpToPage(index);
  }

  int getSelectedBottomSheetIndex() {
    if (_selectedBottomSheetScreenId == HomeScreen.id) {
      return 0;
    } else if (_selectedBottomSheetScreenId == FineMatchScreen.id) {
      return 1;
    } else if (_getStatisticScreens().contains(_selectedBottomSheetScreenId)) {
      return 3;
    } else {
      return 2;
    }
  }

  List<String> _getStatisticScreens() {
    List<String> screenIds = [];
    screenIds.add(BeerMatchStatisticScreen.id);
    screenIds.add(BeerPlayerStatisticScreen.id);
    screenIds.add(FinePlayerStatisticScreen.id);
    screenIds.add(FineMatchStatisticScreen.id);
    screenIds.add(GoalMatchStatisticScreen.id);
    screenIds.add(GoalPlayerStatisticScreen.id);
    return screenIds;
  }

  /// Zapíše do globální proměnné _selectedBottomSheetScreenId současné id aktivní obrazovku pokud je v bottomsheetu. Pokud není, zapíše NOT_IN_BOTTOM_SHEET
  void changeBottomSheetColor(String screenId) {
    if (screenId == HomeScreen.id ||
        screenId == FineMatchScreen.id ||
        _getStatisticScreens().contains(screenId)) {
      _selectedBottomSheetScreenId = screenId;
    } else {
      _selectedBottomSheetScreenId = "NOT_IN_BOTTOM_SHEET";
    }
  }

  ///Přidá fragment do fronty fragmentů fragmentList, pokud je seznam prázdný, skryje zpětné tlačítko
  void manageBackButton(String screenId) {
    fragmentList.add(screenId);
    _currentScreenId = screenId;
    if (screenId == HomeScreen.id) {
      fragmentList.clear();
    }
    if (fragmentList.isEmpty && backButtonVisibility) {
      backButtonVisibility = false;
    } else if (fragmentList.isNotEmpty && !backButtonVisibility) {
      backButtonVisibility = true;
    }
  }

  /// obstará logiku po kliku na zpětné tlačítko. Vybere poslední fragment z fronty a přesměruje aktivní obrazovku na něj. Pokud je seznam prázdný, vrátí domovskou obrazovku
  void onBackButtonTap() {
    if (_currentScreenId == GoalScreen.id) {
      // GoalScreen
      String id = fragmentList.removeLast();
      ref.read(screenControllerProvider).changeFragment(HomeScreen.id);
    } else {
      backButtonTapped = true;
      if (fragmentList.isNotEmpty) {
        fragmentList.removeLast();
      }
      if (fragmentList.isNotEmpty) {
        String id = fragmentList.removeLast();
        manageBackButton(id);
        changeBottomSheetColor(id);
        ref.read(screenControllerProvider).changeFragment(id);
      } else {
        manageBackButton(HomeScreen.id);
        changeBottomSheetColor(HomeScreen.id);
        ref.read(screenControllerProvider).changeFragment(HomeScreen.id);
      }
    }
  }

  ///pro bottomsheet, převádí index na screenId a aktivuje fragment
  void onTapped(int index) {
    switch (index) {
      case 0:
        ref.read(screenControllerProvider).changeFragment(HomeScreen.id);
        break;
      case 1:
        ref.read(screenControllerProvider).changeFragment(FineMatchScreen.id);
        break;
      case 2:
        break;
      case 3:
        showStatisticsSheetNavigation();
        /*ref
            .read(screenControllerProvider)
            .changeFragment(MainStatisticsScreen.id);*/
        break;
      case 4:
        showBottomSheetNavigation();
        break;
      default:
        ref.read(screenControllerProvider).changeFragment(HomeScreen.id);
    }
  }

  void onModalBottomSheetMenuTapped(String id) {
    if (id == BottomSheetNavigationManager.deleteAccount) {
      Navigator.of(context).pop();
      showDeleteConfirmationDialog();
    } else {
      Navigator.of(context).pop();
      ref.read(screenControllerProvider).changeFragment(id);
    }
  }

  Future<bool> _onWillPop() async {
    final handler = ref.read(backHandlerProvider);

    if (handler != null && handler.onBack()) {
      return false; // back spotřebován
    }

    onBackButtonTap(); // tvé fragmentové chování
    return false;
  }

  bool isChangedMatch() {
    if (changedMatch) {
      changedMatch = false;
      return true;
    }
    return false;
  }

  String getTitle(Widget widget) {
    if (widget is AppBarTitle) {
      AppBarTitle appBarTitle = widget as AppBarTitle;
      return appBarTitle.appBarTitle();
    }
    return "Trus |";
  }

  @override
  Widget build(BuildContext context) {
    var controller = ref.watch(mainControllerProvider);
    return FutureBuilder<void>(
        future: controller
            .setupPlayerStats(getPlayerSelectedInUserProfile()?.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          return FutureBuilder<void>(
              future: controller.viewPlayerStats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loader();
                }
                return WillPopScope(
                  onWillPop: _onWillPop,
                  child: StreamBuilder<Widget>(
                      stream: ref.watch(screenControllerProvider).screen(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState !=
                                ConnectionState.waiting &&
                            !snapshot.hasError) {
                          changeFragment(snapshot.data!);
                        }
                        return Scaffold(
                          resizeToAvoidBottomInset: false,
                          //pak nelítá prostřední tlačítko z dolního menu nahoru
                          appBar: AppBar(
                            leading: backButtonVisibility
                                ? BackButton(
                                    color: Colors.white,
                              onPressed: () {
                                final handler = ref.read(backHandlerProvider);
                                if (handler != null && handler.onBack()) {
                                  return;
                                }
                                onBackButtonTap();
                              },
                                    //onPressed: () => onBackButtonTap(),
                                  )
                                : null,
                            title: !ref.watch(screenControllerProvider).isScreenFocused(HomeScreen.id)? FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                getTitle(
                                  ref.read(screenControllerProvider)
                                      .getFragmentByFragmentId(_currentScreenId),
                                ),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ) :PlayerStatsAppBarText(
                              playerStatsMixin: controller,
                              hashKey: controller.playerStatsKey,
                            ),
                            /*title: PlayerStatsAppBarText(
                              playerStatsMixin: controller,
                              hashKey: controller.playerStatsKey,
                            ),*/

                            actions: [
                              IconButton(
                                  key: const ValueKey('account_button'),
                                  color: Colors.white,
                                  onPressed: () => showUpperSheetNavigation(),
                                  icon: const Icon(Icons.manage_accounts)),
                              IconButton(
                                  key: const ValueKey('notifications_button'),
                                  onPressed: () => ref
                                      .read(screenControllerProvider)
                                      .changeFragment(NotificationScreen.id),
                                  icon: const Icon(Icons.notifications)),
                            ],
                          ),
                          body: PageView(
                              controller: pageController,
                              physics: const NeverScrollableScrollPhysics(),
                              children: ref
                                  .read(screenControllerProvider)
                                  .widgetList),
                          floatingActionButton: FloatingActionButton(
                            onPressed: () => ref
                                .read(screenControllerProvider)
                                .changeFragment(BeerSimpleScreen.id),
                            elevation: 4.0,
                            backgroundColor: Colors.orange,
                            key: const ValueKey('beer_button'),
                            child: const Icon(
                              Icons.sports_bar_outlined,
                              color: Colors.black87,
                            ),
                          ),
                          floatingActionButtonLocation:
                              FloatingActionButtonLocation.centerDocked,
                          bottomNavigationBar: BottomNavigationBar(
                            showUnselectedLabels: true,
                            type: BottomNavigationBarType.shifting,
                            items: [
                              const BottomNavigationBarItem(
                                  icon: Icon(Icons.home,
                                      key: ValueKey('home_button')),
                                  label: "Přehled"),
                              const BottomNavigationBarItem(
                                  icon: Icon(Icons.savings,
                                      key: ValueKey('fine_button')),
                                  label: "Pokuty"),
                              BottomNavigationBarItem(
                                  label: "", icon: Container()),
                              const BottomNavigationBarItem(
                                  icon: Icon(Icons.equalizer,
                                      key: ValueKey('stats_button')),
                                  label: "Statistiky"),
                              const BottomNavigationBarItem(
                                  icon: Icon(Icons.menu,
                                      key: ValueKey('menu_button')),
                                  label: "Menu"),
                            ],
                            currentIndex: getSelectedBottomSheetIndex(),
                            selectedItemColor: selectedItemColor,
                            unselectedItemColor: unselectedItemColor,
                            onTap: onTapped,
                          ),
                        );
                      }),
                );
              });
        });
  }
}

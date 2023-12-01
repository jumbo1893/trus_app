import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/features/auth/screens/login_screen.dart';
import 'package:trus_app/features/fine/match/screens/fine_match_screen.dart';
import 'package:trus_app/features/fine/match/screens/fine_player_screen.dart';
import 'package:trus_app/features/fine/screens/fine_screen.dart';
import 'package:trus_app/features/goal/screen/goal_screen.dart';
import 'package:trus_app/features/match/screens/add_match_screen.dart';
import 'package:trus_app/features/match/screens/edit_match_screen.dart';
import 'package:trus_app/features/match/screens/match_screen.dart';
import 'package:trus_app/features/pkfl/screens/main_pkfl_statistics_screen.dart';
import 'package:trus_app/features/player/screens/add_player_screen.dart';
import 'package:trus_app/features/player/screens/edit_player_screen.dart';
import 'package:trus_app/features/player/screens/player_screen.dart';
import 'package:trus_app/features/season/screens/edit_season_screen.dart';
import 'package:trus_app/features/season/screens/season_screen.dart';
import 'package:trus_app/models/api/fine_api_model.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import '../../common/utils/utils.dart';
import '../../common/widgets/confirmation_dialog.dart';
import '../../models/api/pkfl/pkfl_match_api_model.dart';
import '../../models/api/player_api_model.dart';
import '../../models/api/season_api_model.dart';
import '../../models/enum/match_detail_options.dart';
import '../auth/controller/auth_controller.dart';
import '../auth/screens/user_screen.dart';
import '../beer/screens/beer_simple_screen.dart';
import '../fine/match/screens/multiple_fine_players_screen.dart';
import '../fine/screens/add_fine_screen.dart';
import '../fine/screens/edit_fine_screen.dart';
import '../general/error/api_executor.dart';
import '../home/screens/home_screen.dart';
import '../info/screens/info_screen.dart';
import '../notification/screen/notification_screen.dart';
import '../pkfl/screens/match_detail_screen.dart';
import '../pkfl/screens/pkfl_table_screens.dart';
import '../pkfl/screens/pkfl_fixtures_screen.dart';
import '../season/screens/add_season_screen.dart';
import '../statistics/screens/goal/main_goal_statistics_screen.dart';
import '../statistics/screens/main_statistics_screen.dart';
import 'bottom_sheet_navigation_manager.dart';
import 'appbar_title_manager.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  static const routeName = '/main-screen';

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedBottomSheetIndex = 0;
  PageController pageController = PageController();
  final List<int> fragmentList = [];
  bool backButtonVisibility = false;
  int _currentIndex = 0;
  int? pageIndexWhenPlusButtonTapped;
  late BottomSheetNavigationManager _bottomSheetNavigationManager;
  late AppBarTitleManager _appBarTitleManager;
  bool changedMatch = false;

  @override
  void initState() {
    super.initState();
    _bottomSheetNavigationManager = BottomSheetNavigationManager(context);
    _appBarTitleManager = AppBarTitleManager();
  }

  //dummy modely , které se předávají na další obrazovky
  PlayerApiModel playerModel = PlayerApiModel(
    name: "name",
    id: 0,
    birthday: DateTime.now(),
    fan: false,
    active: true,
  );

  SeasonApiModel seasonModel = SeasonApiModel.dummy();

  MatchApiModel matchModel = MatchApiModel.dummy();

  int? matchId;

  FineApiModel fineModel = FineApiModel.dummy();

  PkflMatchApiModel? pkflMatch;

  List<int> playerIdListModel = [];

  MatchDetailOptions preferredScreen = MatchDetailOptions.editMatch;

  void onPickedPlayerChange(PlayerApiModel newPlayerModel) {
    setState(() => playerModel = newPlayerModel);
    changeFragment(5);
  }

  void onPickedSeasonChange(SeasonApiModel newSeasonModel) {
    setState(() => seasonModel = newSeasonModel);
    changeFragment(8);
  }

  void onPickedMatchChange(MatchApiModel newMatchModel) {
    setState(() => {
      matchModel = newMatchModel,
      matchId = newMatchModel.id,
      preferredScreen = MatchDetailOptions.editMatch,
      pkflMatch = null
    });
    setState(() => matchModel = newMatchModel);
    preferredScreen = MatchDetailOptions.editMatch;
    changeFragment(27);
  }

  void onPickedPkflMatchChange(PkflMatchApiModel newPkflMatchApiModel,
      MatchDetailOptions preferredScreen) {
    setState(() => {
          pkflMatch = newPkflMatchApiModel,
      matchId = null,
          this.preferredScreen = preferredScreen
        });
    changeFragment(27);
  }

  void onPickedFineChange(FineApiModel newFineModel) {
    setState(() => fineModel = newFineModel);
    changeFragment(14);
  }

  void onPickedPlayerFinesChange(PlayerApiModel newPlayerModel) {
    setState(() => playerModel = newPlayerModel);
    changeFragment(15);
  }

  void onPickedPlayersFinesChange(List<int> newPlayerList) {
    setState(() => playerIdListModel = newPlayerList);
    changeFragment(16);
  }

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

  void showBottomSheetNavigation() {
    _bottomSheetNavigationManager.showBottomSheetNavigation(
        (index) => onModalBottomSheetMenuTapped(index), getUserName(), () {
      signOut();
    });
  }

  void changeFragmentAfterAddMatch(int index) {
    if (pageIndexWhenPlusButtonTapped != null) {
      changeFragment(pageIndexWhenPlusButtonTapped!);
      pageIndexWhenPlusButtonTapped = null;
    } else {
      changeFragment(index);
    }
  }

  void changeFragmentForAddMatchFromAddButton(PkflMatchApiModel? match) {
    pageIndexWhenPlusButtonTapped = _currentIndex;
    changeFragmentForAddMatch(match);
  }

  void changeFragmentForAddMatch(PkflMatchApiModel? match) {
    pkflMatch = match;
    changeFragment(10);
  }

  void changeFragment(int index) {
    manageBackButton(index, false);
    setAppBarTitle(index);
    changeBottomSheetColor(index);
    pageController.jumpToPage(index);
  }

  void changeFragmentAndDeletePage(int index) {
    manageBackButton(index, true);
    setAppBarTitle(index);
    changeBottomSheetColor(index);
    pageController.jumpToPage(index);
  }

  void changeBottomSheetColor(int index) {
    setState(() {
      if (index == 0 || index == 1 || index == 3) {
        _selectedBottomSheetIndex = index;
      } else if (index == 4) {
      } else {
        _selectedBottomSheetIndex = 2;
      }
    });
  }

  void manageBackButton(int index, bool tappedBackButton) {
    if (!tappedBackButton) {
      fragmentList.add(_currentIndex);
    }
    _currentIndex = index;
    if (index == 0) {
      fragmentList.clear();
    }
    if (fragmentList.isEmpty && backButtonVisibility) {
      setState(() {
        backButtonVisibility = false;
      });
    } else if (fragmentList.isNotEmpty && !backButtonVisibility) {
      setState(() {
        backButtonVisibility = true;
      });
    }
  }

  void onBackButtonTap() {
    if (_currentIndex == 25) {
      // GoalScreen
      onPickedMatchChange(matchModel);
    } else {
      if (fragmentList.isNotEmpty) {
        int index = fragmentList.removeLast();
        manageBackButton(index, true);
        setAppBarTitle(index);
        changeBottomSheetColor(index);
        pageController.jumpToPage(index);
      } else {
        manageBackButton(0, true);
        setAppBarTitle(0);
        changeBottomSheetColor(0);
        pageController.jumpToPage(0);
      }
    }
  }

  void setAppBarTitle(int index) {
    setState(() {
      _appBarTitleManager.setAppBarTitle(index);
    });
  }

  void onTapped(int index) {
    if (index == 4) {
      showBottomSheetNavigation();
      return;
    }
    changeFragment(index);
  }

  void onModalBottomSheetMenuTapped(int index) {
    if (index == -1) {
      //delete account
      Navigator.of(context).pop();
      showDeleteConfirmationDialog();
    } else {
      Navigator.of(context).pop();
      changeFragment(index);
    }
  }

  Future<bool> _onWillPop() async {
    onBackButtonTap();
    return false;
  }

  bool isFocused(pageIndex) {
    return pageIndex == _currentIndex;
  }

  bool isChangedMatch() {
    if (changedMatch) {
      changedMatch = false;
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        //pak nelítá prostřední tlačítko z dolního menu nahoru
        appBar: AppBar(
          leading: backButtonVisibility
              ? BackButton(
                  color: Colors.white,
                  onPressed: () => onBackButtonTap(),
                )
              : null,
          title: Text(_appBarTitleManager.appBarTitle),
          actions: [
            IconButton(
                key: const ValueKey('plus_button'),
                onPressed: () => changeFragmentForAddMatchFromAddButton(null),
                icon: const Icon(Icons.add)),
            IconButton(
                key: const ValueKey('notifications_button'),
                onPressed: () => changeFragment(23),
                icon: const Icon(Icons.notifications)),
          ],
        ),
        body: PageView(
          controller: pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            HomeScreen(
              //0
              addPkflMatch: (pkflMatch) => changeFragmentForAddMatch(pkflMatch),
              addGoals: (int matchId) =>
                  {matchModel.id = matchId, changeFragment(25)},
              addFines: (int matchId) =>
                  {matchModel.id = matchId, changeFragment(1)},
              addBeers: (int matchId) =>
                  {matchModel.id = matchId, changeFragment(17)},
              editMatch: (int matchId) =>
                  {matchModel.id = matchId, onPickedMatchChange(matchModel)},
              changedMatch: isChangedMatch(),
              commonMatches: (pkflMatch) => onPickedPkflMatchChange(pkflMatch, MatchDetailOptions.commonMatches),
            ),
            FineMatchScreen(
              //1
              matchId: matchModel.id!,
              playerIdListToChangeFines: (players) =>
                  onPickedPlayersFinesChange(players),
              setMatch: (newMatch) => matchModel = newMatch,
              setPlayer: (player) => onPickedPlayerFinesChange(player),
              isFocused: isFocused(1),
              backToMainMenu: () => changeFragment(0),
            ),
            Container(
              //2
              color: Colors.yellow,
            ),
            MainStatisticsScreen(
              //3
              backToMainMenu: () => changeFragment(0),
            ),
            AddPlayerScreen(
              //4
              onAddPlayerPressed: () => changeFragment(0),
              isFocused: isFocused(4),
              backToMainMenu: () => changeFragment(0),
            ),
            EditPlayerScreen(
              //5
              playerModel,
              onButtonConfirmPressed: () => changeFragment(0),
              isFocused: isFocused(5),
              backToMainMenu: () => changeFragment(0),
            ),
            SeasonScreen(
              //6
              onPlusButtonPressed: () => changeFragment(7),
              backToMainMenu: () => changeFragment(0),
              setSeason: (season) => onPickedSeasonChange(season),
              isFocused: isFocused(6),
            ),
            AddSeasonScreen(
              //7
              onAddSeasonPressed: () => changeFragment(6),
              isFocused: isFocused(7),
              backToMainMenu: () => changeFragment(0),
            ),
            EditSeasonScreen(
              //8
              seasonModel,
              onButtonConfirmPressed: () => changeFragment(6),
              isFocused: isFocused(8),
              backToMainMenu: () => changeFragment(0),
            ),
            MatchScreen(
              //9
              onPlusButtonPressed: () => changeFragmentForAddMatch(null),
              setMatch: (match) => onPickedMatchChange(match),
              backToMainMenu: () => changeFragment(0),
              isFocused: isFocused(9),
            ),
            AddMatchScreen(
              //10
              onAddMatchPressed: () =>
                  {changeFragmentAndDeletePage(0), changedMatch = true},
              isFocused: isFocused(10),
              setMatchId: (int id) {
                matchModel.id = id;
              },
              onChangePlayerGoalsPressed: () => changeFragment(25),
              backToMainMenu: () => changeFragment(0),
              pkflMatch: pkflMatch,
            ),
            EditMatchScreen(
              //11
              onButtonConfirmPressed: () =>
                  {changeFragmentAndDeletePage(0), changedMatch = true},
              isFocused: isFocused(11),
              setMatchId: (int id) {
                matchModel.id = id;
              },
              onChangePlayerGoalsPressed: () => changeFragment(25),
              backToMainMenu: () => changeFragment(0),
            ),
            FineScreen(
              //12
              onPlusButtonPressed: () => changeFragment(13),
              backToMainMenu: () => changeFragment(0),
              setFine: (fine) => onPickedFineChange(fine),
              isFocused: isFocused(12),
            ),
            AddFineScreen(
              //13
              onAddFinePressed: () => changeFragment(12),
              isFocused: isFocused(13),
              backToMainMenu: () => changeFragment(0),
            ),
            EditFineScreen(
              //14
              fineModel,
              onButtonConfirmPressed: () => changeFragment(12),
              isFocused: isFocused(14),
              backToMainMenu: () => changeFragment(0),
            ),
            FinePlayerScreen(
              //15
              matchModel: matchModel,
              playerModel: playerModel,
              onButtonConfirmPressed: () => changeFragment(1),
              isFocused: isFocused(15),
              backToMainMenu: () => changeFragment(0),
            ),
            MultipleFinePlayersScreen(
              //16
              matchModel: matchModel,
              playerIdList: playerIdListModel,
              onButtonConfirmPressed: () => changeFragment(1),
              isFocused: isFocused(16),
              backToMainMenu: () => changeFragment(0),
            ),
            BeerSimpleScreen(
              //17
              matchId: matchModel.id!,
              setMatch: (newMatch) => matchModel = newMatch,
              onButtonConfirmPressed: () => changeFragment(0),
              backToMainMenu: () => changeFragment(0),
              isFocused: isFocused(17),
            ),
            PlayerScreen(
              //18
              onPlusButtonPressed: () => changeFragment(4),
              backToMainMenu: () => changeFragment(0),
              setPlayer: (player) => onPickedPlayerChange(player),
              isFocused: isFocused(18),
            ),
            PkflFixturesScreen(
              //19
              setPkflMach: (match) => onPickedPkflMatchChange(match, MatchDetailOptions.pkflDetail),
              backToMainMenu: () => changeFragment(0),
              isFocused: isFocused(19),
            ),
            MainPkflStatisticsScreen(
              backToMainMenu: () => changeFragment(0),
              isFocused: isFocused(20),
              //20
            ),
            const PkflTableScreen(
                //21
                ),
            MainGoalStatisticsScreen(
              //22
              backToMainMenu: () => changeFragment(0),
            ),
            NotificationScreen(
              //23
              backToMainMenu: () => changeFragment(0),
              isFocused: isFocused(23),
            ),
            UserScreen(
              //24
              isFocused: isFocused(24),
              backToMainMenu: () => changeFragment(0),
            ),
            GoalScreen(
              //25
              onAddGoalsPressed: () => changeFragment(0),
              isFocused: isFocused(25),
              matchId: matchModel.id!,
              backToMainMenu: () => changeFragment(0),
            ),
            const InfoScreen(
                //26
                ),
            MatchDetailScreen(
              //27
              backToMainMenu: () => changeFragment(0),
              pkflMatchId: pkflMatch?.id,
              matchId: matchId,
              preferredScreen: preferredScreen, isFocused: isFocused(27),
              onButtonConfirmPressed: () =>
              {changeFragmentAndDeletePage(0), changedMatch = true},
              setMatchId: (int id) {
                matchModel.id = id;
              },
              onChangePlayerGoalsPressed: () => changeFragment(25),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => changeFragment(17),
          elevation: 4.0,
          backgroundColor: Colors.orange,
          key: const ValueKey('beer_button'),
          child: const Icon(
            Icons.sports_bar_outlined,
            color: Colors.black87,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomNavigationBar(
          showUnselectedLabels: true,
          type: BottomNavigationBarType.shifting,
          items: [
            const BottomNavigationBarItem(
                icon: Icon(Icons.home, key: ValueKey('home_button')),
                label: "Přehled"),
            const BottomNavigationBarItem(
                icon: Icon(Icons.savings, key: ValueKey('fine_button')),
                label: "Pokuty"),
            BottomNavigationBarItem(label: "", icon: Container()),
            const BottomNavigationBarItem(
                icon: Icon(Icons.equalizer, key: ValueKey('stats_button')),
                label: "Statistiky"),
            const BottomNavigationBarItem(
                icon: Icon(Icons.menu, key: ValueKey('menu_button')),
                label: "Menu"),
          ],
          currentIndex: _selectedBottomSheetIndex,
          selectedItemColor: selectedItemColor,
          unselectedItemColor: unselectedItemColor,
          onTap: onTapped,
        ),
      ),
    );
  }
}

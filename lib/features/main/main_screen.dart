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
import 'package:trus_app/features/pkfl/screens/pkfl_match_screens.dart';
import 'package:trus_app/features/player/screens/add_player_screen.dart';
import 'package:trus_app/features/player/screens/edit_player_screen.dart';
import 'package:trus_app/features/player/screens/player_screen.dart';
import 'package:trus_app/features/season/screens/edit_season_screen.dart';
import 'package:trus_app/features/season/screens/season_screen.dart';
import 'package:trus_app/models/api/fine_api_model.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/match_model.dart';
import 'package:trus_app/models/player_model.dart';
import '../../common/utils/utils.dart';
import '../../models/api/player_api_model.dart';
import '../../models/api/season_api_model.dart';
import '../auth/controller/auth_controller.dart';
import '../auth/screens/user_screen.dart';
import '../beer/screens/beer_simple_screen.dart';
import '../fine/match/screens/multiple_fine_players_screen.dart';
import '../fine/screens/add_fine_screen.dart';
import '../fine/screens/edit_fine_screen.dart';
import '../general/error/api_executor.dart';
import '../home/screens/home_screen.dart';
import '../notification/screen/notification_screen.dart';
import '../pkfl/screens/pkfl_table_screens.dart';
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
  late BottomSheetNavigationManager _bottomSheetNavigationManager;
  late AppBarTitleManager _appBarTitleManager;

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
      active: true,);

  SeasonApiModel seasonModel = SeasonApiModel.dummy();

  MatchApiModel matchModel = MatchApiModel.dummy();

  FineApiModel fineModel = FineApiModel.dummy();

  MatchModel mainMatch = MatchModel.dummyMainMatch();

  List<int> playerIdListModel = [];

  void onPickedPlayerChange(PlayerApiModel newPlayerModel) {
    setState(() => playerModel = newPlayerModel);
    changeFragment(5);
  }

  void onPickedSeasonChange(SeasonApiModel newSeasonModel) {
    setState(() => seasonModel = newSeasonModel);
    changeFragment(8);
  }

  void onPickedMatchChange(MatchApiModel newMatchModel) {
    setState(() => matchModel = newMatchModel);
    changeFragment(11);
  }

  void onPickedMainMatch(MatchModel newMatchModel) {
    mainMatch = newMatchModel;
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

  /*void signOut() {
    ref.read(authControllerProvider).signOut(context);
    Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (route) => false);
  }*/
  Future<void> signOut() async {
    bool? result = await executeApi<bool?>(() async {
      return await ref.read(authControllerProvider).signOut();
    },() => showBottomSheetNavigation(), context, true);
    if (result != null && result) {
      Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (route) => false);
      showSnackBarWithPostFrame(context: context, content: "Děkujeme, přijďte zas");
    }
  }
  String getUserName() {
    String? name = ref.read(authControllerProvider).getCurrentUserName();
    if(name == null) {
      return "Uživatel neznámý trouba";
    }
    return "píč $name";
  }


  void showBottomSheetNavigation() {
    _bottomSheetNavigationManager.showBottomSheetNavigation((index) => onModalBottomSheetMenuTapped(index), getUserName(), () { signOut();});
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
      }
      else {
        _selectedBottomSheetIndex = 2;
      }
    });
  }

  void manageBackButton(int index, bool tappedBackButton) {
    if(!tappedBackButton) {
      fragmentList.add(_currentIndex);
    }
    _currentIndex = index;
    if(index == 0) {
      fragmentList.clear();
    }
    if(fragmentList.isEmpty && backButtonVisibility) {
      setState(() {
        backButtonVisibility = false;
        });
    }
    else if(fragmentList.isNotEmpty && !backButtonVisibility) {
      setState(() {
        backButtonVisibility = true;
      });
    }
  }

  void onBackButtonTap() {
    if(fragmentList.isNotEmpty) {
      int index = fragmentList.removeLast();
      manageBackButton(index, true);
      setAppBarTitle(index);
      changeBottomSheetColor(index);
      pageController.jumpToPage(index);
    }
    else {
      manageBackButton(0, true);
      setAppBarTitle(0);
      changeBottomSheetColor(0);
      pageController.jumpToPage(0);
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
    Navigator.of(context).pop();
    changeFragment(index);
  }

  Future<bool> _onWillPop() async {
    onBackButtonTap();
    return false;
  }

  bool isFocused(pageIndex) {
    return pageIndex == _currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset:
            false, //pak nelítá prostřední tlačítko z dolního menu nahoru
        appBar: AppBar(
          leading: backButtonVisibility ? BackButton(color: Colors.white, onPressed: () => onBackButtonTap(),): null,
          title: Text(_appBarTitleManager.appBarTitle),
          actions: [
            IconButton(
                onPressed: () => changeFragment(10), icon: const Icon(Icons.add)),
            IconButton(onPressed: () => changeFragment(23), icon: const Icon(Icons.notifications)),
          ],
        ),
        body: PageView(
          controller: pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            const HomeScreen(
                //0
                ),
            FineMatchScreen(
              //1
              mainMatch: matchModel,
              playerIdListToChangeFines: (players) =>
                  onPickedPlayersFinesChange(players),
              setMatch: (newMatch) => matchModel = newMatch,
              setPlayer: (player) => onPickedPlayerFinesChange(player),
              isFocused: isFocused(1),
            ),
            Container(
              //2
              color: Colors.yellow,
            ),
            const MainStatisticsScreen(
                //3
                ),
            AddPlayerScreen(
              //4
              onAddPlayerPressed: () => changeFragment(0),
              isFocused: isFocused(4),
            ),
            EditPlayerScreen(
              //5
              playerModel,
              onButtonConfirmPressed: () => changeFragment(0),
              isFocused: isFocused(5),
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
            ),
            EditSeasonScreen(
              //8
              seasonModel,
              onButtonConfirmPressed: () => changeFragment(6),
              isFocused: isFocused(8),
            ),
            MatchScreen(
              //9
              onPlusButtonPressed: () => changeFragment(10),
              setMatch: (match) => onPickedMatchChange(match),
              backToMainMenu: () => changeFragment(0),
              isFocused: isFocused(9),
            ),
            AddMatchScreen(
              //10
              onAddMatchPressed: () => changeFragment(9),
              isFocused: isFocused(10),
              setMatchId: (int id) {matchModel.id = id;},
              onChangePlayerGoalsPressed: () => changeFragment(25),
            ),
            EditMatchScreen(
              //11
              matchModel: matchModel,
              onButtonConfirmPressed: () => changeFragmentAndDeletePage(9),
              isFocused: isFocused(11),
              setMatchId: (int id) {matchModel.id = id;},
              onChangePlayerGoalsPressed: () => changeFragment(25),
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
            ),
            EditFineScreen(
              //14
              fineModel,
              onButtonConfirmPressed: () => changeFragment(12),
              isFocused: isFocused(14),
            ),
            FinePlayerScreen(
              //15
              matchModel: matchModel,
              playerModel: playerModel,
              onButtonConfirmPressed: () => changeFragment(1),
              isFocused: isFocused(15),
            ),
            MultipleFinePlayersScreen(
              //16
              matchModel: matchModel,
              playerIdList: playerIdListModel,
              onButtonConfirmPressed: () => changeFragment(1),
              isFocused: isFocused(16),
            ),
            BeerSimpleScreen(
              //17
              mainMatch: matchModel,
              setMatch: (newMatch) => matchModel = newMatch,
              onButtonConfirmPressed: () => changeFragment(0),
              isFocused: isFocused(17),
            ),
            PlayerScreen(
              //18
              onPlusButtonPressed: () => changeFragment(4),
              backToMainMenu: () => changeFragment(0),
              setPlayer: (player) => onPickedPlayerChange(player),
              isFocused: isFocused(18),
            ),
            const PkflMatchScreen(
                //19
                ),
            const MainPkflStatisticsScreen(
                //20
                ),
            const PkflTableScreen(
                //21
                ),
            const MainGoalStatisticsScreen(
                //22
                ),
            const NotificationScreen(
              //23
            ),
            UserScreen(
              //24
              isFocused: isFocused(24),
              backToMainMenu: () => changeFragment(0),
            ),
            GoalScreen(
              //25
              onAddGoalsPressed: () => changeFragment(4),
              isFocused: isFocused(25),
              matchId: matchModel.id!,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => changeFragment(17),
          elevation: 4.0,
          backgroundColor: Colors.orange,
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
                icon: Icon(Icons.home), label: "Přehled"),
            const BottomNavigationBarItem(
                icon: Icon(Icons.savings), label: "Pokuty"),
            BottomNavigationBarItem(label: "", icon: Container()),
            const BottomNavigationBarItem(
                icon: Icon(Icons.equalizer), label: "Statistiky"),
            const BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Menu"),
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

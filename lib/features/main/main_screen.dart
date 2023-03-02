import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/features/auth/screens/login_screen.dart';
import 'package:trus_app/features/fine/match/screens/fine_match_screen.dart';
import 'package:trus_app/features/fine/match/screens/fine_player_screen.dart';
import 'package:trus_app/features/fine/screens/fine_screen.dart';
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
import 'package:trus_app/models/match_model.dart';
import 'package:trus_app/models/player_model.dart';
import 'package:trus_app/models/season_model.dart';
import '../../models/fine_model.dart';
import '../auth/controller/auth_controller.dart';
import '../beer/screens/beer_simple_screen.dart';
import '../fine/match/screens/multiple_fine_players_screen.dart';
import '../fine/screens/add_fine_screen.dart';
import '../fine/screens/edit_fine_screen.dart';
import '../home/screens/home_screen.dart';
import '../pkfl/screens/pkfl_table_screens.dart';
import '../season/screens/add_season_screen.dart';
import '../statistics/playerstats/screens/player_stats_stats_screen.dart';
import '../statistics/screens/main_statistics_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  static const routeName = '/main-screen';

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;
  PageController pageController = PageController();
  String appBarTitle = "Trusí appka";

  //dummy modely , které se předávají na další obrazovky
  PlayerModel playerModel = PlayerModel(
      name: "name",
      id: "id",
      birthday: DateTime.now(),
      fan: false,
      isActive: true);

  SeasonModel seasonModel = SeasonModel(
      name: "name", id: "id", fromDate: DateTime.now(), toDate: DateTime.now());

  MatchModel matchModel = MatchModel(
      name: "name",
      id: "id",
      date: DateTime.now(),
      home: true,
      playerIdList: ["id"],
      seasonId: "id");

  FineModel fineModel = FineModel(
    name: "name",
    id: "id",
    amount: 1,
  );

  MatchModel mainMatch = MatchModel.dummyMainMatch();

  List<PlayerModel> playerListModel = [];

  void onPickedPlayerChange(PlayerModel newPlayerModel) {
    setState(() => playerModel = newPlayerModel);
    changeFragment(5);
  }

  void onPickedSeasonChange(SeasonModel newSeasonModel) {
    setState(() => seasonModel = newSeasonModel);
    changeFragment(8);
  }

  void onPickedMatchChange(MatchModel newMatchModel) {
    setState(() => matchModel = newMatchModel);
    changeFragment(11);
  }

  void onPickedMainMatch(MatchModel newMatchModel) {
    mainMatch = newMatchModel;
  }

  void onPickedFineChange(FineModel newFineModel) {
    setState(() => fineModel = newFineModel);
    changeFragment(14);
  }

  void onPickedPlayerFinesChange(PlayerModel newPlayerModel) {
    setState(() => playerModel = newPlayerModel);
    changeFragment(15);
  }

  void onPickedPlayersFinesChange(List<PlayerModel> newPlayerList) {
    setState(() => playerListModel = newPlayerList);
    changeFragment(16);
  }

  void showBottomSheetNavigation() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        builder: (context) => SizedBox(
              height: MediaQuery.of(context).copyWith().size.height * (3 / 4),
              child: ListView(
                children: <Widget>[
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    onLongPress: () => Navigator.of(context).pop(),
                    child: Container(
                      color: Colors.grey,
                      height: 10,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(ref.watch(userDataAuthProvider).when(
                            data: (user) {
                              if (user == null) {
                                return "uživatel neznámý trouba";
                              }
                              return ("píč ${user.name}");
                            },
                            error: (error, trace) {
                              print(error.toString());
                              return ("chyba při načítání uživatele");
                            },
                            loading: () => "načítám")),
                        TextButton(
                          onPressed: () => Navigator.pushNamedAndRemoveUntil(
                              context, LoginScreen.routeName, (route) => false),
                          child: const Text("Odhlásit",
                              style: TextStyle(
                                color: orangeColor,
                              )),
                        )
                      ],
                    ),
                  ),
                  Container(
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                    color: Colors.black,
                  )))),
                  ListTile(
                    leading: const Icon(
                      Icons.home,
                      color: Colors.orange,
                    ),
                    title: const Text("Přehled"),
                    onTap: () => onModalBottomSheetMenuTapped(0),
                  ),
                  Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text(
                          "ZÁPASY",
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.add,
                      color: Colors.orange,
                    ),
                    title: const Text("Přidat zápas"),
                    onTap: () => onModalBottomSheetMenuTapped(10),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.list_outlined,
                      color: Colors.orange,
                    ),
                    title: const Text("Seznam zápasů"),
                    onTap: () => onModalBottomSheetMenuTapped(9),
                  ),
                  Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text(
                          "PKFL",
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.sports_soccer,
                      color: Colors.orange,
                    ),
                    title: const Text("Seznam PKFL zápasů"),
                    onTap: () => onModalBottomSheetMenuTapped(19),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.scoreboard_rounded,
                      color: Colors.orange,
                    ),
                    title: const Text("PKFL tabulka"),
                    onTap: () => onModalBottomSheetMenuTapped(21),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.equalizer,
                      color: Colors.orange,
                    ),
                    title: const Text("Statistiky z PKFL"),
                    onTap: () => onModalBottomSheetMenuTapped(20),
                  ),
                  Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text(
                          "HRÁČI",
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.person_add,
                      color: Colors.orange,
                    ),
                    title: const Text("Přidat hráče"),
                    onTap: () => onModalBottomSheetMenuTapped(4),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.group,
                      color: Colors.orange,
                    ),
                    title: const Text("Seznam hráčů"),
                    onTap: () => onModalBottomSheetMenuTapped(18),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.point_of_sale,
                      color: Colors.orange,
                    ),
                    title: const Text("Srovnání dluhů hráčů"),
                    onTap: () {},
                  ),
                  Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text(
                          "POKUTY",
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.attach_money,
                      color: Colors.orange,
                    ),
                    title: const Text("Přidat/upravit pokutu"),
                    onTap: () => onModalBottomSheetMenuTapped(12),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.savings,
                      color: Colors.orange,
                    ),
                    title: const Text("Přidat pokutu v zápase"),
                    onTap: () => onModalBottomSheetMenuTapped(1),
                  ),
                  Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text(
                          "PIVA",
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.sports_bar,
                      color: Colors.orange,
                    ),
                    title: const Text("Přidat pivo v zápase"),
                    onTap: () => onModalBottomSheetMenuTapped(17),
                  ),
                  Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text(
                          "STATISTIKY",
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.equalizer,
                      color: Colors.orange,
                    ),
                    title: const Text("Statistiky piv/pokut"),
                    onTap: () => onModalBottomSheetMenuTapped(3),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.query_stats,
                      color: Colors.orange,
                    ),
                    title: const Text("Statistiky gólů/asistencí"),
                    onTap: () => onModalBottomSheetMenuTapped(22),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.download,
                      color: Colors.orange,
                    ),
                    title: const Text("Tabulka/export statistik"),
                    onTap: () {},
                  ),
                  Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text(
                          "NASTAVENÍ",
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.info,
                      color: Colors.orange,
                    ),
                    title: const Text("Informace o appce"),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.manage_accounts,
                      color: Colors.orange,
                    ),
                    title: const Text("Nastavení uživatele"),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.edit_calendar,
                      color: Colors.orange,
                    ),
                    title: const Text("Nastavení sezon"),
                    onTap: () => onModalBottomSheetMenuTapped(6),
                  ),
                ],
              ),
            ));
  }

  void changeFragment(int index) {
    setAppBarTitle(index);
    changeBottomSheetColor(index);
    pageController.jumpToPage(index);
  }

  void changeBottomSheetColor(int index) {
    print(index);
    setState(() {
      if (index == 0 || index == 1 || index == 3) {
        _selectedIndex = index;
      } else if (index == 4) {
      }
      else {
        _selectedIndex = 2;
      }
    });
  }

  void setAppBarTitle(int index) {
    setState(() {
      switch (index) {
        case 0:
          appBarTitle = "Trusí appka";
          break;
        case 1:
          appBarTitle = "Přidání pokut";
          break;
        case 3:
          appBarTitle = "Statistiky pokut/piv";
          break;
        case 4:
          appBarTitle = "Přidat hráče";
          break;
        case 5:
          appBarTitle = "Upravit hráče";
          break;
        case 6:
          appBarTitle = "Sezony";
          break;
        case 7:
          appBarTitle = "Přidat sezonu";
          break;
        case 8:
          appBarTitle = "Upravit sezonu";
          break;
        case 9:
          appBarTitle = "Zápasy";
          break;
        case 10:
          appBarTitle = "Přidat zápas";
          break;
        case 11:
          appBarTitle = "Upravit zápas";
          break;
        case 12:
          appBarTitle = "Pokuty";
          break;
        case 13:
          appBarTitle = "Přidat pokutu";
          break;
        case 14:
          appBarTitle = "Upravit pokutu";
          break;
        case 15:
          appBarTitle = "Přidat pokutu hráči";
          break;
        case 16:
          appBarTitle = "Přidat pokutu více hráčům";
          break;
        case 17:
          appBarTitle = "Přidat pivo";
          break;
        case 18:
          appBarTitle = "Hráči";
          break;
        case 19:
          appBarTitle = "Seznam PKFL zápasů";
          break;
        case 20:
          appBarTitle = "Statistika PKFL";
          break;
        case 21:
          appBarTitle = "Tabulka PKFL";
          break;
        case 22:
          appBarTitle = "Statistika gólů/asistencí";
          break;
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, //pak nelítá prostřední tlačítko z dolního menu nahoru
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [
          IconButton(
              onPressed: () => changeFragment(10), icon: const Icon(Icons.add)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
        ],
      ),
      body: PageView(
        controller: pageController,
        children: [
          const HomeScreen(
              //0
              ),
          FineMatchScreen(
            //1
            mainMatch: mainMatch,
            playerListToChangeFines: (players) =>
                onPickedPlayersFinesChange(players),
            setMainMatch: (match) => onPickedMainMatch(match),
            setPlayer: (player) => onPickedPlayerFinesChange(player),
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
            onAddPlayerPressed: () => changeFragment(3),
          ),
          EditPlayerScreen(
            //5
            playerModel,
            onButtonConfirmPressed: () => changeFragment(3),
          ),
          SeasonScreen(
            //6
            onPlusButtonPressed: () => changeFragment(7),
            setSeason: (season) => onPickedSeasonChange(season),
          ),
          AddSeasonScreen(
            //7
            onAddSeasonPressed: () => changeFragment(6),
          ),
          EditSeasonScreen(
            //8
            seasonModel,
            onButtonConfirmPressed: () => changeFragment(6),
          ),
          MatchScreen(
            //9
            onPlusButtonPressed: () => changeFragment(10),
            setMatch: (match) => onPickedMatchChange(match),
          ),
          AddMatchScreen(
            //10
            onAddMatchPressed: () => changeFragment(9),
          ),
          EditMatchScreen(
            //11
            matchModel: matchModel,
            onButtonConfirmPressed: () => changeFragment(9),
          ),
          FineScreen(
            //12
            onPlusButtonPressed: () => changeFragment(13),
            setFine: (fine) => onPickedFineChange(fine),
          ),
          AddFineScreen(
            //13
            onAddFinePressed: () => changeFragment(12),
          ),
          EditFineScreen(
            //14
            fineModel,
            onButtonConfirmPressed: () => changeFragment(12),
          ),
          FinePlayerScreen(
            //15
            matchModel: mainMatch,
            playerModel: playerModel,
            onButtonConfirmPressed: () => changeFragment(1),
          ),
          MultipleFinePlayersScreen(
            //16
            matchId: mainMatch.id,
            players: playerListModel,
            onButtonConfirmPressed: () => changeFragment(1),
          ),
          BeerSimpleScreen(
            //17
            mainMatch: mainMatch,
            setMainMatch: (match) => onPickedMainMatch(match),
            onButtonConfirmPressed: () => changeFragment(0),
          ),
          PlayerScreen(
            //18
            onPlusButtonPressed: () => changeFragment(4),
            setPlayer: (player) => onPickedPlayerChange(player),
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
          const PlayerStatsStatsScreen(
              //22
              )
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
        currentIndex: _selectedIndex,
        selectedItemColor: selectedItemColor,
        unselectedItemColor: unselectedItemColor,
        onTap: onTapped,
      ),
    );
  }
}

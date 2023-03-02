import 'dart:async';

import 'package:trus_app/features/statistics/helper/beer_season_helper.dart';
import 'package:trus_app/features/statistics/helper/fine_season_helper.dart';
import 'package:trus_app/features/statistics/helper/fine_stats_helper.dart';
import 'package:trus_app/models/beer_model.dart';
import 'package:trus_app/models/helper/beer_stats_helper_model.dart';
import 'package:trus_app/models/helper/fine_stats_helper_model.dart';
import 'package:trus_app/models/match_model.dart';
import 'package:trus_app/models/player_model.dart';
import 'package:trus_app/models/season_model.dart';

import '../../models/enum/drink.dart';
import '../../models/enum/fine.dart';
import '../../models/enum/model.dart';
import '../../models/enum/participant.dart';
import '../../models/fine_match_model.dart';
import '../../models/fine_model.dart';
import '../../models/player_stats_model.dart';
import '../statistics/helper/beer_stats_helper.dart';

class RandomFact {
  List<PlayerModel>? players;
  List<MatchModel>? matches;
  List<SeasonModel>? seasons;
  List<FineModel>? fines;
  List<PlayerStatsModel>? playerStats;
  List<BeerModel>? beers;
  List<FineMatchModel>? finesMatches;
  SeasonModel currentSeason = SeasonModel.otherSeason();
  BeerStatsHelper? beerStatsHelper;
  FineStatsHelper? finesStatsHelper;
  List<BeerStatsHelperModel>? beersForMatches;
  List<BeerStatsHelperModel>? beersForPlayers;
  List<FineStatsHelperModel>? finesForMatches;
  List<FineStatsHelperModel>? finesForPlayers;
  final randomFactListStream = StreamController<List<String>>.broadcast();
  final randomFactStream = StreamController<String>.broadcast();

  void _setCurrentSeason() {
    if(seasons != null) {
      for(SeasonModel seasonModel in seasons!) {
        if(!seasonModel.fromDate.isAfter(DateTime.now()) && !seasonModel.toDate.isBefore(DateTime.now())) {
          currentSeason = seasonModel;
          return;
        }
      }
      currentSeason = SeasonModel.otherSeason();
    }
  }

  void _initListBeerHelpers() {
    if(beerStatsHelper != null) {
      if (players != null) {
        beersForPlayers = beerStatsHelper!
            .convertBeerModelToBeerStatsHelperModelForPlayers(players!);
      }
      if (matches != null) {
        beersForMatches = beerStatsHelper!
            .convertBeerModelToBeerStatsHelperModelForMatches(matches!);
      }
    }
  }

  void _initListFineHelpers() {
    if(finesStatsHelper != null) {
      if (players != null) {
        finesForPlayers = finesStatsHelper!
            .convertFineModelToFineStatsHelperModelForPlayers(players!);
      }
      if (matches != null) {
        finesForMatches = finesStatsHelper!
            .convertFineModelToFineStatsHelperModelForMatches(matches!);
      }
    }
  }

  void _initBeerStatsHelper() {
    if(beers != null) {
      beerStatsHelper = BeerStatsHelper(beers!);
    }
  }

  void _initFinesStatsHelper() {
    if(finesMatches != null && fines != null) {
      finesStatsHelper = FineStatsHelper(fines!, finesMatches!);
    }
  }

  Stream<List<String>> getRandomFactListStream() {
    return randomFactListStream.stream;
  }

  Stream<String> getRandomFactStream() {
    return randomFactStream.stream;
  }

  void _initRandomFactStream() {
    if(finesForPlayers != null && finesForMatches != null && beersForPlayers != null && beersForMatches != null && seasons != null) {
      List<String> randomFactList = [];
      randomFactList.add(getAmountOfFinesInCurrentSeason());
      randomFactList.add(getAverageNumberOfBeersInHomeAndAwayMatch());
      randomFactList.add(getAverageNumberOfBeersInMatch());
      randomFactList.add(getAverageNumberOfBeersInMatchForFan());
      randomFactList.add(getAverageNumberOfBeersInMatchForPlayers());
      randomFactList.add(getAverageNumberOfBeersInMatchForPlayersAndFans());
      randomFactList.add(getAverageNumberOfFinesAmountInMatch());
      randomFactList.add(getAverageNumberOfFinesInMatchForPlayers());
      randomFactList.add(getAverageNumberOfFinesInMatch());
      randomFactList.add(getAverageNumberOfFinesInMatchForPlayers());
      randomFactList.add(getAverageNumberOfLiquorsInHomeAndAwayMatch());
      randomFactList.add(getAverageNumberOfLiquorsInMatch());
      randomFactList.add(getAverageNumberOfLiquorsInMatchForFans());
      randomFactList.add(getAverageNumberOfLiquorsInMatchForPlayers());
      randomFactList.add(getAverageNumberOfLiquorsInMatchForPlayersAndFans());
      randomFactList.add(getHighestAttendanceInMatch());
      randomFactList.add(getLowestAttendanceInMatch());
      randomFactList.add(getMatchWithBirthday());
      randomFactList.add(getMatchWithHighestAverageBeers());
      randomFactList.add(getMatchWithHighestAverageLiquors());
      randomFactList.add(getMatchWithLowestAverageBeers());
      randomFactList.add(getMatchWithLowestAverageLiquors());
      randomFactList.add(getMatchWithMostBeers());
      randomFactList.add(getMatchWithMostBeersInCurrentSeason());
      randomFactList.add(getMatchWithMostFines());
      randomFactList.add(getMatchWithMostFinesAmount());
      randomFactList.add(getMatchWithMostFinesAmountInCurrentSeason());
      randomFactList.add(getMatchWithMostFinesInCurrentSeason());
      randomFactList.add(getMatchWithMostLiquors());
      randomFactList.add(getMatchWithMostLiquorsInCurrentSeason());
      randomFactList.add(getNumberOfBeersInCurrentSeason());
      randomFactList.add(getNumberOfFinesInCurrentSeason());
      randomFactList.add(getNumberOfLiquorsInCurrentSeason());
      randomFactList.add(getPlayerWithMostBeers());
      randomFactList.add(getPlayerWithMostFines());
      randomFactList.add(getPlayerWithMostFinesAmount());
      randomFactList.add(getPlayerWithMostLiquors());
      randomFactList.add(getSeasonWithMostBeers());
      randomFactList.add(getSeasonWithMostFines());
      randomFactList.add(getSeasonWithMostFinesAmount());
      randomFactList.add(getSeasonWithMostLiquors());
      randomFactListStream.add(randomFactList);
    }
  }

  void initStreams(Stream stream, Model model) async {
    stream.listen((event) {
      switch(model) {
        case Model.player:
          players = event;
          break;
        case Model.match:
          matches = event;
          break;
        case Model.fine:
          fines = event;
          _initFinesStatsHelper();
          break;
        case Model.beer:
          beers = event;
          _initBeerStatsHelper();
          break;
        case Model.fineMatch:
          finesMatches = event;
          _initFinesStatsHelper();
          break;
        case Model.playerStats:
          playerStats = event;
          break;
        case Model.seasons:
          seasons = event;
          _setCurrentSeason();
          break;
        case Model.user:
          // TODO: Handle this case.
          break;
        case Model.pkfl:
          // TODO: Handle this case.
          break;
      }
      _initListBeerHelpers();
      _initListFineHelpers();
      _initRandomFactStream();
    });
  }

  /// @return Vrátí text s hráčem nebo seznam hráčů, kteří vypili za celou historii (všechny zápasy v db) nejvíce piv
  String getPlayerWithMostBeers() {
    Drink enumDrink = Drink.beer;
    List<BeerStatsHelperModel> returnBeers =
        beerStatsHelper!.getBeerStatsHelperModelsWithMostBeers(
            beersForPlayers!, null, enumDrink);
    if (returnBeers.isEmpty ||
        returnBeers[0].getNumberOfDrinksInMatches(
                enumDrink, Participant.both, null) ==
            0) {
      return "Nelze najít největšího pijana, protože si ještě nikdo nedal pivo???!!";
    } else if (returnBeers.length == 1) {
      return "Nejvíce velkých piv za historii si dal ${returnBeers[0].player!.name} který vypil ${returnBeers[0].getNumberOfDrinksInMatches(enumDrink, Participant.both, null)} piv";
    } else {
      String result = "O pozici největšího pijana v historii se dělí ";
      for (int i = 0; i < returnBeers.length; i++) {
        result += returnBeers[i].player!.name;
        if (i == returnBeers.length - 1) {
          result +=
              " kteří všichni do jednoho vypili ${returnBeers[0].getNumberOfDrinksInMatches(enumDrink, Participant.both, null)} piv. Boj, boj, boj!";
        } else if (i == returnBeers.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  ///@return vrátí text se zápasem nebo seznamem zápasů, ve kterém se za historii (z db) vypilo nejvíce piv
  String getMatchWithMostBeers() {
    Drink enumDrink = Drink.beer;
    List<BeerStatsHelperModel> returnBeers =
        beerStatsHelper!.getBeerStatsHelperModelsWithMostBeers(
            beersForMatches!, null, enumDrink);
    if (returnBeers.isEmpty ||
        returnBeers[0].getNumberOfDrinksInMatches(
                Drink.beer, Participant.both, null) ==
            0) {
      return "Nelze najít zápas s nejvíce pivy, protože si zatím nikdo žádný nedal!";
    } else if (returnBeers.length == 1) {
      return "Nejvíce piv za historii padlo v zápase ${returnBeers[0].match!.toStringWithOpponentNameAndDate()} a padlo v něm ${returnBeers[0].getNumberOfDrinksInMatches(Drink.beer, Participant.both, null)} piv";
    } else {
      String result = "O pozici zápasu ve kterém padlo nejvíce piv se dělí ";
      for (int i = 0; i < returnBeers.length; i++) {
        result += returnBeers[i].match!.toStringWithOpponentNameAndDate();
        if (i == returnBeers.length - 1) {
          result +=
              " ve kterých padlo ${returnBeers[0].getNumberOfDrinksInMatches(Drink.beer, Participant.both, null)} piv.";
        } else if (i == returnBeers.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  /// @return vrátí počet piv v aktuální sezoně dle data
  String getNumberOfBeersInCurrentSeason() {
    int beerNumber = 0;
    List<BeerStatsHelperModel> returnBeers = beersForMatches!;
    for (BeerStatsHelperModel beer in returnBeers) {
      if (beer.match!.seasonId == currentSeason.id) {
        beerNumber +=
            beer.getNumberOfDrinksInMatches(Drink.beer, Participant.both, null);
      }
    }
    return "V aktuální sezoně ${currentSeason.name} se vypilo $beerNumber piv";
  }

  /// @return vrátí text se zápasem nebo listem zápasů ve kterých se tuto sezonu vypilo nejvíce piv
  String getMatchWithMostBeersInCurrentSeason() {
    Drink enumDrink = Drink.beer;
    List<BeerStatsHelperModel> returnBeers =
        beerStatsHelper!.getBeerStatsHelperModelsWithMostBeers(
            beersForMatches!, currentSeason.id, enumDrink);
    if (returnBeers.isEmpty ||
        returnBeers[0].getNumberOfDrinksInMatches(
                Drink.beer, Participant.both, null) ==
            0) {
      return "Nelze najít zápas s nejvíce pivy v této sezoně ${currentSeason.name}, protože si zatím nikdo žádný nedal!";
    } else if (returnBeers.length == 1) {
      return "Nejvíce piv v aktuální sezoně ${currentSeason.name} padlo v zápase ${returnBeers[0].match!.toStringWithOpponentNameAndDate()} a padlo v něm ${returnBeers[0].getNumberOfDrinksInMatches(Drink.beer, Participant.both, null)} piv";
    } else {
      String result =
          "O pozici zápasu ve kterém padlo nejvíce piv v aktuální sezoně ${currentSeason.name} se dělí ";
      for (int i = 0; i < returnBeers.length; i++) {
        result += returnBeers[i].match!.toStringWithOpponentNameAndDate();
        if (i == returnBeers.length - 1) {
          result +=
              " ve kterých padlo ${returnBeers[0].getNumberOfDrinksInMatches(Drink.beer, Participant.both, null)} piv.";
        } else if (i == returnBeers.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  /// @return vrátí text sezonu/sezony ve kterých padlo v historii nejvíce piv, společně s počtem a počtem zápasů
  String getSeasonWithMostBeers() {
    List<BeerSeasonHelper> returnSeasons = beerStatsHelper!
        .getSeasonWithMostBeers(beersForMatches!, seasons!, Drink.beer);
    if (returnSeasons.isEmpty || returnSeasons[0].beerNumber == 0) {
      return "Nelze najít sezonu s nejvíce pivy, protože si zatím nikdo pivo nedal!!!";
    } else if (returnSeasons.length == 1) {
      return "Nejvíce piv se vypilo v sezoně ${returnSeasons[0].seasonModel.name},kdy se v ${returnSeasons[0].matchNumber}. zápasech vypilo ${returnSeasons[0].beerNumber} piv";
    } else {
      String result = "Nejvíce pivy se můžou chlubit  sezony ";
      for (int i = 0; i < returnSeasons.length; i++) {
        result +=
            "${returnSeasons[i].seasonModel.name} s ${returnSeasons[i].matchNumber}. zápasy";
        if (i == returnSeasons.length - 1) {
          result += ", ve kterých padlo ${returnSeasons[0].beerNumber} piv.";
        } else if (i == returnSeasons.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  /// @return vrátí průměrný počet piv na všechny účastníky včetně fans
  String getAverageNumberOfBeersInMatchForPlayersAndFans() {
    int beerNumber = 0;
    int playerNumber = 0;
    List<BeerStatsHelperModel> returnBeers = beersForMatches!;
    for (BeerStatsHelperModel beer in returnBeers) {
      beerNumber +=
          beer.getNumberOfDrinksInMatches(Drink.beer, Participant.both, null);
      playerNumber += beer.getNumberOfPlayersInMatch(Participant.both, null);
    }
    double average = beerNumber / playerNumber;
    return "Za celou historii průměrně každý hráč a fanoušek Trusu vypil $average piv za zápas";
  }

  /// @return vrátí průměrný počet piv na hráče
  String getAverageNumberOfBeersInMatchForPlayers() {
    int beerNumber = 0;
    int playerNumber = 0;
    List<BeerStatsHelperModel> returnBeers = beersForMatches!;
    for (BeerStatsHelperModel beer in returnBeers) {
      beerNumber += beer.getNumberOfDrinksInMatches(
          Drink.beer, Participant.player, players);
      playerNumber += beer.getNumberOfPlayersInMatch(Participant.fan, players);
    }
    double average = beerNumber / playerNumber;
    return "Za celou historii průměrně každý hráč Trusu vypil $average piv za zápas";
  }

  /// @return vrátí průměrný počet piv na fanouška
  String getAverageNumberOfBeersInMatchForFan() {
    int beerNumber = 0;
    int playerNumber = 0;
    List<BeerStatsHelperModel> returnBeers = beersForMatches!;
    for (BeerStatsHelperModel beer in returnBeers) {
      beerNumber +=
          beer.getNumberOfDrinksInMatches(Drink.beer, Participant.fan, players);
      playerNumber += beer.getNumberOfPlayersInMatch(Participant.fan, players);
    }
    double average = beerNumber / playerNumber;
    return "Za celou historii průměrně každý fanoušek Trusu vypil $average piv za zápas";
  }

  /// @return vrátí průměrný počet piv na zápas
  String getAverageNumberOfBeersInMatch() {
    int beerNumber = 0;
    List<BeerStatsHelperModel> returnBeers = beersForMatches!;
    for (BeerStatsHelperModel beer in returnBeers) {
      beerNumber +=
          beer.getNumberOfDrinksInMatches(Drink.beer, Participant.fan, players);
    }
    double average = beerNumber / returnBeers.length;
    return "V naprosto průměrném zápasu Trusu se vypije $average piv";
  }

  /// @return Vrací dosud nejvyšší průměrný počet vypitých piv v jednom zápase
  String getMatchWithHighestAverageBeers() {
    List<BeerStatsHelperModel> returnMatches =
        beerStatsHelper!.getMatchWithHighestAverageBeers(
            beersForMatches!, null, true, Drink.beer);
    double average = 0;
    if (returnMatches.isEmpty) {
      return "Nelze najít zápas s nejvíce průměrnými pivy, protože si zatím nikdo pivo nedal!!!";
    } else {
      average = returnMatches[0]
              .getNumberOfDrinksInMatches(Drink.beer, Participant.both, null) /
          returnMatches[0].getNumberOfPlayersInMatch(Participant.both, null);
      if (returnMatches.length == 1) {
        return "Nejvyšší průměr počtu vypitých piv v zápase proběhl na zápase ${returnMatches[0].match!.toStringWithOpponentNameAndDate()}. "
            "Vypilo se ${returnMatches[0].getNumberOfDrinksInMatches(Drink.beer, Participant.both, null)} piv v ${returnMatches[0].getNumberOfPlayersInMatch(Participant.both, null)} lidech, což dělá průměr $average na hráče. "
            "Tak ještě jedno, ať to překonáme!";
      } else {
        String result =
            "Nejvyšší průměr počtu vypitých piv v zápase proběhl na v zápasech se ";
        for (int i = 0; i < returnMatches.length; i++) {
          result +=
              "soupeřem ${returnMatches[i].match!.toStringWithOpponentNameAndDate()} s celkovým počtem ${returnMatches[i].getNumberOfDrinksInMatches(Drink.beer, Participant.both, null)} "
              "piv v ${returnMatches[i].getNumberOfPlayersInMatch(Participant.both, null)} lidech";
          if (i == returnMatches.length - 1) {
            result += ".\n Celkový průměr pro tyto zápasy je $average piv.";
          } else if (i == returnMatches.length - 2) {
            result += " a ";
          } else {
            result += "; ";
          }
        }
        return result;
      }
    }
  }

  /// @return Vrací dosud nejnižší průměrný počet vypitých piv v jednom zápase
  String getMatchWithLowestAverageBeers() {
    List<BeerStatsHelperModel> returnMatches =
        beerStatsHelper!.getMatchWithHighestAverageBeers(
            beersForMatches!, null, false, Drink.beer);
    double average = 0;
    if (returnMatches.isEmpty) {
      return "Nelze najít zápas s nejméně průměrnými pivy, protože si zatím nikdo pivo nedal!!!";
    } else {
      average = returnMatches[0]
              .getNumberOfDrinksInMatches(Drink.beer, Participant.both, null) /
          returnMatches[0].getNumberOfPlayersInMatch(Participant.both, null);
      if (returnMatches.length == 1) {
        return "Ostudný den Liščího Trusu, kdy byl pokořen rekord v nejnižším průměru počtu vypitých piv v zápase proběhl na zápase ${returnMatches[0].match!.toStringWithOpponentNameAndDate()}. "
            "Vypilo se ${returnMatches[0].getNumberOfDrinksInMatches(Drink.beer, Participant.both, null)} piv v ${returnMatches[0].getNumberOfPlayersInMatch(Participant.both, null)} lidech, což dělá průměr $average na hráče. "
            "Vzpomeňte si na to, až si budete objednávat další rundu!";
      } else {
        String result =
            "Je až neuvěřitelné, že se taková potupa opakovala vícekrát, ovšem existuje více zápasů s ostudně nejnižším průměrem vypitých piv. Stalo se tak se ";
        for (int i = 0; i < returnMatches.length; i++) {
          result +=
              "soupeřem ${returnMatches[i].match!.toStringWithOpponentNameAndDate()} s celkovým počtem ${returnMatches[i].getNumberOfDrinksInMatches(Drink.beer, Participant.both, null)} "
              "piv v ${returnMatches[i].getNumberOfPlayersInMatch(Participant.both, null)} lidech";
          if (i == returnMatches.length - 1) {
            result += ".\n Celkový průměr pro tyto zápasy je $average piv.";
          } else if (i == returnMatches.length - 2) {
            result += " a ";
          } else {
            result += "; ";
          }
        }
        return result;
      }
    }
  }

  /// @return vrátí průměrný piv v domácím a venkovním zápase
  String getAverageNumberOfBeersInHomeAndAwayMatch() {
    int homeBeerNumber = 0;
    int awayBeerNumber = 0;
    int homeMatches = 0;
    List<BeerStatsHelperModel> returnBeers = beersForMatches!;
    for (BeerStatsHelperModel beerMatch in returnBeers) {
      if (beerMatch.match!.home) {
        homeBeerNumber += beerMatch.getNumberOfDrinksInMatches(
            Drink.beer, Participant.both, null);
        homeMatches++;
      } else {
        awayBeerNumber += beerMatch.getNumberOfDrinksInMatches(
            Drink.beer, Participant.both, null);
      }
    }
    double homeAverage = homeBeerNumber / homeMatches;
    double awayAverage = awayBeerNumber / (matches!.length - homeMatches);
    String response =
        "Průměrně se na domácím zápase vypije $homeAverage piv, oproti venkovním zápasům, kde je průměr $awayAverage piv na zápas. ";
    if (homeAverage > awayAverage) {
      return "${response}Tak to má být, soupeř musí prohrávat o 2 piva už u Průhonic!";
    }
    return "${response}Není načase změnit domácí hospodu?";
  }

  /// @return Vrací dosud nejvyšší účast jednom zápase spolu s podrobnými údaji
  String getHighestAttendanceInMatch() {
    List<BeerStatsHelperModel> returnMatches = [];
    int matchAttendance = 0;
    List<BeerStatsHelperModel> returnBeers = beersForMatches!;
    for (BeerStatsHelperModel beerMatch in returnBeers) {
      if (beerMatch.getNumberOfPlayersInMatch(Participant.both, null) >
          matchAttendance) {
        returnMatches.clear();
        returnMatches.add(beerMatch);
        matchAttendance =
            beerMatch.getNumberOfPlayersInMatch(Participant.both, null);
      } else if (beerMatch.getNumberOfPlayersInMatch(Participant.both, null) ==
          matchAttendance) {
        returnMatches.add(beerMatch);
      }
    }
    if (matchAttendance == 0) {
      return "Nelze najít zápas s nejvyšší účastí, protože se zatím žádný nehrál";
    } else if (returnMatches.length == 1) {
      return "Největší účast Liščího Trusu proběhla na zápase ${returnMatches[0].match!.toStringWithOpponentNameAndDate()} kdy celkový počet účastníků byl"
          " ${returnMatches[0].getNumberOfPlayersInMatch(Participant.fan, players)} fanoušků a ${returnMatches[0].getNumberOfPlayersInMatch(Participant.player, players)} hráčů, celkem tedy $matchAttendance lidí. "
          "Celkově se v tomto zápase vypilo ${returnMatches[0].getNumberOfDrinksInMatches(Drink.beer, Participant.both, null)} piv a ${returnMatches[0].getNumberOfDrinksInMatches(Drink.liquor, Participant.both, null)} panáků";
    } else {
      String result = "Největší účast Liščího Trusu proběhla v zápasech ";
      for (int i = 0; i < returnMatches.length; i++) {
        result +=
            "${returnMatches[i].match!.toStringWithOpponentNameAndDate()}, kdy celkový počet účastníků byl ${returnMatches[i].getNumberOfPlayersInMatch(Participant.fan, players)} fanoušků a "
            "${returnMatches[i].getNumberOfPlayersInMatch(Participant.player, players)} hráčů s počtem ${returnMatches[0].getNumberOfDrinksInMatches(Drink.beer, Participant.both, null)}. vypitých piv a "
            "${returnMatches[0].getNumberOfDrinksInMatches(Drink.liquor, Participant.both, null)} panáků";
        if (i == returnMatches.length - 1) {
          result += ".";
        } else if (i == returnMatches.length - 2) {
          result += " a ";
        } else {
          result += "; ";
        }
      }
      return result;
    }
  }

  /// @return Vrací dosud nejnižší účast jednom zápase spolu s podrobnými údaji
  String getLowestAttendanceInMatch() {
    List<BeerStatsHelperModel> returnMatches = [];
    int matchAttendance = 1000;
    List<BeerStatsHelperModel> returnBeers = beersForMatches!;
    for (BeerStatsHelperModel beerMatch in returnBeers) {
      if (beerMatch.getNumberOfPlayersInMatch(Participant.both, null) <
          matchAttendance) {
        returnMatches.clear();
        returnMatches.add(beerMatch);
        matchAttendance =
            beerMatch.getNumberOfPlayersInMatch(Participant.both, null);
      } else if (beerMatch.getNumberOfPlayersInMatch(Participant.both, null) ==
          matchAttendance) {
        returnMatches.add(beerMatch);
      }
    }
    if (returnMatches.isEmpty) {
      return "Nelze najít zápas s nejnižší účastí, protože se nejspíš zatím žádný nehrál";
    } else if (returnMatches.length == 1) {
      return "Nejnižší účast Liščího Trusu proběhla na zápase ${returnMatches[0].match!.toStringWithOpponentNameAndDate()} kdy celkový počet účastníků byl"
          " ${returnMatches[0].getNumberOfPlayersInMatch(Participant.fan, players)} fanoušků a ${returnMatches[0].getNumberOfPlayersInMatch(Participant.player, players)} hráčů, celkem tedy $matchAttendance lidí. "
          "Celkově se v tomto zápase vypilo ${returnMatches[0].getNumberOfDrinksInMatches(Drink.beer, Participant.both, null)} piv a ${returnMatches[0].getNumberOfDrinksInMatches(Drink.liquor, Participant.both, null)} panáků";
    } else {
      String result = "Nejnižší účast Liščího Trusu proběhla v zápasech ";
      for (int i = 0; i < returnMatches.length; i++) {
        result +=
            "${returnMatches[i].match!.toStringWithOpponentNameAndDate()}, kdy celkový počet účastníků byl ${returnMatches[i].getNumberOfPlayersInMatch(Participant.fan, players)} fanoušků a "
            "${returnMatches[i].getNumberOfPlayersInMatch(Participant.player, players)} hráčů s počtem ${returnMatches[0].getNumberOfDrinksInMatches(Drink.beer, Participant.both, null)}. vypitých piv a "
            "${returnMatches[0].getNumberOfDrinksInMatches(Drink.liquor, Participant.both, null)} panáků";
        if (i == returnMatches.length - 1) {
          result += ".";
        } else if (i == returnMatches.length - 2) {
          result += " a ";
        } else {
          result += "; ";
        }
      }
      return result;
    }
  }

  /// @return Vrátí text s hráčem nebo seznam hráčů, kteří dostali za celou historii (všechny zápasy v db) nejvíce pokut
  String getPlayerWithMostFines() {
    List<FineStatsHelperModel> returnFines =
        finesStatsHelper!.getFineStatsHelperModelsWithMostFines(
            finesForPlayers!, null, Fine.number);
    if (returnFines.isEmpty ||
        returnFines[0].getNumberOrAmountOfFines(Fine.number) == 0) {
      return "Nelze nalézt hráče s nejvíce pokutami, protože ještě nikdo žádnou nedostal??!!";
    } else if (returnFines.length == 1) {
      return "Nejvíce pokut za historii dostal hráč ${returnFines[0].player!.name}, který dostal ${returnFines[0].getNumberOrAmountOfFines(Fine.number)} pokut. Za pokladníka děkujeme!";
    } else {
      String result =
          "O pozici hráče s největším počtem pokut v historii se dělí ";
      for (int i = 0; i < returnFines.length; i++) {
        result += returnFines[0].player!.name;
        if (i == returnFines.length - 1) {
          result +=
              " kteří všichni do jednoho dostali ${returnFines[0].getNumberOrAmountOfFines(Fine.number)} pokut. Nádherný souboj, prosíme, ještě přidejte!";
        } else if (i == returnFines.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  /// @return vrátí text se zápasem nebo seznamem zápasů, ve kterém se za historii (z db) padlo nejvíce pokut
  String getMatchWithMostFines() {
    List<FineStatsHelperModel> returnFines =
        finesStatsHelper!.getFineStatsHelperModelsWithMostFines(
            finesForMatches!, null, Fine.number);
    if (returnFines.isEmpty ||
        returnFines[0].getNumberOrAmountOfFines(Fine.number) == 0) {
      return "Nelze nalézt zápas s nejvíce pokutami, protože ještě nikdo žádnou nedostal??!!";
    } else if (returnFines.length == 1) {
      return "Nejvíce pokut v historii padlo v zápase ${returnFines[0].match!.toStringWithOpponentNameAndDate()}, a udělilo se v něm ${returnFines[0].getNumberOrAmountOfFines(Fine.number)} pokut. Za pokladníka děkujeme!";
    } else {
      String result =
          "O pozici zápasu ve kterém padlo nejvíce pokut se dělí zápas ";
      for (int i = 0; i < returnFines.length; i++) {
        result += returnFines[0].match!.toStringWithOpponentNameAndDate();
        if (i == returnFines.length - 1) {
          result +=
              " ve kterých padlo ${returnFines[0].getNumberOrAmountOfFines(Fine.number)} pokut.";
        } else if (i == returnFines.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  /// @return Vrátí text s hráčem nebo seznam hráčů, kteří zaplatili za celou historii (všechny zápasy v db) nejvíce na pokutách
  String getPlayerWithMostFinesAmount() {
    List<FineStatsHelperModel> returnFines =
        finesStatsHelper!.getFineStatsHelperModelsWithMostFines(
            finesForPlayers!, null, Fine.amount);
    if (returnFines.isEmpty ||
        returnFines[0].getNumberOrAmountOfFines(Fine.amount) == 0) {
      return "Nelze nalézt hráče, co nejvíc zaplatil na pokutách, protože ještě nikdo žádnou nedostal??!!";
    } else if (returnFines.length == 1) {
      return "Nejvíce pokuty stály hráče ${returnFines[0].player!.name}, který celkem zacáloval ${returnFines[0].getNumberOrAmountOfFines(Fine.amount)} Kč. Nezapomeň, je to nedílná součást tréningového procesu!";
    } else {
      String result =
          "O pozici hráče co nejvíc zacálovali na pokutách se dělí ";
      for (int i = 0; i < returnFines.length; i++) {
        result += returnFines[0].player!.name;
        if (i == returnFines.length - 1) {
          result +=
              " kteří všichni do jednoho zaplatili ${returnFines[0].getNumberOrAmountOfFines(Fine.amount)} Kč. Díky kluci, zvyšuje to autoritu trenéra!";
        } else if (i == returnFines.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  /// @return vrátí text se zápasem nebo seznamem zápasů, ve kterém se za historii (z db) nejvíce vydělalo na pokutách
  String getMatchWithMostFinesAmount() {
    List<FineStatsHelperModel> returnFines =
        finesStatsHelper!.getFineStatsHelperModelsWithMostFines(
            finesForMatches!, null, Fine.amount);
    if (returnFines.isEmpty ||
        returnFines[0].getNumberOrAmountOfFines(Fine.amount) == 0) {
      return "Nelze nalézt zápas, kde se nejvíc cálovalo za pokuty, protože ještě nikdo žádnou nedostal??!!";
    } else if (returnFines.length == 1) {
      return "Největší objem peněz v pokutách přinesl zápas ${returnFines[0].match!.toStringWithOpponentNameAndDate()}, a vybralo se v něm ${returnFines[0].getNumberOrAmountOfFines(Fine.amount)} Kč";
    } else {
      String result =
          "O pozici zápasu ve kterém se klubová pokladna nejvíce nafoukla se dělí zápas";
      for (int i = 0; i < returnFines.length; i++) {
        result += returnFines[0].match!.toStringWithOpponentNameAndDate();
        if (i == returnFines.length - 1) {
          result +=
              " ve kterých se vybralo  ${returnFines[0].getNumberOrAmountOfFines(Fine.amount)} Kč.";
        } else if (i == returnFines.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  /// @return vrátí počet pokut v aktuální sezoně dle data
  String getNumberOfFinesInCurrentSeason() {
    int fineNumber = 0;
    List<FineStatsHelperModel> returnFines = finesForMatches!;
    for (FineStatsHelperModel fine in returnFines) {
      if (fine.match!.seasonId == currentSeason.id) {
        fineNumber += fine.getNumberOrAmountOfFines(Fine.number);
      }
    }
    return "V aktuální sezoně ${currentSeason.name} se rozdalo již $fineNumber pokut";
  }

  /// @return vrátí vybranou částku na pokutách v aktuální sezoně dle data
  String getAmountOfFinesInCurrentSeason() {
    int fineNumber = 0;
    List<FineStatsHelperModel> returnFines = finesForMatches!;
    for (FineStatsHelperModel fine in returnFines) {
      if (fine.match!.seasonId == currentSeason.id) {
        fineNumber += fine.getNumberOrAmountOfFines(Fine.amount);
      }
    }
    return "V aktuální sezoně ${currentSeason.name} se na pokutách vybralo již $fineNumber Kč";
  }

  /// @return vrátí text se zápasem nebo listem zápasů ve kterých se tuto sezonu rozdalo nejvíce pokut
  String getMatchWithMostFinesInCurrentSeason() {
    Fine enumFine = Fine.number;
    List<FineStatsHelperModel> returnFines =
        finesStatsHelper!.getFineStatsHelperModelsWithMostFines(
            finesForMatches!, currentSeason.id, enumFine);
    if (returnFines.isEmpty ||
        returnFines[0].getNumberOrAmountOfFines(enumFine) == 0) {
      return "Nelze najít zápas s nejvíce pokutami odehraný v této sezoně  ${currentSeason.name}, protože se zatím žádná pokuta neudělila!";
    } else if (returnFines.length == 1) {
      return "Nejvíce pokut v aktuální sezoně ${currentSeason.name} se rozdalo v zápase ${returnFines[0].match!.toStringWithOpponentNameAndDate()} a padlo v něm ${returnFines[0].getNumberOrAmountOfFines(enumFine)} pokut";
    } else {
      String result =
          "O pozici zápasu ve kterém se rozdalo nejvíce pokut v aktuální sezoně ${currentSeason.name} se dělí ";
      for (int i = 0; i < returnFines.length; i++) {
        result += returnFines[i].match!.toStringWithOpponentNameAndDate();
        if (i == returnFines.length - 1) {
          result +=
              " ve kterých padlo ${returnFines[0].getNumberOrAmountOfFines(enumFine)} pokut.";
        } else if (i == returnFines.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  /// @return vrátí text se zápasem nebo listem zápasů ve kterých se tuto sezonu nejvíce vydělalo na pokutách
  String getMatchWithMostFinesAmountInCurrentSeason() {
    Fine enumFine = Fine.amount;
    List<FineStatsHelperModel> returnFines =
        finesStatsHelper!.getFineStatsHelperModelsWithMostFines(
            finesForMatches!, currentSeason.id, enumFine);
    if (returnFines.isEmpty ||
        returnFines[0].getNumberOrAmountOfFines(enumFine) == 0) {
      return "Nelze najít zápas, kde se v této sezoně ${currentSeason.name} nejvíce cálovalo za pokuty, protože se zatím žádná pokuta neudělila!";
    } else if (returnFines.length == 1) {
      return "Největší objem peněz v aktuální sezoně ${currentSeason.name} přinesl zápas ${returnFines[0].match!.toStringWithOpponentNameAndDate()} a vybralo se v něm ${returnFines[0].getNumberOrAmountOfFines(enumFine)} Kč";
    } else {
      String result =
          "O pozici zápasu, který přinesl klubové pokladně nejvíce peněz z pokut v aktuální sezoně ${currentSeason.name} se dělí ";
      for (int i = 0; i < returnFines.length; i++) {
        result += returnFines[i].match!.toStringWithOpponentNameAndDate();
        if (i == returnFines.length - 1) {
          result +=
              " ve kterých se vybralo ${returnFines[0].getNumberOrAmountOfFines(enumFine)} Kč.";
        } else if (i == returnFines.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  /// @return vrátí text sezonu/sezony ve kterých padlo v historii nejvíce pokut, společně s počtem a počtem zápasů
  String getSeasonWithMostFines() {
    Fine enumFine = Fine.number;
    List<FineSeasonHelper> returnSeasons = finesStatsHelper!
        .getSeasonWithMostBeers(finesForMatches!, seasons!, enumFine);
    if (returnSeasons.isEmpty ||
        returnSeasons[0].getNumberOrAmount(enumFine) == 0) {
      return "Nelze najít sezonu s nejvíce pokutama, protože se zatím žádná pokuta nerozdala!";
    } else if (returnSeasons.length == 1) {
      return "Nejvíce pokut se rozdalo v sezoně ${returnSeasons[0].seasonModel.name}, kdy v ${returnSeasons[0].matchNumber}. zápasech padlo ${returnSeasons[0].getNumberOrAmount(enumFine)} pokut";
    } else {
      String result = "Nejvíce pokutami se můžou chlubit sezony ";
      for (int i = 0; i < returnSeasons.length; i++) {
        result +=
            "${returnSeasons[i].seasonModel.name} s ${returnSeasons[i].matchNumber}. zápasy";
        if (i == returnSeasons.length - 1) {
          result +=
              ", ve kterých padlo ${returnSeasons[0].getNumberOrAmount(enumFine)} pokut.";
        } else if (i == returnSeasons.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  /// @return vrátí text sezonu/sezony ve kterých se vybralo v historii nejvíce za pokuty, společně s počtem zápasů
  String getSeasonWithMostFinesAmount() {
    Fine enumFine = Fine.amount;
    List<FineSeasonHelper> returnSeasons = finesStatsHelper!
        .getSeasonWithMostBeers(finesForMatches!, seasons!, enumFine);
    if (returnSeasons.isEmpty ||
        returnSeasons[0].getNumberOrAmount(enumFine) == 0) {
      return "Nelze najít sezonu kdy se vybralo nejvíc za pokuty, protože se zatím žádná pokuta nerozdala!";
    } else if (returnSeasons.length == 1) {
      return "Nejvíc peněz na pokutách se vybralo v sezoně ${returnSeasons[0].seasonModel.name}, kdy v ${returnSeasons[0].matchNumber} zápasech pokladna shrábla ${returnSeasons[0].getNumberOrAmount(enumFine)} Kč.";
    } else {
      String result =
          "Největším objemem vybraných peněz se můžou chlubit sezony ";
      for (int i = 0; i < returnSeasons.length; i++) {
        result +=
            "${returnSeasons[i].seasonModel.name} s ${returnSeasons[i].matchNumber}. zápasy";
        if (i == returnSeasons.length - 1) {
          result +=
              ", ve kterých se zaplatilo ${returnSeasons[0].getNumberOrAmount(enumFine)} Kč.";
        } else if (i == returnSeasons.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  /// @return vrátí průměrný počet pokut na hráče
  String getAverageNumberOfFinesInMatchForPlayers() {
    int finesNumber = 0;
    int playerNumber = 0;
    List<FineStatsHelperModel> returnFines = finesForMatches!;
    for (FineStatsHelperModel fine in returnFines) {
      finesNumber += fine.getNumberOrAmountOfFines(Fine.number);
      playerNumber += fine.getNumberOfPlayersInMatch(Participant.fan, players);
    }
    double average = finesNumber / playerNumber;
    return "Za celou historii průměrně každý hráč Trusu dostal $average pokut za zápas";
  }

  /// @return vrátí průměrný cálování pokut na hráče
  String getAverageNumberOfFinesAmountInMatchForPlayers() {
    int finesNumber = 0;
    int playerNumber = 0;
    List<FineStatsHelperModel> returnFines = finesForMatches!;
    for (FineStatsHelperModel fine in returnFines) {
      finesNumber += fine.getNumberOrAmountOfFines(Fine.amount);
      playerNumber += fine.getNumberOfPlayersInMatch(Participant.fan, players);
    }
    double average = finesNumber / playerNumber;
    return "Za celou historii průměrně každý hráč Trusu zacáloval $average korun každý zápas za pokuty";
  }

  /// @return vrátí průměrný počet pokut na zápas
  String getAverageNumberOfFinesInMatch() {
    int finesNumber = 0;
    List<FineStatsHelperModel> returnFines = finesForMatches!;
    for (FineStatsHelperModel fine in returnFines) {
      finesNumber += fine.getNumberOrAmountOfFines(Fine.number);
    }
    double average = finesNumber / returnFines.length;
    return "V naprosto průměrném zápasu Trusu se udělí $average pokut";
  }

  /// @return vrátí průměrný počet vybranejch peněz v zápase
  String getAverageNumberOfFinesAmountInMatch() {
    int finesNumber = 0;
    List<FineStatsHelperModel> returnFines = finesForMatches!;
    for (FineStatsHelperModel fine in returnFines) {
      finesNumber += fine.getNumberOrAmountOfFines(Fine.amount);
    }
    double average = finesNumber / returnFines.length;
    return "V naprosto průměrném zápasu Trusu se vybere $average Kč na pokutách";
  }

  /// @return Vrátí text s hráčem nebo seznam hráčů, kteří vypili za celou historii (všechny zápasy v db) nejvíce panáků
  String getPlayerWithMostLiquors() {
    Drink enumDrink = Drink.liquor;
    List<BeerStatsHelperModel> returnBeers =
        beerStatsHelper!.getBeerStatsHelperModelsWithMostBeers(
            beersForPlayers!, null, enumDrink);
    if (returnBeers.isEmpty ||
        returnBeers[0].getNumberOfDrinksInMatches(
                enumDrink, Participant.both, null) ==
            0) {
      return "Zatím se hledá člověk, co by si dal alespoň jednoho panáka na zápase Trusu. Výherce čeká věčná sláva zvěčněná přímo v této zajímavosti do té doby, než si někdo dá panáky 2";
    } else if (returnBeers.length == 1) {
      return "Nejvíce panáků za historii si dal ${returnBeers[0].player!.name} který vypil ${returnBeers[0].getNumberOfDrinksInMatches(enumDrink, Participant.both, null)} frťanů. Na výkonu to vůbec není poznat, gratulujeme!";
    } else {
      String result =
          "Byť to zní jako scifi, tak těmto hráčům pravděpodobně chutná tvrdý více než pivo. Dělí se totiž o pozici největšího píče co se týče panáčků. Jedná se o ";
      for (int i = 0; i < returnBeers.length; i++) {
        result += returnBeers[i].player!.name;
        if (i == returnBeers.length - 1) {
          result +=
              " kteří všichni do jednoho vypili ${returnBeers[0].getNumberOfDrinksInMatches(enumDrink, Participant.both, null)} frťanů. Boj, boj, boj!";
        } else if (i == returnBeers.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  /// @return vrátí text se zápasem nebo seznamem zápasů, ve kterém se za historii (z db) vypilo nejvíce panáků
  String getMatchWithMostLiquors() {
    Drink enumDrink = Drink.liquor;
    List<BeerStatsHelperModel> returnBeers =
        beerStatsHelper!.getBeerStatsHelperModelsWithMostBeers(
            beersForMatches!, null, enumDrink);
    if (returnBeers.isEmpty ||
        returnBeers[0].getNumberOfDrinksInMatches(
                enumDrink, Participant.both, null) ==
            0) {
      return "Nelze najít zápas s nejvíce panáky, protože si zatím nikdo žádný nedal! Jedna šťopička nikdy nikoho nezabila, tak se neostýchejte pánové!";
    } else if (returnBeers.length == 1) {
      return "Nejvíce panáků za historii padlo v zápase ${returnBeers[0].match!.toStringWithOpponentNameAndDate()} a padlo v něm ${returnBeers[0].getNumberOfDrinksInMatches(enumDrink, Participant.both, null)} frťanů";
    } else {
      String result = "O pozici zápasu ve kterém padlo nejvíce panáků se dělí ";
      for (int i = 0; i < returnBeers.length; i++) {
        result += returnBeers[i].match!.toStringWithOpponentNameAndDate();
        if (i == returnBeers.length - 1) {
          result +=
              " ve kterých padlo ${returnBeers[0].getNumberOfDrinksInMatches(enumDrink, Participant.both, null)} frťanů.";
        } else if (i == returnBeers.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  /// @return vrátí počet panáků v aktuální sezoně dle data
  String getNumberOfLiquorsInCurrentSeason() {
    int liquorNumber = 0;
    List<BeerStatsHelperModel> returnBeers = beersForMatches!;
    for (BeerStatsHelperModel beer in returnBeers) {
      if (beer.match!.seasonId == currentSeason.id) {
        liquorNumber += beer.getNumberOfDrinksInMatches(
            Drink.liquor, Participant.both, null);
      }
    }
    return "V aktuální sezoně ${currentSeason.name} se vypilo $liquorNumber panáků";
  }

  /// @return vrátí text se zápasem nebo listem zápasů ve kterých se tuto sezonu vypilo nejvíce panáků
  String getMatchWithMostLiquorsInCurrentSeason() {
    Drink enumDrink = Drink.liquor;
    List<BeerStatsHelperModel> returnBeers =
        beerStatsHelper!.getBeerStatsHelperModelsWithMostBeers(
            beersForMatches!, currentSeason.id, enumDrink);
    if (returnBeers.isEmpty ||
        returnBeers[0].getNumberOfDrinksInMatches(
                enumDrink, Participant.both, null) ==
            0) {
      return "Nelze najít zápas s nejvíce panáky odehraný v této sezoně ${currentSeason.name}, protože si zatím nikdo žádný nedal! Aspoň jeden Liščí Trus denně je prospěšný pro zdraví, to vám potvrdí každý doktor";
    } else if (returnBeers.length == 1) {
      return "Nejvíce panáků v aktuální sezoně ${currentSeason.name} padlo v zápase ${returnBeers[0].match!.toStringWithOpponentNameAndDate()} v celkovém počtu ${returnBeers[0].getNumberOfDrinksInMatches(enumDrink, Participant.both, null)} kořalek";
    } else {
      String result =
          "O pozici zápasu ve kterém padlo nejvíce panáků v aktuální sezoně ${currentSeason.name} se dělí ";
      for (int i = 0; i < returnBeers.length; i++) {
        result += returnBeers[i].match!.toStringWithOpponentNameAndDate();
        if (i == returnBeers.length - 1) {
          result +=
              " ve kterých padlo ${returnBeers[0].getNumberOfDrinksInMatches(enumDrink, Participant.both, null)} tvrdýho.";
        } else if (i == returnBeers.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  /// @return vrátí text sezonu/sezony ve kterých padlo v historii nejvíce panáků, společně s počtem a počtem zápasů
  String getSeasonWithMostLiquors() {
    Drink enumDrink = Drink.liquor;
    List<BeerSeasonHelper> returnSeasons = beerStatsHelper!
        .getSeasonWithMostBeers(beersForMatches!, seasons!, enumDrink);
    if (returnSeasons.isEmpty || returnSeasons[0].liquorNumber == 0) {
      return "Sezona s nejvíce panáky je... žádná! Zatím si nikdo nedal ani jeden Liščí Trus!!";
    } else if (returnSeasons.length == 1) {
      return "Nejvíce panáků se vypilo v sezoně ${returnSeasons[0].seasonModel.name},kdy se v ${returnSeasons[0].matchNumber}. zápasech vypilo ${returnSeasons[0].liquorNumber} tvrdýho";
    } else {
      String result = "Nejvíce panáky se můžou chlubit  sezony ";
      for (int i = 0; i < returnSeasons.length; i++) {
        result +=
            "${returnSeasons[i].seasonModel.name} s ${returnSeasons[i].matchNumber}. zápasy";
        if (i == returnSeasons.length - 1) {
          result +=
              ", ve kterých padlo ${returnSeasons[0].liquorNumber} tvrdýho.";
        } else if (i == returnSeasons.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  /// @return vrátí průměrný počet panáků na všechny účastníky včetně fans
  String getAverageNumberOfLiquorsInMatchForPlayersAndFans() {
    int liquorNumber = 0;
    int playerNumber = 0;
    List<BeerStatsHelperModel> returnBeers = beersForMatches!;
    for (BeerStatsHelperModel beer in returnBeers) {
      liquorNumber +=
          beer.getNumberOfDrinksInMatches(Drink.liquor, Participant.both, null);
      playerNumber += beer.getNumberOfPlayersInMatch(Participant.both, null);
    }
    double average = liquorNumber / playerNumber;
    return "Za celou historii průměrně každý hráč a fanoušek Trusu vypil $average panáků za zápas";
  }

  /// @return vrátí průměrný počet panáků na hráče
  String getAverageNumberOfLiquorsInMatchForPlayers() {
    int liquorNumber = 0;
    int playerNumber = 0;
    List<BeerStatsHelperModel> returnBeers = beersForMatches!;
    for (BeerStatsHelperModel beer in returnBeers) {
      liquorNumber += beer.getNumberOfDrinksInMatches(
          Drink.liquor, Participant.player, players);
      playerNumber += beer.getNumberOfPlayersInMatch(Participant.fan, players);
    }
    double average = liquorNumber / playerNumber;
    return "Za celou historii průměrně každý hráč Trusu vypil $average panáků za zápas";
  }

  /// @return vrátí průměrný počet panáků na fanouška
  String getAverageNumberOfLiquorsInMatchForFans() {
    int liquorNumber = 0;
    int fanNumber = 0;
    List<BeerStatsHelperModel> returnBeers = beersForMatches!;
    for (BeerStatsHelperModel beer in returnBeers) {
      liquorNumber += beer.getNumberOfDrinksInMatches(
          Drink.liquor, Participant.fan, players);
      fanNumber += beer.getNumberOfPlayersInMatch(Participant.fan, players);
    }
    double average = liquorNumber / fanNumber;
    return "Za celou historii průměrně každý fanoušek Trusu vypil $average panáků za zápas";
  }

  /// @return vrátí průměrný počet panáků na zápas
  String getAverageNumberOfLiquorsInMatch() {
    int liquorNumber = 0;
    List<BeerStatsHelperModel> returnBeers = beersForMatches!;
    for (BeerStatsHelperModel beer in returnBeers) {
      liquorNumber += beer.getNumberOfDrinksInMatches(
          Drink.liquor, Participant.fan, players);
    }
    double average = liquorNumber / returnBeers.length;
    return "V naprosto průměrném zápasu Trusu se vypije $average panáků";
  }

  /// @return Vrací dosud nejvyšší průměrný počet vypitých panáků v jednom zápase
  String getMatchWithHighestAverageLiquors() {
    Drink enumDrink = Drink.liquor;
    List<BeerStatsHelperModel> returnMatches =
        beerStatsHelper!.getMatchWithHighestAverageBeers(
            beersForMatches!, null, true, enumDrink);
    double average = 0;
    if (returnMatches.isEmpty) {
      return "Nejvyšší průměr vypitých panáků na zápase Trusu je 0!! Nechce někdo vyměnit pivko za lahodný Liščí Trus?!?";
    } else {
      average = returnMatches[0]
              .getNumberOfDrinksInMatches(enumDrink, Participant.both, null) /
          returnMatches[0].getNumberOfPlayersInMatch(Participant.both, null);
      if (returnMatches.length == 1) {
        return "Nejvyšší průměr počtu vypitých panáků v zápase proběhl na zápase ${returnMatches[0].match!.toStringWithOpponentNameAndDate()}. "
            "Vypilo se ${returnMatches[0].getNumberOfDrinksInMatches(enumDrink, Participant.both, null)} tvrdýho v ${returnMatches[0].getNumberOfPlayersInMatch(Participant.both, null)} lidech, což dělá průměr $average na hráče. Copak se asi tehdy slavilo?";
      } else {
        String result =
            "Nejvyšší průměr počtu vypitých panáků v zápase proběhl se ";
        for (int i = 0; i < returnMatches.length; i++) {
          result +=
              "soupeřem ${returnMatches[i].match!.toStringWithOpponentNameAndDate()} s celkovým počtem ${returnMatches[i].getNumberOfDrinksInMatches(enumDrink, Participant.both, null)} "
              "tvrdýho v ${returnMatches[i].getNumberOfPlayersInMatch(Participant.both, null)} lidech";
          if (i == returnMatches.length - 1) {
            result +=
                ".\n Celkový průměr pro tyto zápasy je $average piv. Copak se asi tehdy slavilo?";
          } else if (i == returnMatches.length - 2) {
            result += " a ";
          } else {
            result += "; ";
          }
        }
        return result;
      }
    }
  }

  /// @return Vrací dosud nejnižší průměrný počet vypitých panáků v jednom zápase
  String getMatchWithLowestAverageLiquors() {
    Drink enumDrink = Drink.liquor;
    List<BeerStatsHelperModel> returnMatches =
        beerStatsHelper!.getMatchWithHighestAverageBeers(
            beersForMatches!, null, false, enumDrink);
    double average = 0;
    if (returnMatches.isEmpty) {
      return "Zatím v žádném zápase Trusu nepadl jediný panák. To nikdo neslyšel o blahodárném drinku jménem Liščí Trus?";
    } else {
      average = returnMatches[0]
              .getNumberOfDrinksInMatches(enumDrink, Participant.both, null) /
          returnMatches[0].getNumberOfPlayersInMatch(Participant.both, null);
      if (returnMatches.length == 1) {
        return "Můžete sami posoudit, jaká ostuda se stala v zápase ${returnMatches[0].match!.toStringWithOpponentNameAndDate()}, kdz se historicky vypil nejmenší průměr panáků."
            "Vypilo se ${returnMatches[0].getNumberOfDrinksInMatches(enumDrink, Participant.both, null)} kořalek v ${returnMatches[0].getNumberOfPlayersInMatch(Participant.both, null)} lidech, což dělá průměr $average na hráče. "
            "Možná to může zachránit počet piv v zápase, který byl ${returnMatches[0].getNumberOfDrinksInMatches(Drink.beer, Participant.both, null)}. Vzpomeňte si na to, až si budete objednávat další rundu, ideálně slavný Liščí Trus!";
      } else {
        String result =
            "Bohužel je znát, že Trus je tým zaměřený spíše na piva. Jinak by ani nebylo možné, aby existovalo více zápasů s nejnižším průměrem vypitých panáků. Stalo se tak se ";
        for (int i = 0; i < returnMatches.length; i++) {
          result +=
              "soupeřem ${returnMatches[i].match!.toStringWithOpponentNameAndDate()} s celkovým počtem ${returnMatches[i].getNumberOfDrinksInMatches(enumDrink, Participant.both, null)} "
              "tvrdýho v ${returnMatches[i].getNumberOfPlayersInMatch(Participant.both, null)} lidech";
          if (i == returnMatches.length - 1) {
            result += ".\n Celkový průměr pro tyto zápasy je $average kořalek.";
          } else if (i == returnMatches.length - 2) {
            result += " a ";
          } else {
            result += "; ";
          }
        }
        return result;
      }
    }
  }

  /*---------------------tvrdej alkohol-------------------*/
  /// @return vrátí průměrný tvrdejch v domácím a venkovním zápase
  String getAverageNumberOfLiquorsInHomeAndAwayMatch() {
    Drink enumDrink = Drink.liquor;
    int homeLiquorNumber = 0;
    int awayLiquorNumber = 0;
    int homeMatches = 0;
    List<BeerStatsHelperModel> returnBeers = beersForMatches!;
    for (BeerStatsHelperModel beerMatch in returnBeers) {
      if (beerMatch.match!.home) {
        homeLiquorNumber += beerMatch.getNumberOfDrinksInMatches(
            enumDrink, Participant.both, null);
        homeMatches++;
      } else {
        awayLiquorNumber += beerMatch.getNumberOfDrinksInMatches(
            enumDrink, Participant.both, null);
      }
    }
    double homeAverage = homeLiquorNumber / homeMatches;
    double awayAverage = awayLiquorNumber / (matches!.length - homeMatches);
    String response =
        "Průměrně se na domácím zápase vypije $homeAverage panáků, oproti venkovním zápasům, kde je průměr $awayAverage panáků na zápas. ";
    if (homeAverage > awayAverage) {
      return "${response}Zdá se, že při domácím zápase se chlastá daleko líp než venku!";
    }
    return "${response}Ve školce snad nalejvá kuchař i panáky?";
  }

  String getMatchWithBirthday() {
    List<MatchModel> matchesWithBirthday = [];
    List<PlayerModel> playersWithBirthday = [];
    for (MatchModel match in matches!) {
      for (PlayerModel player in players!) {
        if (match.date.isAtSameMomentAs(player.birthday)) {
          matchesWithBirthday.add(match);
          playersWithBirthday.add(player);
        }
      }
    }
    //pokud se nikdo nenašel v první iteraci, tedy žádné narozky se nekrejou s datem zápasu
    if (matchesWithBirthday.isEmpty) {
      return "Zatím se nenašel zápas kde by nějaký hráč zapíjel narozky. Už se všichni těšíme";
    } else {
      //nejprve zjišťujeme, zda hráč, který měl narozky v den zápasu, skutečně byl na zápasu přítomen
      List<MatchModel> returnMatches = [];
      List<PlayerModel> returnPlayers = [];
      for (MatchModel match in matchesWithBirthday) {
        for (PlayerModel player in playersWithBirthday) {
          if (match.playerIdList.contains(player.id)) {
            returnPlayers.add(player);
            returnMatches.add(match);
          }
        }
      }
      //Pokud nikdo s narozkama nebyl na zápase trusu, tak uděláme stěnu hamby
      List<BeerModel> returnBeers =
          beerStatsHelper!.getNumberOfBeersInMatchForPlayer(
              returnPlayers, returnMatches, beers!);
      if (returnMatches.isEmpty) {
        String result =
            "Zatím se nenašel zápas kde by nějaký hráč zapíjel narozky. Už se všichni těšíme. Do té doby zde máme zeď hamby pro hráče, kteří raději své narozeniny zapíjeli jinde než na Trusu. Hamba! : ";
        for (int i = 0; i < playersWithBirthday.length; i++) {
          result += playersWithBirthday[i].name;
          if (i == playersWithBirthday.length - 1) {
            result += ".";
          } else if (i == playersWithBirthday.length - 2) {
            result += " a ";
          } else {
            result += ", ";
          }
        }
        return result;
      }
      //Pokud byl jenom jeden takový šťastlivec
      else if (returnMatches.length == 1) {
        return "Zatím jediný zápas, kdy někdo z Trusu zapíjel narozky byl ${returnMatches[0].toStringWithOpponentNameAndDate()} kdy slavil ${returnPlayers[0].name}, "
            "který vypil ${returnBeers[0].beerNumber} piv a ${returnBeers[0].liquorNumber} panáků.";
      }
      //pokud jich bylo víc
      else {
        String result =
            "Velká společenská událost v podobě oslavy narozek se konala na zápasech ";
        for (int i = 0; i < returnMatches.length; i++) {
          result +=
              "${returnMatches[i].toStringWithOpponentNameAndDate()}, kdy slavil narozky ${returnPlayers[i].name}, který vypil ${returnBeers[i].beerNumber} piv a ${returnBeers[i].liquorNumber}.";
          if (i == returnMatches.length - 1) {
            result += ".";
          } else if (i == returnMatches.length - 2) {
            result += " a proti ";
          } else {
            result += ". Proti ";
          }
        }
        return result;
      }
    }
  }
}

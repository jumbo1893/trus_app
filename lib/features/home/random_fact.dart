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
    }
    currentSeason = SeasonModel.otherSeason();
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
      randomFactList.add(getAmountOfFinesInCurrentSeason()); //0
      randomFactList.add(getAverageNumberOfBeersInHomeAndAwayMatch());
      randomFactList.add(getAverageNumberOfBeersInMatch());
      randomFactList.add(getAverageNumberOfBeersInMatchForFan());
      randomFactList.add(getAverageNumberOfBeersInMatchForPlayers());
      randomFactList.add(getAverageNumberOfBeersInMatchForPlayersAndFans());
      randomFactList.add(getAverageNumberOfFinesAmountInMatch());
      randomFactList.add(getAverageNumberOfFinesInMatchForPlayers());
      randomFactList.add(getAverageNumberOfFinesInMatch());
      randomFactList.add(getAverageNumberOfFinesInMatchForPlayers());
      randomFactList.add(getAverageNumberOfLiquorsInHomeAndAwayMatch()); //10
      randomFactList.add(getAverageNumberOfLiquorsInMatch());
      randomFactList.add(getAverageNumberOfLiquorsInMatchForFans());
      randomFactList.add(getAverageNumberOfLiquorsInMatchForPlayers());
      randomFactList.add(getAverageNumberOfLiquorsInMatchForPlayersAndFans());
      randomFactList.add(getHighestAttendanceInMatch());
      randomFactList.add(getLowestAttendanceInMatch());
      randomFactList.add(getMatchWithBirthday());
      randomFactList.add(getMatchWithHighestAverageBeers());
      randomFactList.add(getMatchWithHighestAverageLiquors());
      randomFactList.add(getMatchWithLowestAverageBeers()); //20
      randomFactList.add(getMatchWithLowestAverageLiquors());
      randomFactList.add(getMatchWithMostBeers());
      randomFactList.add(getMatchWithMostBeersInCurrentSeason());
      randomFactList.add(getMatchWithMostFines());
      randomFactList.add(getMatchWithMostFinesAmount());
      randomFactList.add(getMatchWithMostFinesAmountInCurrentSeason());
      randomFactList.add(getMatchWithMostFinesInCurrentSeason());
      randomFactList.add(getMatchWithMostLiquors());
      randomFactList.add(getMatchWithMostLiquorsInCurrentSeason());
      randomFactList.add(getNumberOfBeersInCurrentSeason()); //30
      randomFactList.add(getNumberOfFinesInCurrentSeason());
      randomFactList.add(getNumberOfLiquorsInCurrentSeason());
      randomFactList.add(getPlayerWithMostBeers());
      randomFactList.add(getPlayerWithMostFines());
      randomFactList.add(getPlayerWithMostFinesAmount());
      randomFactList.add(getPlayerWithMostLiquors());
      randomFactList.add(getSeasonWithMostBeers());
      randomFactList.add(getSeasonWithMostFines());
      randomFactList.add(getSeasonWithMostFinesAmount());
      randomFactList.add(getSeasonWithMostLiquors()); //40
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

  /// @return Vr??t?? text s hr????em nebo seznam hr??????, kte???? vypili za celou historii (v??echny z??pasy v db) nejv??ce piv
  String getPlayerWithMostBeers() {
    Drink enumDrink = Drink.beer;
    List<BeerStatsHelperModel> returnBeers =
        beerStatsHelper!.getBeerStatsHelperModelsWithMostBeers(
            beersForPlayers!, null, enumDrink);
    if (returnBeers.isEmpty ||
        returnBeers[0].getNumberOfDrinksInMatches(
                enumDrink, Participant.both, null) ==
            0) {
      return "Nelze naj??t nejv??t????ho pijana, proto??e si je??t?? nikdo nedal pivo???!!";
    } else if (returnBeers.length == 1) {
      return "Nejv??ce velk??ch piv za historii si dal ${returnBeers[0].player!.name} kter?? vypil ${returnBeers[0].getNumberOfDrinksInMatches(enumDrink, Participant.both, null)} piv";
    } else {
      String result = "O pozici nejv??t????ho pijana v historii se d??l?? ";
      for (int i = 0; i < returnBeers.length; i++) {
        result += returnBeers[i].player!.name;
        if (i == returnBeers.length - 1) {
          result +=
              " kte???? v??ichni do jednoho vypili ${returnBeers[0].getNumberOfDrinksInMatches(enumDrink, Participant.both, null)} piv. Boj, boj, boj!";
        } else if (i == returnBeers.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  ///@return vr??t?? text se z??pasem nebo seznamem z??pas??, ve kter??m se za historii (z db) vypilo nejv??ce piv
  String getMatchWithMostBeers() {
    Drink enumDrink = Drink.beer;
    List<BeerStatsHelperModel> returnBeers =
        beerStatsHelper!.getBeerStatsHelperModelsWithMostBeers(
            beersForMatches!, null, enumDrink);
    if (returnBeers.isEmpty ||
        returnBeers[0].getNumberOfDrinksInMatches(
                Drink.beer, Participant.both, null) ==
            0) {
      return "Nelze naj??t z??pas s nejv??ce pivy, proto??e si zat??m nikdo ????dn?? nedal!";
    } else if (returnBeers.length == 1) {
      return "Nejv??ce piv za historii padlo v z??pase ${returnBeers[0].match!.toStringWithOpponentNameAndDate()} a padlo v n??m ${returnBeers[0].getNumberOfDrinksInMatches(Drink.beer, Participant.both, null)} piv";
    } else {
      String result = "O pozici z??pasu ve kter??m padlo nejv??ce piv se d??l?? ";
      for (int i = 0; i < returnBeers.length; i++) {
        result += returnBeers[i].match!.toStringWithOpponentNameAndDate();
        if (i == returnBeers.length - 1) {
          result +=
              " ve kter??ch padlo ${returnBeers[0].getNumberOfDrinksInMatches(Drink.beer, Participant.both, null)} piv.";
        } else if (i == returnBeers.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  /// @return vr??t?? po??et piv v aktu??ln?? sezon?? dle data
  String getNumberOfBeersInCurrentSeason() {
    int beerNumber = 0;
    List<BeerStatsHelperModel> returnBeers = beersForMatches!;
    for (BeerStatsHelperModel beer in returnBeers) {
      if (beer.match!.seasonId == currentSeason.id) {
        beerNumber +=
            beer.getNumberOfDrinksInMatches(Drink.beer, Participant.both, null);
      }
    }
    return "V aktu??ln?? sezon?? ${currentSeason.name} se vypilo $beerNumber piv";
  }

  /// @return vr??t?? text se z??pasem nebo listem z??pas?? ve kter??ch se tuto sezonu vypilo nejv??ce piv
  String getMatchWithMostBeersInCurrentSeason() {
    Drink enumDrink = Drink.beer;
    List<BeerStatsHelperModel> returnBeers =
        beerStatsHelper!.getBeerStatsHelperModelsWithMostBeers(
            beersForMatches!, currentSeason.id, enumDrink);
    if (returnBeers.isEmpty ||
        returnBeers[0].getNumberOfDrinksInMatches(
                Drink.beer, Participant.both, null) ==
            0) {
      return "Nelze naj??t z??pas s nejv??ce pivy v t??to sezon?? ${currentSeason.name}, proto??e si zat??m nikdo ????dn?? nedal!";
    } else if (returnBeers.length == 1) {
      return "Nejv??ce piv v aktu??ln?? sezon?? ${currentSeason.name} padlo v z??pase ${returnBeers[0].match!.toStringWithOpponentNameAndDate()} a padlo v n??m ${returnBeers[0].getNumberOfDrinksInMatches(Drink.beer, Participant.both, null)} piv";
    } else {
      String result =
          "O pozici z??pasu ve kter??m padlo nejv??ce piv v aktu??ln?? sezon?? ${currentSeason.name} se d??l?? ";
      for (int i = 0; i < returnBeers.length; i++) {
        result += returnBeers[i].match!.toStringWithOpponentNameAndDate();
        if (i == returnBeers.length - 1) {
          result +=
              " ve kter??ch padlo ${returnBeers[0].getNumberOfDrinksInMatches(Drink.beer, Participant.both, null)} piv.";
        } else if (i == returnBeers.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  /// @return vr??t?? text sezonu/sezony ve kter??ch padlo v historii nejv??ce piv, spole??n?? s po??tem a po??tem z??pas??
  String getSeasonWithMostBeers() {
    List<BeerSeasonHelper> returnSeasons = beerStatsHelper!
        .getSeasonWithMostBeers(beersForMatches!, seasons!, Drink.beer);
    if (returnSeasons.isEmpty || returnSeasons[0].beerNumber == 0) {
      return "Nelze naj??t sezonu s nejv??ce pivy, proto??e si zat??m nikdo pivo nedal!!!";
    } else if (returnSeasons.length == 1) {
      return "Nejv??ce piv se vypilo v sezon?? ${returnSeasons[0].seasonModel.name},kdy se v ${returnSeasons[0].matchNumber}. z??pasech vypilo ${returnSeasons[0].beerNumber} piv";
    } else {
      String result = "Nejv??ce pivy se m????ou chlubit  sezony ";
      for (int i = 0; i < returnSeasons.length; i++) {
        result +=
            "${returnSeasons[i].seasonModel.name} s ${returnSeasons[i].matchNumber}. z??pasy";
        if (i == returnSeasons.length - 1) {
          result += ", ve kter??ch padlo ${returnSeasons[0].beerNumber} piv.";
        } else if (i == returnSeasons.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  /// @return vr??t?? pr??m??rn?? po??et piv na v??echny ????astn??ky v??etn?? fans
  String getAverageNumberOfBeersInMatchForPlayersAndFans() {
    int beerNumber = 0;
    int playerNumber = 0;
    List<BeerStatsHelperModel> returnBeers = beersForMatches!;
    for (BeerStatsHelperModel beer in returnBeers) {
      beerNumber +=
          beer.getNumberOfDrinksInMatches(Drink.beer, Participant.both, null);
      playerNumber += beer.getNumberOfPlayersInMatch(Participant.both, null);
    }
    double average = 0;
    if(playerNumber != 0) {
      average = beerNumber / playerNumber;
    }
    return "Za celou historii pr??m??rn?? ka??d?? hr???? a fanou??ek Trusu, kter?? se z????astnil z??pasu, vypil $average piv za z??pas";
  }

  /// @return vr??t?? pr??m??rn?? po??et piv na hr????e
  String getAverageNumberOfBeersInMatchForPlayers() {
    int beerNumber = 0;
    int playerNumber = 0;
    List<BeerStatsHelperModel> returnBeers = beersForMatches!;
    for (BeerStatsHelperModel beer in returnBeers) {
      beerNumber += beer.getNumberOfDrinksInMatches(
          Drink.beer, Participant.player, players);
      playerNumber += beer.getNumberOfPlayersInMatch(Participant.player, players);
    }
    double average = 0;
    if(playerNumber != 0) {
      average = beerNumber / playerNumber;
    }
    return "Za celou historii pr??m??rn?? ka??d?? hr???? Trusu, kter?? se z????astnil z??pasu, vypil $average piv za z??pas";
  }

  /// @return vr??t?? pr??m??rn?? po??et piv na fanou??ka
  String getAverageNumberOfBeersInMatchForFan() {
    int beerNumber = 0;
    int playerNumber = 0;
    List<BeerStatsHelperModel> returnBeers = beersForMatches!;
    for (BeerStatsHelperModel beer in returnBeers) {
      beerNumber +=
          beer.getNumberOfDrinksInMatches(Drink.beer, Participant.fan, players);
      playerNumber += beer.getNumberOfPlayersInMatch(Participant.fan, players);
    }
    double average = 0;
    if(playerNumber != 0) {
      average = beerNumber / playerNumber;
    }
    return "Za celou historii pr??m??rn?? ka??d?? fanou??ek Trusu, kter?? se z????astnil z??pasu, vypil $average piv za z??pas";
  }

  /// @return vr??t?? pr??m??rn?? po??et piv na z??pas
  String getAverageNumberOfBeersInMatch() {
    int beerNumber = 0;
    List<BeerStatsHelperModel> returnBeers = beersForMatches!;
    for (BeerStatsHelperModel beer in returnBeers) {
      beerNumber +=
          beer.getNumberOfDrinksInMatches(Drink.beer, Participant.both, null);
    }
    double average = beerNumber / matches!.length;
    return "V naprosto pr??m??rn??m z??pasu Trusu se vypije $average piv";
  }

  /// @return Vrac?? dosud nejvy?????? pr??m??rn?? po??et vypit??ch piv v jednom z??pase
  String getMatchWithHighestAverageBeers() {
    List<BeerStatsHelperModel> returnMatches =
        beerStatsHelper!.getMatchWithHighestAverageBeers(
            beersForMatches!, null, true, Drink.beer);
    double average = 0;
    if (returnMatches.isEmpty) {
      return "Nelze naj??t z??pas s nejv??ce pr??m??rn??mi pivy, proto??e si zat??m nikdo pivo nedal!!!";
    } else {
      average = returnMatches[0]
              .getNumberOfDrinksInMatches(Drink.beer, Participant.both, null) /
          returnMatches[0].getNumberOfPlayersInMatch(Participant.both, null);
      if (returnMatches.length == 1) {
        return "Nejvy?????? pr??m??r po??tu vypit??ch piv v z??pase prob??hl na z??pase ${returnMatches[0].match!.toStringWithOpponentNameAndDate()}. "
            "Vypilo se ${returnMatches[0].getNumberOfDrinksInMatches(Drink.beer, Participant.both, null)} piv v ${returnMatches[0].getNumberOfPlayersInMatch(Participant.both, null)} lidech, co?? d??l?? pr??m??r $average na hr????e. "
            "Tak je??t?? jedno, a?? to p??ekon??me!";
      } else {
        String result =
            "Nejvy?????? pr??m??r po??tu vypit??ch piv v z??pase prob??hl na v z??pasech se ";
        for (int i = 0; i < returnMatches.length; i++) {
          result +=
              "soupe??em ${returnMatches[i].match!.toStringWithOpponentNameAndDate()} s celkov??m po??tem ${returnMatches[i].getNumberOfDrinksInMatches(Drink.beer, Participant.both, null)} "
              "piv v ${returnMatches[i].getNumberOfPlayersInMatch(Participant.both, null)} lidech";
          if (i == returnMatches.length - 1) {
            result += ".\n Celkov?? pr??m??r pro tyto z??pasy je $average piv.";
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

  /// @return Vrac?? dosud nejni?????? pr??m??rn?? po??et vypit??ch piv v jednom z??pase
  String getMatchWithLowestAverageBeers() {
    List<BeerStatsHelperModel> returnMatches =
        beerStatsHelper!.getMatchWithHighestAverageBeers(
            beersForMatches!, null, false, Drink.beer);
    double average = 0;
    if (returnMatches.isEmpty) {
      return "Nelze naj??t z??pas s nejm??n?? pr??m??rn??mi pivy, proto??e si zat??m nikdo pivo nedal!!!";
    } else {
      average = returnMatches[0]
              .getNumberOfDrinksInMatches(Drink.beer, Participant.both, null) /
          returnMatches[0].getNumberOfPlayersInMatch(Participant.both, null);
      if (returnMatches.length == 1) {
        return "Ostudn?? den Li??????ho Trusu, kdy byl poko??en rekord v nejni??????m pr??m??ru po??tu vypit??ch piv v z??pase prob??hl na z??pase ${returnMatches[0].match!.toStringWithOpponentNameAndDate()}. "
            "Vypilo se ${returnMatches[0].getNumberOfDrinksInMatches(Drink.beer, Participant.both, null)} piv v ${returnMatches[0].getNumberOfPlayersInMatch(Participant.both, null)} lidech, co?? d??l?? pr??m??r $average na hr????e. "
            "Vzpome??te si na to, a?? si budete objedn??vat dal???? rundu!";
      } else {
        String result =
            "Je a?? neuv????iteln??, ??e se takov?? potupa opakovala v??cekr??t, ov??em existuje v??ce z??pas?? s ostudn?? nejni??????m pr??m??rem vypit??ch piv. Stalo se tak se ";
        for (int i = 0; i < returnMatches.length; i++) {
          result +=
              "soupe??em ${returnMatches[i].match!.toStringWithOpponentNameAndDate()} s celkov??m po??tem ${returnMatches[i].getNumberOfDrinksInMatches(Drink.beer, Participant.both, null)} "
              "piv v ${returnMatches[i].getNumberOfPlayersInMatch(Participant.both, null)} lidech";
          if (i == returnMatches.length - 1) {
            result += ".\n Celkov?? pr??m??r pro tyto z??pasy je $average piv.";
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

  /// @return vr??t?? pr??m??rn?? piv v dom??c??m a venkovn??m z??pase
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
    double homeAverage = 0;
    if(homeMatches != 0) {
      homeAverage = homeBeerNumber / homeMatches;
    }
    double awayAverage = 0;
    if(matches!.length - homeMatches != 0) {
      awayAverage = awayBeerNumber / (matches!.length - homeMatches);
    }
    String response =
        "Pr??m??rn?? se na dom??c??m z??pase vypije $homeAverage piv, oproti venkovn??m z??pas??m, kde je pr??m??r $awayAverage piv na z??pas. ";
    if (homeAverage > awayAverage) {
      return "${response}Tak to m?? b??t, soupe?? mus?? prohr??vat o 2 piva u?? u Pr??honic!";
    }
    return "${response}Nen?? na??ase zm??nit dom??c?? hospodu?";
  }

  /// @return Vrac?? dosud nejvy?????? ????ast jednom z??pase spolu s podrobn??mi ??daji
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
      return "Nelze naj??t z??pas s nejvy?????? ????ast??, proto??e se zat??m ????dn?? nehr??l";
    } else if (returnMatches.length == 1) {
      return "Nejv??t???? ????ast Li??????ho Trusu prob??hla na z??pase ${returnMatches[0].match!.toStringWithOpponentNameAndDate()} kdy celkov?? po??et ????astn??k?? byl"
          " ${returnMatches[0].getNumberOfPlayersInMatch(Participant.fan, players)} fanou??k?? a ${returnMatches[0].getNumberOfPlayersInMatch(Participant.player, players)} hr??????, celkem tedy $matchAttendance lid??. "
          "Celkov?? se v tomto z??pase vypilo ${returnMatches[0].getNumberOfDrinksInMatches(Drink.beer, Participant.both, null)} piv a ${returnMatches[0].getNumberOfDrinksInMatches(Drink.liquor, Participant.both, null)} pan??k??";
    } else {
      String result = "Nejv??t???? ????ast Li??????ho Trusu prob??hla v z??pasech ";
      for (int i = 0; i < returnMatches.length; i++) {
        result +=
            "${returnMatches[i].match!.toStringWithOpponentNameAndDate()}, kdy celkov?? po??et ????astn??k?? byl ${returnMatches[i].getNumberOfPlayersInMatch(Participant.fan, players)} fanou??k?? a "
            "${returnMatches[i].getNumberOfPlayersInMatch(Participant.player, players)} hr?????? s po??tem ${returnMatches[0].getNumberOfDrinksInMatches(Drink.beer, Participant.both, null)}. vypit??ch piv a "
            "${returnMatches[0].getNumberOfDrinksInMatches(Drink.liquor, Participant.both, null)} pan??k??";
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

  /// @return Vrac?? dosud nejni?????? ????ast jednom z??pase spolu s podrobn??mi ??daji
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
      return "Nelze naj??t z??pas s nejni?????? ????ast??, proto??e se nejsp???? zat??m ????dn?? nehr??l";
    } else if (returnMatches.length == 1) {
      return "Nejni?????? ????ast Li??????ho Trusu prob??hla na z??pase ${returnMatches[0].match!.toStringWithOpponentNameAndDate()} kdy celkov?? po??et ????astn??k?? byl"
          " ${returnMatches[0].getNumberOfPlayersInMatch(Participant.fan, players)} fanou??k?? a ${returnMatches[0].getNumberOfPlayersInMatch(Participant.player, players)} hr??????, celkem tedy $matchAttendance lid??. "
          "Celkov?? se v tomto z??pase vypilo ${returnMatches[0].getNumberOfDrinksInMatches(Drink.beer, Participant.both, null)} piv a ${returnMatches[0].getNumberOfDrinksInMatches(Drink.liquor, Participant.both, null)} pan??k??";
    } else {
      String result = "Nejni?????? ????ast Li??????ho Trusu prob??hla v z??pasech ";
      for (int i = 0; i < returnMatches.length; i++) {
        result +=
            "${returnMatches[i].match!.toStringWithOpponentNameAndDate()}, kdy celkov?? po??et ????astn??k?? byl ${returnMatches[i].getNumberOfPlayersInMatch(Participant.fan, players)} fanou??k?? a "
            "${returnMatches[i].getNumberOfPlayersInMatch(Participant.player, players)} hr?????? s po??tem ${returnMatches[0].getNumberOfDrinksInMatches(Drink.beer, Participant.both, null)}. vypit??ch piv a "
            "${returnMatches[0].getNumberOfDrinksInMatches(Drink.liquor, Participant.both, null)} pan??k??";
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

  /// @return Vr??t?? text s hr????em nebo seznam hr??????, kte???? dostali za celou historii (v??echny z??pasy v db) nejv??ce pokut
  String getPlayerWithMostFines() {
    List<FineStatsHelperModel> returnFines =
        finesStatsHelper!.getFineStatsHelperModelsWithMostFines(
            finesForPlayers!, null, Fine.number);
    if (returnFines.isEmpty ||
        returnFines[0].getNumberOrAmountOfFines(Fine.number) == 0) {
      return "Nelze nal??zt hr????e s nejv??ce pokutami, proto??e je??t?? nikdo ????dnou nedostal??!!";
    } else if (returnFines.length == 1) {
      return "Nejv??ce pokut za historii dostal hr???? ${returnFines[0].player!.name}, kter?? dostal ${returnFines[0].getNumberOrAmountOfFines(Fine.number)} pokut. Za pokladn??ka d??kujeme!";
    } else {
      String result =
          "O pozici hr????e s nejv??t????m po??tem pokut v historii se d??l?? ";
      for (int i = 0; i < returnFines.length; i++) {
        result += returnFines[0].player!.name;
        if (i == returnFines.length - 1) {
          result +=
              " kte???? v??ichni do jednoho dostali ${returnFines[0].getNumberOrAmountOfFines(Fine.number)} pokut. N??dhern?? souboj, pros??me, je??t?? p??idejte!";
        } else if (i == returnFines.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  /// @return vr??t?? text se z??pasem nebo seznamem z??pas??, ve kter??m se za historii (z db) padlo nejv??ce pokut
  String getMatchWithMostFines() {
    List<FineStatsHelperModel> returnFines =
        finesStatsHelper!.getFineStatsHelperModelsWithMostFines(
            finesForMatches!, null, Fine.number);
    if (returnFines.isEmpty ||
        returnFines[0].getNumberOrAmountOfFines(Fine.number) == 0) {
      return "Nelze nal??zt z??pas s nejv??ce pokutami, proto??e je??t?? nikdo ????dnou nedostal??!!";
    } else if (returnFines.length == 1) {
      return "Nejv??ce pokut v historii padlo v z??pase ${returnFines[0].match!.toStringWithOpponentNameAndDate()}, a ud??lilo se v n??m ${returnFines[0].getNumberOrAmountOfFines(Fine.number)} pokut. Za pokladn??ka d??kujeme!";
    } else {
      String result =
          "O pozici z??pasu ve kter??m padlo nejv??ce pokut se d??l?? z??pas ";
      for (int i = 0; i < returnFines.length; i++) {
        result += returnFines[0].match!.toStringWithOpponentNameAndDate();
        if (i == returnFines.length - 1) {
          result +=
              " ve kter??ch padlo ${returnFines[0].getNumberOrAmountOfFines(Fine.number)} pokut.";
        } else if (i == returnFines.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  /// @return Vr??t?? text s hr????em nebo seznam hr??????, kte???? zaplatili za celou historii (v??echny z??pasy v db) nejv??ce na pokut??ch
  String getPlayerWithMostFinesAmount() {
    List<FineStatsHelperModel> returnFines =
        finesStatsHelper!.getFineStatsHelperModelsWithMostFines(
            finesForPlayers!, null, Fine.amount);
    if (returnFines.isEmpty ||
        returnFines[0].getNumberOrAmountOfFines(Fine.amount) == 0) {
      return "Nelze nal??zt hr????e, co nejv??c zaplatil na pokut??ch, proto??e je??t?? nikdo ????dnou nedostal??!!";
    } else if (returnFines.length == 1) {
      return "Nejv??ce pokuty st??ly hr????e ${returnFines[0].player!.name}, kter?? celkem zac??loval ${returnFines[0].getNumberOrAmountOfFines(Fine.amount)} K??. Nezapome??, je to ned??ln?? sou????st tr??ningov??ho procesu!";
    } else {
      String result =
          "O pozici hr????e co nejv??c zac??lovali na pokut??ch se d??l?? ";
      for (int i = 0; i < returnFines.length; i++) {
        result += returnFines[0].player!.name;
        if (i == returnFines.length - 1) {
          result +=
              " kte???? v??ichni do jednoho zaplatili ${returnFines[0].getNumberOrAmountOfFines(Fine.amount)} K??. D??ky kluci, zvy??uje to autoritu tren??ra!";
        } else if (i == returnFines.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  /// @return vr??t?? text se z??pasem nebo seznamem z??pas??, ve kter??m se za historii (z db) nejv??ce vyd??lalo na pokut??ch
  String getMatchWithMostFinesAmount() {
    List<FineStatsHelperModel> returnFines =
        finesStatsHelper!.getFineStatsHelperModelsWithMostFines(
            finesForMatches!, null, Fine.amount);
    if (returnFines.isEmpty ||
        returnFines[0].getNumberOrAmountOfFines(Fine.amount) == 0) {
      return "Nelze nal??zt z??pas, kde se nejv??c c??lovalo za pokuty, proto??e je??t?? nikdo ????dnou nedostal??!!";
    } else if (returnFines.length == 1) {
      return "Nejv??t???? objem pen??z v pokut??ch p??inesl z??pas ${returnFines[0].match!.toStringWithOpponentNameAndDate()}, a vybralo se v n??m ${returnFines[0].getNumberOrAmountOfFines(Fine.amount)} K??";
    } else {
      String result =
          "O pozici z??pasu ve kter??m se klubov?? pokladna nejv??ce nafoukla se d??l?? z??pas";
      for (int i = 0; i < returnFines.length; i++) {
        result += returnFines[0].match!.toStringWithOpponentNameAndDate();
        if (i == returnFines.length - 1) {
          result +=
              " ve kter??ch se vybralo  ${returnFines[0].getNumberOrAmountOfFines(Fine.amount)} K??.";
        } else if (i == returnFines.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  /// @return vr??t?? po??et pokut v aktu??ln?? sezon?? dle data
  String getNumberOfFinesInCurrentSeason() {
    int fineNumber = 0;
    List<FineStatsHelperModel> returnFines = finesForMatches!;
    for (FineStatsHelperModel fine in returnFines) {
      if (fine.match!.seasonId == currentSeason.id) {
        fineNumber += fine.getNumberOrAmountOfFines(Fine.number);
      }
    }
    return "V aktu??ln?? sezon?? ${currentSeason.name} se rozdalo ji?? $fineNumber pokut";
  }

  /// @return vr??t?? vybranou ????stku na pokut??ch v aktu??ln?? sezon?? dle data
  String getAmountOfFinesInCurrentSeason() {
    int fineNumber = 0;
    List<FineStatsHelperModel> returnFines = finesForMatches!;
    for (FineStatsHelperModel fine in returnFines) {
      if (fine.match!.seasonId == currentSeason.id) {
        fineNumber += fine.getNumberOrAmountOfFines(Fine.amount);
      }
    }
    return "V aktu??ln?? sezon?? ${currentSeason.name} se na pokut??ch vybralo ji?? $fineNumber K??";
  }

  /// @return vr??t?? text se z??pasem nebo listem z??pas?? ve kter??ch se tuto sezonu rozdalo nejv??ce pokut
  String getMatchWithMostFinesInCurrentSeason() {
    Fine enumFine = Fine.number;
    List<FineStatsHelperModel> returnFines =
        finesStatsHelper!.getFineStatsHelperModelsWithMostFines(
            finesForMatches!, currentSeason.id, enumFine);
    if (returnFines.isEmpty ||
        returnFines[0].getNumberOrAmountOfFines(enumFine) == 0) {
      return "Nelze naj??t z??pas s nejv??ce pokutami odehran?? v t??to sezon??  ${currentSeason.name}, proto??e se zat??m ????dn?? pokuta neud??lila!";
    } else if (returnFines.length == 1) {
      return "Nejv??ce pokut v aktu??ln?? sezon?? ${currentSeason.name} se rozdalo v z??pase ${returnFines[0].match!.toStringWithOpponentNameAndDate()} a padlo v n??m ${returnFines[0].getNumberOrAmountOfFines(enumFine)} pokut";
    } else {
      String result =
          "O pozici z??pasu ve kter??m se rozdalo nejv??ce pokut v aktu??ln?? sezon?? ${currentSeason.name} se d??l?? ";
      for (int i = 0; i < returnFines.length; i++) {
        result += returnFines[i].match!.toStringWithOpponentNameAndDate();
        if (i == returnFines.length - 1) {
          result +=
              " ve kter??ch padlo ${returnFines[0].getNumberOrAmountOfFines(enumFine)} pokut.";
        } else if (i == returnFines.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  /// @return vr??t?? text se z??pasem nebo listem z??pas?? ve kter??ch se tuto sezonu nejv??ce vyd??lalo na pokut??ch
  String getMatchWithMostFinesAmountInCurrentSeason() {
    Fine enumFine = Fine.amount;
    List<FineStatsHelperModel> returnFines =
        finesStatsHelper!.getFineStatsHelperModelsWithMostFines(
            finesForMatches!, currentSeason.id, enumFine);
    if (returnFines.isEmpty ||
        returnFines[0].getNumberOrAmountOfFines(enumFine) == 0) {
      return "Nelze naj??t z??pas, kde se v t??to sezon?? ${currentSeason.name} nejv??ce c??lovalo za pokuty, proto??e se zat??m ????dn?? pokuta neud??lila!";
    } else if (returnFines.length == 1) {
      return "Nejv??t???? objem pen??z v aktu??ln?? sezon?? ${currentSeason.name} p??inesl z??pas ${returnFines[0].match!.toStringWithOpponentNameAndDate()} a vybralo se v n??m ${returnFines[0].getNumberOrAmountOfFines(enumFine)} K??";
    } else {
      String result =
          "O pozici z??pasu, kter?? p??inesl klubov?? pokladn?? nejv??ce pen??z z pokut v aktu??ln?? sezon?? ${currentSeason.name} se d??l?? ";
      for (int i = 0; i < returnFines.length; i++) {
        result += returnFines[i].match!.toStringWithOpponentNameAndDate();
        if (i == returnFines.length - 1) {
          result +=
              " ve kter??ch se vybralo ${returnFines[0].getNumberOrAmountOfFines(enumFine)} K??.";
        } else if (i == returnFines.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  /// @return vr??t?? text sezonu/sezony ve kter??ch padlo v historii nejv??ce pokut, spole??n?? s po??tem a po??tem z??pas??
  String getSeasonWithMostFines() {
    Fine enumFine = Fine.number;
    List<FineSeasonHelper> returnSeasons = finesStatsHelper!
        .getSeasonWithMostFines(finesForMatches!, seasons!, enumFine);
    if (returnSeasons.isEmpty ||
        returnSeasons[0].getNumberOrAmount(enumFine) == 0) {
      return "Nelze naj??t sezonu s nejv??ce pokutama, proto??e se zat??m ????dn?? pokuta nerozdala!";
    } else if (returnSeasons.length == 1) {
      return "Nejv??ce pokut se rozdalo v sezon?? ${returnSeasons[0].seasonModel.name}, kdy v ${returnSeasons[0].matchNumber}. z??pasech padlo ${returnSeasons[0].getNumberOrAmount(enumFine)} pokut";
    } else {
      String result = "Nejv??ce pokutami se m????ou chlubit sezony ";
      for (int i = 0; i < returnSeasons.length; i++) {
        result +=
            "${returnSeasons[i].seasonModel.name} s ${returnSeasons[i].matchNumber}. z??pasy";
        if (i == returnSeasons.length - 1) {
          result +=
              ", ve kter??ch padlo ${returnSeasons[0].getNumberOrAmount(enumFine)} pokut.";
        } else if (i == returnSeasons.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  /// @return vr??t?? text sezonu/sezony ve kter??ch se vybralo v historii nejv??ce za pokuty, spole??n?? s po??tem z??pas??
  String getSeasonWithMostFinesAmount() {
    Fine enumFine = Fine.amount;
    List<FineSeasonHelper> returnSeasons = finesStatsHelper!
        .getSeasonWithMostFines(finesForMatches!, seasons!, enumFine);
    if (returnSeasons.isEmpty ||
        returnSeasons[0].getNumberOrAmount(enumFine) == 0) {
      return "Nelze naj??t sezonu kdy se vybralo nejv??c za pokuty, proto??e se zat??m ????dn?? pokuta nerozdala!";
    } else if (returnSeasons.length == 1) {
      return "Nejv??c pen??z na pokut??ch se vybralo v sezon?? ${returnSeasons[0].seasonModel.name}, kdy v ${returnSeasons[0].matchNumber} z??pasech pokladna shr??bla ${returnSeasons[0].getNumberOrAmount(enumFine)} K??.";
    } else {
      String result =
          "Nejv??t????m objemem vybran??ch pen??z se m????ou chlubit sezony ";
      for (int i = 0; i < returnSeasons.length; i++) {
        result +=
            "${returnSeasons[i].seasonModel.name} s ${returnSeasons[i].matchNumber}. z??pasy";
        if (i == returnSeasons.length - 1) {
          result +=
              ", ve kter??ch se zaplatilo ${returnSeasons[0].getNumberOrAmount(enumFine)} K??.";
        } else if (i == returnSeasons.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  /// @return vr??t?? pr??m??rn?? po??et pokut na hr????e
  String getAverageNumberOfFinesInMatchForPlayers() {
    int finesNumber = 0;
    List<FineStatsHelperModel> returnFines = finesForMatches!;
    for (FineStatsHelperModel fine in returnFines) {
      finesNumber += fine.getNumberOrAmountOfFines(Fine.number);
    }
    double average = finesNumber / (finesStatsHelper!.getNumberOfPlayers(Participant.player, players!)*matches!.length);
    return "V historii v pr??m??ru p??ipad?? $average pokut na hr????e pro ka??d?? z??pas";
  }

  /// @return vr??t?? pr??m??rn?? c??lov??n?? pokut na hr????e
  String getAverageNumberOfFinesAmountInMatchForPlayers() {
    int finesNumber = 0;
    List<FineStatsHelperModel> returnFines = finesForMatches!;
    for (FineStatsHelperModel fine in returnFines) {
      finesNumber += fine.getNumberOrAmountOfFines(Fine.amount);
    }
    double average = finesNumber / (finesStatsHelper!.getNumberOfPlayers(Participant.player, players!)*matches!.length);
    return "V historii v pr??m??ru p??ipad?? $average K?? zaplaceno na pokut??ch na hr????e pro ka??d?? z??pas";
  }

  /// @return vr??t?? pr??m??rn?? po??et pokut na z??pas
  String getAverageNumberOfFinesInMatch() {
    int finesNumber = 0;
    List<FineStatsHelperModel> returnFines = finesForMatches!;
    for (FineStatsHelperModel fine in returnFines) {
      finesNumber += fine.getNumberOrAmountOfFines(Fine.number);
    }
    double average = finesNumber / matches!.length;
    return "V naprosto pr??m??rn??m z??pasu Trusu se ud??l?? $average pokut";
  }

  /// @return vr??t?? pr??m??rn?? po??et vybranejch pen??z v z??pase
  String getAverageNumberOfFinesAmountInMatch() {
    int finesNumber = 0;
    List<FineStatsHelperModel> returnFines = finesForMatches!;
    for (FineStatsHelperModel fine in returnFines) {
      finesNumber += fine.getNumberOrAmountOfFines(Fine.amount);
    }
    double average = finesNumber / matches!.length;
    return "V naprosto pr??m??rn??m z??pasu Trusu se vybere $average K?? na pokut??ch";
  }

  /// @return Vr??t?? text s hr????em nebo seznam hr??????, kte???? vypili za celou historii (v??echny z??pasy v db) nejv??ce pan??k??
  String getPlayerWithMostLiquors() {
    Drink enumDrink = Drink.liquor;
    List<BeerStatsHelperModel> returnBeers =
        beerStatsHelper!.getBeerStatsHelperModelsWithMostBeers(
            beersForPlayers!, null, enumDrink);
    if (returnBeers.isEmpty ||
        returnBeers[0].getNumberOfDrinksInMatches(
                enumDrink, Participant.both, null) ==
            0) {
      return "Zat??m se hled?? ??lov??k, co by si dal alespo?? jednoho pan??ka na z??pase Trusu. V??herce ??ek?? v????n?? sl??va zv????n??n?? p????mo v t??to zaj??mavosti do t?? doby, ne?? si n??kdo d?? pan??ky 2";
    } else if (returnBeers.length == 1) {
      return "Nejv??ce pan??k?? za historii si dal ${returnBeers[0].player!.name} kter?? vypil ${returnBeers[0].getNumberOfDrinksInMatches(enumDrink, Participant.both, null)} fr??an??. Na v??konu to v??bec nen?? poznat, gratulujeme!";
    } else {
      String result =
          "By?? to zn?? jako scifi, tak t??mto hr??????m pravd??podobn?? chutn?? tvrd?? v??ce ne?? pivo. D??l?? se toti?? o pozici nejv??t????ho p????e co se t????e pan????k??. Jedn?? se o ";
      for (int i = 0; i < returnBeers.length; i++) {
        result += returnBeers[i].player!.name;
        if (i == returnBeers.length - 1) {
          result +=
              " kte???? v??ichni do jednoho vypili ${returnBeers[0].getNumberOfDrinksInMatches(enumDrink, Participant.both, null)} fr??an??. Boj, boj, boj!";
        } else if (i == returnBeers.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  /// @return vr??t?? text se z??pasem nebo seznamem z??pas??, ve kter??m se za historii (z db) vypilo nejv??ce pan??k??
  String getMatchWithMostLiquors() {
    Drink enumDrink = Drink.liquor;
    List<BeerStatsHelperModel> returnBeers =
        beerStatsHelper!.getBeerStatsHelperModelsWithMostBeers(
            beersForMatches!, null, enumDrink);
    if (returnBeers.isEmpty ||
        returnBeers[0].getNumberOfDrinksInMatches(
                enumDrink, Participant.both, null) ==
            0) {
      return "Nelze naj??t z??pas s nejv??ce pan??ky, proto??e si zat??m nikdo ????dn?? nedal! Jedna ????opi??ka nikdy nikoho nezabila, tak se neost??chejte p??nov??!";
    } else if (returnBeers.length == 1) {
      return "Nejv??ce pan??k?? za historii padlo v z??pase ${returnBeers[0].match!.toStringWithOpponentNameAndDate()} s celkov??m po??tem ${returnBeers[0].getNumberOfDrinksInMatches(enumDrink, Participant.both, null)}. fr??an??";
    } else {
      String result = "O pozici z??pasu ve kter??m padlo nejv??ce pan??k?? se d??l?? ";
      for (int i = 0; i < returnBeers.length; i++) {
        result += returnBeers[i].match!.toStringWithOpponentNameAndDate();
        if (i == returnBeers.length - 1) {
          result +=
              ". V ka??d??m z t??chto z??pas?? padlo ${returnBeers[0].getNumberOfDrinksInMatches(enumDrink, Participant.both, null)} fr??an??.";
        } else if (i == returnBeers.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  /// @return vr??t?? po??et pan??k?? v aktu??ln?? sezon?? dle data
  String getNumberOfLiquorsInCurrentSeason() {
    int liquorNumber = 0;
    List<BeerStatsHelperModel> returnBeers = beersForMatches!;
    for (BeerStatsHelperModel beer in returnBeers) {
      if (beer.match!.seasonId == currentSeason.id) {
        liquorNumber += beer.getNumberOfDrinksInMatches(
            Drink.liquor, Participant.both, null);
      }
    }
    return "V aktu??ln?? sezon?? ${currentSeason.name} se vypilo $liquorNumber pan??k??";
  }

  /// @return vr??t?? text se z??pasem nebo listem z??pas?? ve kter??ch se tuto sezonu vypilo nejv??ce pan??k??
  String getMatchWithMostLiquorsInCurrentSeason() {
    Drink enumDrink = Drink.liquor;
    List<BeerStatsHelperModel> returnBeers =
        beerStatsHelper!.getBeerStatsHelperModelsWithMostBeers(
            beersForMatches!, currentSeason.id, enumDrink);
    if (returnBeers.isEmpty ||
        returnBeers[0].getNumberOfDrinksInMatches(
                enumDrink, Participant.both, null) ==
            0) {
      return "Nelze naj??t z??pas s nejv??ce pan??ky odehran?? v t??to sezon?? ${currentSeason.name}, proto??e si zat??m nikdo ????dn?? nedal! Aspo?? jeden Li?????? Trus denn?? je prosp????n?? pro zdrav??, to v??m potvrd?? ka??d?? doktor";
    } else if (returnBeers.length == 1) {
      return "Nejv??ce pan??k?? v aktu??ln?? sezon?? ${currentSeason.name} padlo v z??pase ${returnBeers[0].match!.toStringWithOpponentNameAndDate()} kdy prob??hlo ${returnBeers[0].getNumberOfDrinksInMatches(enumDrink, Participant.both, null)} ko??alek";
    } else {
      String result =
          "O pozici z??pasu ve kter??m padlo nejv??ce ko??alek v aktu??ln?? sezon?? ${currentSeason.name} se d??l?? ";
      for (int i = 0; i < returnBeers.length; i++) {
        result += returnBeers[i].match!.toStringWithOpponentNameAndDate();
        if (i == returnBeers.length - 1) {
          result +=
              " kdy ka??d?? z t??chto z??pas?? obsahoval ??ctihodn??ch ${returnBeers[0].getNumberOfDrinksInMatches(enumDrink, Participant.both, null)} pan????k?? tvrd??ho.";
        } else if (i == returnBeers.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  /// @return vr??t?? text sezonu/sezony ve kter??ch padlo v historii nejv??ce pan??k??, spole??n?? s po??tem a po??tem z??pas??
  String getSeasonWithMostLiquors() {
    Drink enumDrink = Drink.liquor;
    List<BeerSeasonHelper> returnSeasons = beerStatsHelper!
        .getSeasonWithMostBeers(beersForMatches!, seasons!, enumDrink);
    if (returnSeasons.isEmpty || returnSeasons[0].liquorNumber == 0) {
      return "Sezona s nejv??ce pan??ky je... ????dn??! Zat??m si nikdo nedal ani jeden Li?????? Trus!!";
    } else if (returnSeasons.length == 1) {
      return "Nejv??ce pan??k?? se vypilo v sezon?? ${returnSeasons[0].seasonModel.name},kdy se v ${returnSeasons[0].matchNumber}. z??pasech vypilo ${returnSeasons[0].liquorNumber} tvrd??ho";
    } else {
      String result = "Nejv??ce pan??ky se m????ou chlubit  sezony ";
      for (int i = 0; i < returnSeasons.length; i++) {
        result +=
            "${returnSeasons[i].seasonModel.name} s ${returnSeasons[i].matchNumber}. z??pasy";
        if (i == returnSeasons.length - 1) {
          result +=
              ", ve kter??ch padlo ${returnSeasons[0].liquorNumber} tvrd??ho.";
        } else if (i == returnSeasons.length - 2) {
          result += " a ";
        } else {
          result += ", ";
        }
      }
      return result;
    }
  }

  /// @return vr??t?? pr??m??rn?? po??et pan??k?? na v??echny ????astn??ky v??etn?? fans
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
    return "Za celou historii pr??m??rn?? ka??d?? hr???? a fanou??ek Trusu vypil $average pan??k?? za z??pas";
  }

  /// @return vr??t?? pr??m??rn?? po??et pan??k?? na hr????e
  String getAverageNumberOfLiquorsInMatchForPlayers() {
    int liquorNumber = 0;
    int playerNumber = 0;
    List<BeerStatsHelperModel> returnBeers = beersForMatches!;
    for (BeerStatsHelperModel beer in returnBeers) {
      liquorNumber += beer.getNumberOfDrinksInMatches(
          Drink.liquor, Participant.player, players);
      playerNumber += beer.getNumberOfPlayersInMatch(Participant.player, players);
    }
    double average = liquorNumber / playerNumber;
    return "Za celou historii pr??m??rn?? ka??d?? hr???? Trusu vypil $average pan??k?? za z??pas";
  }

  /// @return vr??t?? pr??m??rn?? po??et pan??k?? na fanou??ka
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
    return "Za celou historii pr??m??rn?? ka??d?? fanou??ek Trusu vypil $average pan??k?? za z??pas";
  }

  /// @return vr??t?? pr??m??rn?? po??et pan??k?? na z??pas
  String getAverageNumberOfLiquorsInMatch() {
    int liquorNumber = 0;
    List<BeerStatsHelperModel> returnBeers = beersForMatches!;
    for (BeerStatsHelperModel beer in returnBeers) {
      liquorNumber += beer.getNumberOfDrinksInMatches(
          Drink.liquor, Participant.both, null);
    }
    double average = liquorNumber / matches!.length;
    return "V naprosto pr??m??rn??m z??pasu Trusu se vypije $average pan??k??";
  }

  /// @return Vrac?? dosud nejvy?????? pr??m??rn?? po??et vypit??ch pan??k?? v jednom z??pase
  String getMatchWithHighestAverageLiquors() {
    Drink enumDrink = Drink.liquor;
    List<BeerStatsHelperModel> returnMatches =
        beerStatsHelper!.getMatchWithHighestAverageBeers(
            beersForMatches!, null, true, enumDrink);
    double average = 0;
    if (returnMatches.isEmpty) {
      return "Nejvy?????? pr??m??r vypit??ch pan??k?? na z??pase Trusu je 0!! Nechce n??kdo vym??nit pivko za lahodn?? Li?????? Trus?!?";
    } else {
      average = returnMatches[0]
              .getNumberOfDrinksInMatches(enumDrink, Participant.both, null) /
          returnMatches[0].getNumberOfPlayersInMatch(Participant.both, null);
      if (returnMatches.length == 1) {
        return "Nejvy?????? pr??m??r po??tu vypit??ch pan??k?? v z??pase prob??hl na z??pase ${returnMatches[0].match!.toStringWithOpponentNameAndDate()}. "
            "Vypilo se ${returnMatches[0].getNumberOfDrinksInMatches(enumDrink, Participant.both, null)} tvrd??ho v ${returnMatches[0].getNumberOfPlayersInMatch(Participant.both, null)} lidech, co?? d??l?? pr??m??r $average na hr????e. Copak se asi tehdy slavilo?";
      } else {
        String result =
            "Nejvy?????? pr??m??r po??tu vypit??ch pan??k?? v z??pase prob??hl se ";
        for (int i = 0; i < returnMatches.length; i++) {
          result +=
              "soupe??em ${returnMatches[i].match!.toStringWithOpponentNameAndDate()} s celkov??m po??tem ${returnMatches[i].getNumberOfDrinksInMatches(enumDrink, Participant.both, null)} "
              "tvrd??ho v ${returnMatches[i].getNumberOfPlayersInMatch(Participant.both, null)} lidech";
          if (i == returnMatches.length - 1) {
            result +=
                ".\n Celkov?? pr??m??r pro tyto z??pasy je $average piv. Copak se asi tehdy slavilo?";
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

  /// @return Vrac?? dosud nejni?????? pr??m??rn?? po??et vypit??ch pan??k?? v jednom z??pase
  String getMatchWithLowestAverageLiquors() {
    Drink enumDrink = Drink.liquor;
    List<BeerStatsHelperModel> returnMatches =
        beerStatsHelper!.getMatchWithHighestAverageBeers(
            beersForMatches!, null, false, enumDrink);
    double average = 0;
    if (returnMatches.isEmpty) {
      return "Zat??m v ????dn??m z??pase Trusu nepadl jedin?? pan??k. To nikdo nesly??el o blahod??rn??m drinku jm??nem Li?????? Trus?";
    } else {
      average = returnMatches[0]
              .getNumberOfDrinksInMatches(enumDrink, Participant.both, null) /
          returnMatches[0].getNumberOfPlayersInMatch(Participant.both, null);
      if (returnMatches.length == 1) {
        return "M????ete sami posoudit, jak?? ostuda se stala v z??pase ${returnMatches[0].match!.toStringWithOpponentNameAndDate()}, kdz se historicky vypil nejmen???? pr??m??r pan??k??."
            "Vypilo se ${returnMatches[0].getNumberOfDrinksInMatches(enumDrink, Participant.both, null)} ko??alek v ${returnMatches[0].getNumberOfPlayersInMatch(Participant.both, null)} lidech, co?? d??l?? pr??m??r $average na hr????e. "
            "Mo??n?? to m????e zachr??nit po??et piv v z??pase, kter?? byl ${returnMatches[0].getNumberOfDrinksInMatches(Drink.beer, Participant.both, null)}. Vzpome??te si na to, a?? si budete objedn??vat dal???? rundu, ide??ln?? slavn?? Li?????? Trus!";
      } else {
        String result =
            "Bohu??el je zn??t, ??e Trus je t??m zam????en?? sp????e na piva. Jinak by ani nebylo mo??n??, aby existovalo v??ce z??pas?? s nejni??????m pr??m??rem vypit??ch pan??k??. Stalo se tak se ";
        for (int i = 0; i < returnMatches.length; i++) {
          result +=
              "soupe??em ${returnMatches[i].match!.toStringWithOpponentNameAndDate()} s celkov??m po??tem ${returnMatches[i].getNumberOfDrinksInMatches(enumDrink, Participant.both, null)} "
              "tvrd??ho v ${returnMatches[i].getNumberOfPlayersInMatch(Participant.both, null)} lidech";
          if (i == returnMatches.length - 1) {
            result += ".\n Celkov?? pr??m??r pro tyto z??pasy je $average ko??alek.";
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
  /// @return vr??t?? pr??m??rn?? tvrdejch v dom??c??m a venkovn??m z??pase
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
    double homeAverage = 0;
    if(homeMatches != 0) {
      homeAverage = homeLiquorNumber / homeMatches;
    }
    double awayAverage = awayLiquorNumber / (matches!.length - homeMatches);
    String response =
        "Pr??m??rn?? se na dom??c??m z??pase vypije $homeAverage pan??k??, oproti venkovn??m z??pas??m, kde je pr??m??r $awayAverage pan??k?? na z??pas. ";
    if (homeAverage > awayAverage) {
      return "${response}Zd?? se, ??e p??i dom??c??m z??pase se chlast?? daleko l??p ne?? venku!";
    }
    return "${response}Ve ??kolce snad nalejv?? kucha?? i pan??ky?";
  }

  String getMatchWithBirthday() {
    List<MatchModel> matchesWithBirthday = [];
    List<PlayerModel> playersWithBirthday = [];
    for (MatchModel match in matches!) {
      for (PlayerModel player in players!) {
        if (match.date.isSameDate(player.birthday)) {
          matchesWithBirthday.add(match);
          playersWithBirthday.add(player);
        }
      }
    }
    //pokud se nikdo nena??el v prvn?? iteraci, tedy ????dn?? narozky se nekrejou s datem z??pasu
    if (matchesWithBirthday.isEmpty) {
      return "Zat??m se nena??el z??pas kde by n??jak?? hr???? zap??jel narozky. U?? se v??ichni t??????me";
    } else {
      //nejprve zji????ujeme, zda hr????, kter?? m??l narozky v den z??pasu, skute??n?? byl na z??pasu p????tomen
      List<MatchModel> returnMatches = [];
      List<PlayerModel> returnPlayers = [];
      for (int i = 0; i < matchesWithBirthday.length; i++) {
          if (matchesWithBirthday[i].playerIdList.contains(playersWithBirthday[i].id)) {
            returnPlayers.add(playersWithBirthday[i]);
            returnMatches.add(matchesWithBirthday[i]);
          }
      }
      //Pokud nikdo s narozkama nebyl na z??pase trusu, tak ud??l??me st??nu hamby
      List<BeerModel> returnBeers =
          beerStatsHelper!.getNumberOfBeersInMatchForPlayer(
              returnPlayers, returnMatches, beers!);
      if (returnMatches.isEmpty) {
        String result =
            "Zat??m se nena??el z??pas kde by n??jak?? hr???? zap??jel narozky. U?? se v??ichni t??????me. Do t?? doby zde m??me ze?? hamby pro hr????e, kte???? rad??ji sv?? narozeniny zap??jeli jinde ne?? na Trusu. Hamba! : ";
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
      //Pokud byl jenom jeden takov?? ????astlivec
      else if (returnMatches.length == 1) {
        return "Zat??m jedin?? z??pas, kdy n??kdo z Trusu zap??jel narozky byl ${returnMatches[0].toStringWithOpponentNameAndDate()} kdy slavil ${returnPlayers[0].name}, "
            "kter?? vypil ${returnBeers[0].beerNumber} piv a ${returnBeers[0].liquorNumber} pan??k??.";
      }
      //pokud jich bylo v??c
      else {
        String result =
            "Velk?? spole??ensk?? ud??lost v podob?? oslavy narozek se konala na z??pasech ";
        for (int i = 0; i < returnMatches.length; i++) {
          result +=
              "${returnMatches[i].toStringWithOpponentNameAndDate()}, kdy slavil narozky ${returnPlayers[i].name}, kter?? vypil ${returnBeers[i].beerNumber} piv a ${returnBeers[i].liquorNumber} pan??k??";
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

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month
        && day == other.day;
  }
}

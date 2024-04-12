import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/interfaces/json_and_http_converter.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';
import 'package:trus_app/models/api/pkfl/pkfl_individual_stats_api_model.dart';
import 'package:trus_app/models/api/pkfl/pkfl_opponent_api_model.dart';
import 'package:trus_app/models/api/pkfl/pkfl_referee_api_model.dart';
import 'package:trus_app/models/api/pkfl/pkfl_season_api_model.dart';
import 'package:trus_app/models/api/pkfl/pkfl_stadium_api_model.dart';
import '../../../common/utils/calendar.dart';

class PkflMatchApiModel implements JsonAndHttpConverter, ModelToString {
  int id;
  final DateTime date;
  PkflOpponentApiModel? opponent;
  int round;
  String league;
  PkflStadiumApiModel? stadium;
  PkflRefereeApiModel? referee;
  PkflSeasonApiModel season;
  int? trusGoalNumber;
  int? opponentGoalNumber;
  bool homeMatch;
  String urlResult;
  String refereeComment;
  bool alreadyPlayed;
  List<PkflIndividualStatsApiModel> playerList;
  List<int> matchIdList;

  PkflMatchApiModel({required this.id,
    required this.date,
    this.opponent,
    required this.round,
    required this.league,
    this.stadium,
    this.referee,
    required this.season,
    this.trusGoalNumber,
    this.opponentGoalNumber,
    required this.homeMatch,
    required this.urlResult,
    required this.refereeComment,
    required this.alreadyPlayed,
    required this.playerList,
    required this.matchIdList});

  PkflMatchApiModel.dummy()
      : id = 0,
        league = "",
        matchIdList = [],
        playerList = [],
        alreadyPlayed = false,
        refereeComment = "",
        round = 0,
        season = PkflSeasonApiModel(name: "", url: "", id: 0),
        urlResult = "",
        homeMatch = false,
        date = DateTime.fromMicrosecondsSinceEpoch(0);

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "opponent": opponent,
      "date": formatDateForJson(date),
      "round": round,
      "league": league,
      "stadium": stadium,
      "referee": referee,
      "season": season,
      "trusGoalNumber": trusGoalNumber,
      "opponentGoalNumber": opponentGoalNumber,
      "homeMatch": homeMatch,
      "urlResult": urlResult,
      "refereeComment": refereeComment,
      "alreadyPlayed": alreadyPlayed,
      "playerList": playerList,
      "matchIdList": matchIdList,
    };
  }

  factory PkflMatchApiModel.fromJson(Map<String, dynamic> json) {
    return PkflMatchApiModel(
      id: json["id"],
      date: DateTime.parse(json['date']),
      opponent: json["opponent"] != null ? PkflOpponentApiModel.fromJson(
          json["opponent"]) : null,
      round: json["round"],
      league: json["league"],
      stadium: json["stadium"] != null ? PkflStadiumApiModel.fromJson(
          json["stadium"]) : null,
      referee: json["referee"] != null ? PkflRefereeApiModel.fromJson(
          json["referee"]) : null,
      season: PkflSeasonApiModel.fromJson(json["season"]),
      trusGoalNumber: json["trusGoalNumber"],
      opponentGoalNumber: json["opponentGoalNumber"],
      homeMatch: json["homeMatch"],
      urlResult: json["urlResult"],
      refereeComment: json["refereeComment"],
      alreadyPlayed: json["alreadyPlayed"],
      playerList: List<PkflIndividualStatsApiModel>.from(
          (json['playerList'] as List<dynamic>).map((match) =>
              PkflIndividualStatsApiModel.fromJson(match))),
      matchIdList: List<int>.from((json['matchIdList'])),
    );
  }

  String toStringNameWithOpponent() {
    if (homeMatch) {
      return "Liščí trus - ${opponentToString()}";
    }
    return "${opponentToString()} - Liščí Trus";
  }

  String toStringForNextMatchHomeScreen() {
    return "${toStringNameWithOpponent()}, v čase ${formatDateForFrontend(
        date)}. Jedná se o $round. kolo a bude se hrát ${stadiumToString()}. Pískat bude ${refereeToString()}";
  }

  String toStringForLastMatchHomeScreen() {
    return "${toStringNameWithOpponent()}, v čase ${formatDateForFrontend(
        date)}. Jednalo se o $round. kolo a hrálo se ${stadiumToString()} ${resultToString()}. Rozhodčí byl ${refereeToString()}";
  }

  String toStringForCardDetail() {
    return "${toStringNameWithOpponent()} hraném ${formatDateForFrontend(
        date)} ${stadiumToString()} s konečným výsledkem ${resultToString()}. Kartu udělalil ${refereeToString()}";
  }

  String resultToString() {
    if (trusGoalNumber == null || opponentGoalNumber == null) {
      return "s neznámým výsledkem";
    }
    if (homeMatch) {
      return "s výsledkem $trusGoalNumber:$opponentGoalNumber";
    }
    return "s výsledkem $opponentGoalNumber:$trusGoalNumber";
  }

  String simpleResultToString() {
    if (trusGoalNumber == null || opponentGoalNumber == null) {
      return "neznámý";
    }
    if (homeMatch) {
      return "$trusGoalNumber:$opponentGoalNumber";
    }
    return "$opponentGoalNumber:$trusGoalNumber";
  }

  String stadiumToString() {
    if (stadium != null) {
      return "na hřišti ${stadium!.name}";
    }
    return "na zatím neznámém hřišti";
  }

  String opponentToString() {
    if (stadium != null) {
      return opponent!.name;
    }
    return "neznámý soupeř";
  }

  String refereeToString() {
    if (referee != null) {
      return referee!.name;
    }
    return "zatím neznámý rozhodčí";
  }

  String returnFirstDetailsOfMatch() {
    return "$round. kolo, $league, hrané ${formatDateForFrontend(
        date)}\n\nStadion: ${stadiumToString()}\n\nRozhodčí: ${refereeToString()}\n\nVýsledek: ${simpleResultToString()}";
  }

  String returnSecondDetailsOfMatch() {
    return "\n$refereeComment ${returnBestPlayerText()}${returnGoalScorersText()}${returnOwnGoalScorersText()}${returnYellowCardPlayersText()}${returnRedCardPlayersText()}";
  }

  String returnBestPlayerText() {
    if (playerList.isNotEmpty) {
      for (PkflIndividualStatsApiModel player in playerList) {
        if (player.bestPlayer) {
          return ("\n\nHvězda zápasu: ${player.player.name}");
        }
      }
    }
    return "";
  }

  String returnGoalScorersText() {
    String text = "";
    if (playerList.isNotEmpty) {
      for (PkflIndividualStatsApiModel player in playerList) {
        if (player.goals > 0) {
          int goalNumber = player.goals;
          text += "${player.player.name}: $goalNumber${(goalNumber == 1)
              ? " gól"
              : " góly"}\n";
        }
      }
    }
    if (text.isNotEmpty) {
      return ("\n\nStřelci:\n") + text;
    }
    return text;
  }

  String returnOwnGoalScorersText() {
    String text = "";
    if (playerList.isNotEmpty) {
      for (PkflIndividualStatsApiModel player in playerList) {
        if (player.ownGoals > 0) {
          text +=
          "${player.player.name}: ${player.ownGoals}${(player.ownGoals == 1)
              ? " vlastňák"
              : " vlastňáky"}\n";
        }
      }
    }
    if (text.isNotEmpty) {
      return ("\n\nStřelci vlastňáků:\n") + text;
    }
    return text;
  }

  String returnYellowCardPlayersText() {
    String text = "";
    if (playerList.isNotEmpty) {
      for (PkflIndividualStatsApiModel player in playerList) {
        if (player.yellowCards > 0) {
          text += ("${player.player.name}: ${player.yellowCards}\n");
        }
      }
    }
    if (text.isNotEmpty) {
      return ("\n\nŽluté karty:\n") + text;
    }
    return text;
  }

  String returnRedCardPlayersText() {
    String text = "";
    if (playerList.isNotEmpty) {
      for (PkflIndividualStatsApiModel player in playerList) {
        if (player.redCards > 0) {
          text += ("${player.player.name}: ${player.redCards}\n");
        }
      }
      if (text.isNotEmpty) {
        return ("\n\nČervené karty:\n") + text;
      }
    }
    return text;
  }

  String toStringForSubtitle() {
    return "Datum: ${formatDateForFrontend(
        date)}, výsledek: ${simpleResultToString()}";
  }

  String toStringForMutualMatchesSubtitle() {
    return toStringForSubtitle() + returnGoalScorersText();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PkflMatchApiModel &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PkflMatchApiModel{id: $id, date: $date, opponent: $opponent, round: $round, league: $league, stadium: $stadium, referee: $referee, season: $season, trusGoalNumber: $trusGoalNumber, opponentGoalNumber: $opponentGoalNumber, homeMatch: $homeMatch, urlResult: $urlResult, alreadyPlayed: $alreadyPlayed, playerList: $playerList, matchIdList: $matchIdList}';
  }

  @override
  String httpRequestClass() {
    return pkflApi;
  }

  @override
  int getId() {
    return id;
  }

  @override
  String listViewTitle() {
    return toStringNameWithOpponent();
  }

  @override
  String toStringForAdd() {
    return "";
  }

  @override
  String toStringForConfirmationDelete() {
    return "";
  }

  @override
  String toStringForEdit(String originName) {
    return "";
  }

  @override
  String toStringForListView() {
    return "Datum: ${formatDateForFrontend(date)}, ${stadiumToString()}";
  }
}

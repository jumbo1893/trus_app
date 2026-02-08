import 'package:trus_app/models/api/auth/app_team_api_model.dart';
import 'package:trus_app/models/api/football/league_api_model.dart';
import 'package:trus_app/models/api/football/team_api_model.dart';
import 'package:trus_app/models/api/helper/long_and_long.dart';

import '../../../common/utils/calendar.dart';
import '../../../config.dart';
import '../interfaces/json_and_http_converter.dart';
import '../interfaces/model_to_string.dart';
import 'football_match_player_api_model.dart';

class FootballMatchApiModel implements JsonAndHttpConverter, ModelToString {
  final int? id;
  final DateTime date;
  TeamApiModel? homeTeam;
  TeamApiModel? awayTeam;
  final int round;
  final LeagueApiModel league;
  String? stadium;
  String? referee;
  int? homeGoalNumber;
  int? awayGoalNumber;
  String? urlResult;
  String? refereeComment;
  final bool alreadyPlayed;
  final List<LongAndLong> matchIdAndAppTeamIdList;
  final List<FootballMatchPlayerApiModel> homePlayerList;
  final List<FootballMatchPlayerApiModel> awayPlayerList;

  FootballMatchApiModel({
    this.id,
    required this.date,
    required this.homeTeam,
    required this.awayTeam,
    required this.round,
    required this.league,
    required this.stadium,
    required this.referee,
    this.homeGoalNumber,
    this.awayGoalNumber,
    required this.urlResult,
    this.refereeComment,
    required this.alreadyPlayed,
    required this.matchIdAndAppTeamIdList,
    required this.homePlayerList,
    required this.awayPlayerList,
  });

  FootballMatchApiModel.noMatch()
      : id = -5,
        date = DateTime.now(),
        round = 0,
        alreadyPlayed = false,
        matchIdAndAppTeamIdList = [],
        league = LeagueApiModel.dummy(),
        homePlayerList = [],
        awayPlayerList = [];


  factory FootballMatchApiModel.fromJson(Map<String, dynamic> json) {
    return FootballMatchApiModel(
      id: json["id"],
      date: DateTime.parse(json["date"]),
      homeTeam: TeamApiModel.fromJson(json["homeTeam"]),
      awayTeam: TeamApiModel.fromJson(json["awayTeam"]),
      round: json["round"],
      league: LeagueApiModel.fromJson(json["league"]),
      stadium: json["stadium"],
      referee: json["referee"],
      homeGoalNumber: json["homeGoalNumber"],
      awayGoalNumber: json["awayGoalNumber"],
      urlResult: json["urlResult"],
      refereeComment: json["refereeComment"],
      alreadyPlayed: json["alreadyPlayed"],
      matchIdAndAppTeamIdList: (json["matchIdAndAppTeamIdList"] as List)
          .map((e) => LongAndLong.fromJson(e))
          .toList(),
      homePlayerList: (json["homePlayerList"] as List)
          .map((e) => FootballMatchPlayerApiModel.fromJson(e))
          .toList(),
      awayPlayerList: (json["awayPlayerList"] as List)
          .map((e) => FootballMatchPlayerApiModel.fromJson(e))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "date": date.toIso8601String(),
      "homeTeam": homeTeam?.toJson(),
      "awayTeam": awayTeam?.toJson(),
      "round": round,
      "league": league.toJson(),
      "stadium": stadium,
      "referee": referee,
      "homeGoalNumber": homeGoalNumber,
      "awayGoalNumber": awayGoalNumber,
      "urlResult": urlResult,
      "refereeComment": refereeComment,
      "alreadyPlayed": alreadyPlayed,
      "matchIdAndAppTeamIdList": matchIdAndAppTeamIdList.map((e) => e.toJson()).toList(),
      "homePlayerList": homePlayerList.map((e) => e.toJson()).toList(),
      "awayPlayerList": awayPlayerList.map((e) => e.toJson()).toList(),
    };
  }

  String getOpponentName(int userTeamId) {
    if(homeTeam == null) {
      return "";
    }
    else if(userTeamId == homeTeam!.id) {
      return awayTeam!.name;
    }
    else if(awayTeam == null) {
      return "";
    }
    else if(userTeamId == awayTeam!.id) {
      return homeTeam!.name;
    }
    return "";
  }

  bool isHomeMatch(int userTeamId) {
    if(homeTeam != null && userTeamId == homeTeam!.id) {
      return true;
    }
    else if(awayTeam != null && userTeamId == awayTeam!.id) {
      return false;
    }
    return true;
  }

  String toStringNameWithOpponent() {
    return "${homeTeamToString()} - ${awayTeamToString()}";
  }

  bool isCurrentlyPlaying() {
    final now = DateTime.now();
    final oneHourLater = now.add(const Duration(hours: 1));
    return date.isAfter(now) && date.isBefore(oneHourLater);
  }

  String toStringForNextMatchHomeScreen() {
    if(isCurrentlyPlaying()) {
      return toStringForCurrentlyPlayingMatch();
    }
    return toStringForNextMatch();
  }

  String toStringForLastMatchHomeScreen() {
    if(isCurrentlyPlaying()) {
      return toStringForCurrentlyPlayingMatch();
    }
    return toStringForLastMatch();
  }

  String toStringForNextMatch() {
    return "${toStringNameWithOpponent()}, v čase ${formatDateForFrontend(date)}. Jedná se o souboj ${opponentsTeamRanking()} v $round. kole a bude se hrát ${stadiumToString()}. Pískat bude ${refereeToString()}";
  }

  String toStringForCurrentlyPlayingMatch() {
    return "${toStringNameWithOpponent()}, v čase ${formatDateForFrontend(date)}. Jedná se o souboj ${opponentsTeamRanking()} v $round. kole a hraje se ${stadiumToString()}. Píská ${refereeToString()}";
  }

  String toStringForLastMatch() {
    return "${toStringNameWithOpponent()}, v čase ${formatDateForFrontend(date)}. Jednalo se o souboj ${opponentsTeamRanking()} v $round. kole a hrálo se ${stadiumToString()} ${resultToString()}. Rozhodčí byl ${refereeToString()}";
  }

  String toStringForCardDetail() {
    return "${toStringNameWithOpponent()} hraném ${formatDateForFrontend(date)} ${stadiumToString()} s konečným výsledkem ${resultToString()}. Kartu udělil ${refereeToString()}";
  }

  String opponentsTeamRanking() {
    if (homeTeam != null && awayTeam != null && homeTeam!.currentTableTeam != null && awayTeam!.currentTableTeam != null) {
      return "${homeTeam!.currentTableTeam!.rank}. (${homeTeam!.currentTableTeam!.points} bodů) s ${awayTeam!.currentTableTeam!.rank}. (${awayTeam!.currentTableTeam!.points} bodů)";
    }
    return "";
  }

  String refereeCommentToString() {
    if (refereeComment != null && refereeComment!.isNotEmpty) {
      return refereeComment!;
    }
    return "";
  }

  String resultToString() {
    if (_isScoreUnknown()) {
      return "s neznámým výsledkem";
    }
    return "s výsledkem $homeGoalNumber:$awayGoalNumber";
  }

  String simpleResultToString() {
    if (_isScoreUnknown()) {
      return "neznámý";
    }
    return "$homeGoalNumber:$awayGoalNumber";
  }

  String simpleResultToSimpleString() {
    if (_isScoreUnknown()) {
      return "";
    }
    return "$homeGoalNumber:$awayGoalNumber";
  }

  bool _isScoreUnknown() {
    return (homeGoalNumber == null || awayGoalNumber == null);
  }

  String stadiumToString() {
    if (stadium != null && stadium!.isNotEmpty) {
      return "na hřišti $stadium";
    }
    return "na zatím neznámém hřišti";
  }

  String stadiumToSimpleString() {
    if (stadium != null && stadium!.isNotEmpty) {
      return stadium!;
    }
    return "";
  }

  String homeTeamToString() {
    if (homeTeam != null) {
      return homeTeam!.name;
    }
    return "neznámý soupeř";
  }

  String awayTeamToString() {
    if (awayTeam != null && awayTeam!.name.isNotEmpty) {
      return awayTeam!.name;
    }
    return "neznámý soupeř";
  }

  String bothTeamsToString() {
    return "${homeTeamToString()} : ${awayTeamToString()}";
  }

  String refereeToString() {
    if (referee != null && referee!.isNotEmpty) {
      return referee!;
    }
    return "zatím neznámý rozhodčí";
  }

  String refereeToSimpleString() {
    if (referee != null && referee!.isNotEmpty) {
      return referee!;
    }
    return "";
  }

  String returnRoundLeagueDate() {
    return "$round. kolo, $league, hrané ${formatDateForFrontend(date)}";
  }


  String returnSecondDetailsOfMatch(bool homeTeam, StringReturnDetail stringReturnDetail) {
    switch(stringReturnDetail) {
      case StringReturnDetail.bestPlayer: return returnPlayerSummaryText(homeTeam, _returnBestPlayerText);
      case StringReturnDetail.goalScorer: return returnPlayerSummaryText(homeTeam, _returnGoalScorersText);
      case StringReturnDetail.ownGoal: return returnPlayerSummaryText(homeTeam, _returnOwnGoalScorersText);
      case StringReturnDetail.yellowCard: return returnPlayerSummaryText(homeTeam, _returnYellowCardPlayersText);
      case StringReturnDetail.redCard: return returnPlayerSummaryText(homeTeam, _returnRedCardPlayersText);
    }
  }

  bool _isHomePlayerListUsable() {
    return (homePlayerList.isNotEmpty);
  }

  bool _isAwayPlayerListUsable() {
    return (awayPlayerList.isNotEmpty);
  }

  String returnPlayerSummaryText(bool home,
      Function(List<FootballMatchPlayerApiModel> playerList) function) {
    if (home) {
      if (_isHomePlayerListUsable()) {
        return function(homePlayerList);
      }
      return "";
    } else {
      if (_isAwayPlayerListUsable()) {
        return function(awayPlayerList);
      }
      return "";
    }
  }

  String _returnBestPlayerText(List<FootballMatchPlayerApiModel> playerList) {
    for (FootballMatchPlayerApiModel player in playerList) {
      if (player.bestPlayer) {
        return (player.player.name);
      }
    }
    return "";
  }

  String _returnGoalScorersText(List<FootballMatchPlayerApiModel> playerList) {
    String text = "";
    for (FootballMatchPlayerApiModel player in playerList) {
      if (player.goals > 0) {
        int goalNumber = player.goals;
        text +=
            "${player.player.name}: $goalNumber${(goalNumber == 1) ? " gól" : " góly"}\n";
      }
    }
    if (text.isNotEmpty) {
      return text;
    }
    return text;
  }

  String _returnOwnGoalScorersText(
      List<FootballMatchPlayerApiModel> playerList) {
    String text = "";
    for (FootballMatchPlayerApiModel player in playerList) {
      if (player.ownGoals > 0) {
        text +=
            "${player.player.name}: ${player.ownGoals}${(player.ownGoals == 1) ? " vlastňák" : " vlastňáky"}\n";
      }
    }
    if (text.isNotEmpty) {
      return text;
    }
    return text;
  }

  String _returnYellowCardPlayersText(
      List<FootballMatchPlayerApiModel> playerList) {
    String text = "";
    for (FootballMatchPlayerApiModel player in playerList) {
      if (player.yellowCards > 0) {
        text += ("${player.player.name}: ${player.yellowCards}\n");
      }
    }
    if (text.isNotEmpty) {
      return text;
    }
    return text;
  }

  String _returnRedCardPlayersText(
      List<FootballMatchPlayerApiModel> playerList) {
    String text = "";
    for (FootballMatchPlayerApiModel player in playerList) {
      if (player.redCards > 0) {
        text += ("${player.player.name}: ${player.redCards}\n");
      }
    }
    if (text.isNotEmpty) {
      return text;
    }
    return text;
  }

  String toStringWithTeamsDateAndResult() {
    return "${bothTeamsToString()} ${simpleResultToString()}, ${formatDateForFrontend(date)}";
  }

  String toStringWithTeamsAndResult() {
    return "${bothTeamsToString()} ${simpleResultToString()}";
  }

  String toStringForSubtitle() {
    return "Datum: ${formatDateForFrontend(date)}, výsledek: ${simpleResultToString()}";
  }

  String toStringForMutualMatchesSubtitle(bool homeTeam) {
    return "${toStringForSubtitle()}\n${returnPlayerSummaryText(homeTeam, _returnGoalScorersText)}";
  }

  int? findMatchIdForCurrentAppTeamInMatchIdAndAppTeamIdList(AppTeamApiModel? appTeamApiModel) {
    if(appTeamApiModel == null) {
      return null;
    }
    for(LongAndLong matchIdAndAppTeamId in matchIdAndAppTeamIdList) {
      if(matchIdAndAppTeamId.secondId == appTeamApiModel.id) {
        return matchIdAndAppTeamId.firstId;
      }
    }
    return null;
  }

  @override
  int getId() {
    return id ?? -1;
  }

  @override
  String httpRequestClass() {
    return footballTableApi;
  }

  @override
  String listViewTitle() {
    if(id! == -5) {
      return "Zápasy nenalezeny!";
    }
    return bothTeamsToString();
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
    if(id! == -5) {
      return "";
    }
    return toStringForSubtitle();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FootballMatchApiModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}




enum StringReturnDetail {
  bestPlayer, yellowCard, ownGoal, goalScorer, redCard
}

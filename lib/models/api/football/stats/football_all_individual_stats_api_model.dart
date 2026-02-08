import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/football/football_player_api_model.dart';
import 'package:trus_app/models/api/interfaces/json_and_http_converter.dart';
import 'package:trus_app/models/helper/title_and_text.dart';

import '../../../enum/spinner_options.dart';
import 'card_comment.dart';

class FootballAllIndividualStatsApiModel
    implements JsonAndHttpConverter {
  FootballPlayerApiModel player;
  int matches;
  int goals;
  int receivedGoals;
  int ownGoals;
  int goalkeepingMinutes;
  int yellowCards;
  int redCards;
  int bestPlayer;
  int hattrick;
  int cleanSheet;
  List<CardComment> yellowCardComments;
  List<CardComment> redCardComments;
  int matchPoints;

  FootballAllIndividualStatsApiModel({
    required this.matches,
    required this.player,
    required this.goals,
    required this.receivedGoals,
    required this.ownGoals,
    required this.goalkeepingMinutes,
    required this.yellowCards,
    required this.redCards,
    required this.bestPlayer,
    required this.hattrick,
    required this.cleanSheet,
    required this.yellowCardComments,
    required this.redCardComments,
    required this.matchPoints,
  });

  factory FootballAllIndividualStatsApiModel.fromJson(Map<String, dynamic> json) {
    return FootballAllIndividualStatsApiModel(
      matches: json["matches"],
      player: FootballPlayerApiModel.fromJson(json["player"]),
      goals: json["goals"],
      receivedGoals: json["receivedGoals"],
      ownGoals: json["ownGoals"],
      goalkeepingMinutes: json["goalkeepingMinutes"],
      yellowCards: json["yellowCards"],
      redCards: json["redCards"],
      bestPlayer: json["bestPlayer"],
      hattrick: json["hattrick"],
      cleanSheet: json["cleanSheet"],
      yellowCardComments: List<CardComment>.from(
          (json['yellowCardComments'] as List<dynamic>)
              .map((card) => CardComment.fromJson(card))),
      redCardComments: List<CardComment>.from(
          (json['redCardComments'] as List<dynamic>)
              .map((card) => CardComment.fromJson(card))),
      matchPoints: json["matchPoints"],
    );
  }

  double getGoalMatchesRatio() {
    return goals.toDouble() / matches.toDouble();
  }

  double getReceivedGoalsGoalkeepingMinutesRatio() {
    if (receivedGoals == 0) {
      return 0;
    }
    return receivedGoals.toDouble() / (goalkeepingMinutes.toDouble() / 60);
  }

  double getBestPlayerMatchesRatio() {
    return bestPlayer.toDouble() / matches.toDouble();
  }

  double getYellowCardMatchesRatio() {
    return yellowCards.toDouble() / matches.toDouble();
  }

  double getMatchPointsMatchesRatio() {
    return matchPoints.toDouble() / matches.toDouble();
  }

  String toStringBySpinnerOption(SpinnerOption spinnerOption) {
    switch (spinnerOption) {
      case SpinnerOption.bestPlayerRatio:
        return "počet hvězd utkání na zápas ${roundNumbers(getBestPlayerMatchesRatio())}, počet zápasů $matches";
      case SpinnerOption.goals:
        return "počet gólů: $goals, počet zápasů: $matches";
      case SpinnerOption.bestPlayers:
        return "počet hvězd utkání: $bestPlayer, počet zápasů: $matches";
      case SpinnerOption.yellowCards:
        return "počet žlutejch: $yellowCards, počet zápasů: $matches";
      case SpinnerOption.redCards:
        return "počet červenejch: $redCards, počet zápasů: $matches";
      case SpinnerOption.ownGoals:
        return "počet vlastňáků: $ownGoals, počet zápasů: $matches";
      case SpinnerOption.matches:
        return "počet zápasů: $matches";
      case SpinnerOption.goalkeepingMinutes:
        return "počet odchytaných minut: $goalkeepingMinutes, počet zápasů: $matches";
      case SpinnerOption.goalRatio:
        return "počet gólů na zápas: ${roundNumbers(getGoalMatchesRatio())}, počet zápasů: $matches";
      case SpinnerOption.receivedGoalsRatio:
        return "počet obdržených gólů na zápas: ${roundNumbers(getReceivedGoalsGoalkeepingMinutesRatio())}, počet odchytaných zápasů: ${(roundNumbers(goalkeepingMinutes / 60))}";
      case SpinnerOption.yellowCardRatio:
        return "počet žlutých na zápas: ${roundNumbers(getYellowCardMatchesRatio())}, počet zápasů: $matches";
      case SpinnerOption.hattrick:
        return "počet hattricků: $hattrick, počet zápasů: $matches";
      case SpinnerOption.cleanSheet:
        return "počet čistejch kont: $cleanSheet, počet odchytaných zápasů: ${(roundNumbers(goalkeepingMinutes / 60))}";
      case SpinnerOption.yellowCardDetail:
        return "žlutá karta v zápase ${yellowCardComments[0].footballMatch.toStringForCardDetail()}.\n Komentář sudího: ${yellowCardComments[0].comment}";
      case SpinnerOption.redCardDetail:
        return "červená karta v zápase ${redCardComments[0].footballMatch.toStringForCardDetail()}.\n Komentář sudího: ${redCardComments[0].comment}";
      case SpinnerOption.receivedGoals:
        return "počet obdržených gólů: $receivedGoals, počet odchytaných zápasů: ${(roundNumbers(goalkeepingMinutes / 60))}";
      case SpinnerOption.matchPoints:
        return "průměrný počet získaný v odehraných zápasech: ${roundNumbers(getMatchPointsMatchesRatio())}, počet zápasů: $matches";
    }
  }

  TitleAndText getModelToStringBySpinnerOption(SpinnerOption option) {
    return TitleAndText(title: player.name, text: toStringBySpinnerOption(option));
  }

  String roundNumbers(double number) {
    if (number % 1 == 0) {
      return number.toStringAsFixed(0);
    } else if (number % 0.1 == 0) {
      return number.toStringAsFixed(1);
    } else if (number % 0.01 == 0) {
      return number.toStringAsFixed(2);
    }
    return number.toStringAsFixed(3);
  }

  @override
  String httpRequestClass() {
    return footballAllIndividualStatsApi;
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

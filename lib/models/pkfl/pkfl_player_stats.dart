import 'package:trus_app/models/enum/spinner_options.dart';
import 'package:trus_app/models/pkfl/pkfl_match.dart';
import 'package:trus_app/models/pkfl/pkfl_match_player.dart';

class PkflPlayerStats {
  final String name;
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
  List<String> cardDetail = [];
  String singleCardDetail = "";

  PkflPlayerStats(
    this.name, {
    this.matches = 0,
    this.receivedGoals = 0,
    this.ownGoals = 0,
    this.goalkeepingMinutes = 0,
    this.yellowCards = 0,
    this.redCards = 0,
    this.bestPlayer = 0,
    this.goals = 0,
    this.hattrick = 0,
    this.cleanSheet = 0,
  });

  void enhanceWithPlayerDetail(PkflMatchPlayer player, PkflMatch match) {
    matches++;
    goals += player.goals;
    receivedGoals += player.receivedGoals;
    ownGoals += player.ownGoals;
    goalkeepingMinutes += player.goalkeepingMinutes;
    yellowCards += player.yellowCards;
    redCards += player.redCards;
    if (player.bestPlayer) {
      bestPlayer++;
    }
    if (player.cleanSheet()) {
      cleanSheet++;
    }
    if (player.hattrick()) {
      hattrick++;
    }
    enhanceCardComment(player, match);
  }

  void enhanceCardComment(PkflMatchPlayer player, PkflMatch match) {
    if (player.yellowCardComment != null) {
      cardDetail.add("žlutá karta v zápase ${match.toStringNameWithOpponent()}, hraném ${match.dateToStringWithoutSecondsAndMilliseconds()}"
          " s konečným výsledkem ${match.result}.\n Komentář sudího: ${player.yellowCardComment}");
    }
    if (player.redCardComment != null) {
      cardDetail.add("červená karta v zápase ${match.toStringNameWithOpponent()}, hraném ${match.dateToStringWithoutSecondsAndMilliseconds()}"
          " s konečným výsledkem ${match.result}.\n Komentář sudího: ${player.redCardComment}");
    }
  }

  double getGoalMatchesRatio() {
    return goals.toDouble()/matches.toDouble();
  }

  double getReceivedGoalsGoalkeepingMinutesRatio() {
    if (receivedGoals == 0) {
      return 0;
    }
    return receivedGoals.toDouble()/(goalkeepingMinutes.toDouble()/60);
  }

  double getBestPlayerMatchesRatio() {
    return bestPlayer.toDouble()/matches.toDouble();
  }

  double getYellowCardMatchesRatio() {
    return yellowCards.toDouble()/matches.toDouble();
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
        return "počet obdržených gólů na zápas: ${roundNumbers(getReceivedGoalsGoalkeepingMinutesRatio())}, počet odchytaných zápasů: ${(roundNumbers(goalkeepingMinutes/60))}";
      case SpinnerOption.yellowCardRatio:
        return "počet žlutých na zápas: ${roundNumbers(getYellowCardMatchesRatio())}, počet zápasů: $matches";
      case SpinnerOption.hattrick:
        return "počet hattricků: $hattrick, počet zápasů: $matches";
      case SpinnerOption.cleanSheet:
        return "počet čistejch kont: $cleanSheet, počet odchytaných zápasů: ${(roundNumbers(goalkeepingMinutes/60))}";
      case SpinnerOption.yellowCardDetail:
        return singleCardDetail;
      case SpinnerOption.redCardDetail:
        return singleCardDetail;
      case SpinnerOption.receivedGoals:
        return "počet obdržených gólů: $receivedGoals, počet odchytaných zápasů: ${(roundNumbers(goalkeepingMinutes/60))}";
      case SpinnerOption.matchPoints:
        return "počet obdržených gólů: $receivedGoals, počet odchytaných zápasů: ${(roundNumbers(goalkeepingMinutes/60))}";
    }
  }

  String roundNumbers(double number) {
    if (number % 1 == 0) {
      return number.toStringAsFixed(0);
    }
    else if(number % 0.1 == 0) {
      return number.toStringAsFixed(1);
    }
    else if(number % 0.01 == 0) {
      return number.toStringAsFixed(2);
    }
    return number.toStringAsFixed(3);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PkflPlayerStats &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

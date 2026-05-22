import 'package:trus_app/models/api/beer/beer_detailed_response.dart';
import 'package:trus_app/models/api/goal/goal_detailed_response.dart';
import 'package:trus_app/models/api/receivedfine/received_fine_detailed_response.dart';

import '../../../config.dart';
import '../goal/goal_detailed_model.dart';
import '../interfaces/json_and_http_converter.dart';
import '../receivedfine/received_fine_detailed_model.dart';

class MatchStats implements JsonAndHttpConverter {
  final GoalDetailedResponse goals;
  final BeerDetailedResponse beers;
  final ReceivedFineDetailedResponse fines;


  MatchStats({
    required this.goals,
    required this.beers,
    required this.fines,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      "goals": goals,
      "beers": beers,
      "fines": fines,
    };
  }

  factory MatchStats.fromJson(Map<String, dynamic> json) {
    return MatchStats(
      goals: GoalDetailedResponse.fromJson(json["goals"]),
      beers: BeerDetailedResponse.fromJson(json["beers"]),
      fines: ReceivedFineDetailedResponse.fromJson(json["fines"]),
    );
  }

  @override
  String httpRequestClass() {
    return matchApi;
  }

  String returnGoals() {
    return _returnPlayerStatsText(
      goals.goalList,
          (goal) => goal.goalNumber,
      _goalText,
    );
  }

  String returnAssists() {
    return _returnPlayerStatsText(
      goals.goalList,
          (goal) => goal.assistNumber,
      _assistText,
    );
  }

  String returnBeers() {
    return beers.beerList
        .where((beer) => beer.beerNumber > 0 || beer.liquorNumber > 0)
        .map((beer) {
      final playerName = beer.player?.name ?? "Neznámý hráč";

      final parts = <String>[];

      if (beer.beerNumber > 0) {
        parts.add("${beer.beerNumber} ${_beerText(beer.beerNumber)}");
      }

      if (beer.liquorNumber > 0) {
        parts.add("${beer.liquorNumber} ${_liquorText(beer.liquorNumber)}");
      }

      return "$playerName: ${parts.join(", ")}";
    })
        .join("\n");
  }

  String returnFines() {
    final Map<int, List<ReceivedFineDetailedModel>> finesByPlayer = {};

    for (final fine in fines.fineList) {
      if (fine.fineNumber <= 0 || fine.player == null) {
        continue;
      }

      final playerId = fine.player!.id!;

      finesByPlayer.putIfAbsent(playerId, () => []);
      finesByPlayer[playerId]!.add(fine);
    }

    final Map<String, _GroupedPlayerFines> groupedPlayerFines = {};

    for (final playerFines in finesByPlayer.values) {
      final playerName = playerFines.first.player?.name ?? "Neznámý hráč";

      int playerTotalAmount = 0;
      final fineDescriptions = <String>[];

      for (final fine in playerFines) {
        final fineName = fine.fine?.name ?? "neznámá pokuta";

        final fineTotalAmount = fine.fineAmount > 0
            ? fine.fineAmount
            : fine.fineNumber * (fine.fine?.amount ?? 0);

        playerTotalAmount += fineTotalAmount;

        if (fine.fineNumber == 1) {
          fineDescriptions.add(fineName);
        } else {
          fineDescriptions.add("${fine.fineNumber}x $fineName");
        }
      }

      // Aby se správně spojili hráči i v případě, že BE vrátí pokuty
      // v jiném pořadí.
      fineDescriptions.sort();

      final groupKey = "$playerTotalAmount|${fineDescriptions.join("|")}";

      groupedPlayerFines.putIfAbsent(
        groupKey,
            () => _GroupedPlayerFines(
          totalAmount: playerTotalAmount,
          fineDescriptions: fineDescriptions,
        ),
      );

      groupedPlayerFines[groupKey]!.playerNames.add(playerName);
    }

    final groups = groupedPlayerFines.values.toList()
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    return groups.map((group) {
      group.playerNames.sort();

      final players = group.playerNames.join(", ");
      final descriptions = group.fineDescriptions.join(", ");
      return "$players: ${group.totalAmount} Kč ($descriptions)";
    }).join("\n");
  }

  String _returnPlayerStatsText(
      List<GoalDetailedModel> list,
      int Function(GoalDetailedModel goal) valueGetter,
      String Function(int count) labelGetter,
      ) {
    return list
        .where((goal) => valueGetter(goal) > 0)
        .map((goal) {
      final playerName = goal.player?.name ?? "Neznámý hráč";
      final count = valueGetter(goal);

      return "$playerName: $count ${labelGetter(count)}";
    })
        .join("\n");
  }

  String _goalText(int count) {
    if (count == 1) {
      return "gól";
    }

    if (count >= 2 && count <= 4) {
      return "góly";
    }

    return "gólů";
  }

  String _assistText(int count) {
    if (count == 1) {
      return "asistence";
    }

    if (count >= 2 && count <= 4) {
      return "asistence";
    }

    return "asistencí";
  }

  String _beerText(int count) {
    if (count == 1) {
      return "pivo";
    }

    if (count >= 2 && count <= 4) {
      return "piva";
    }

    return "piv";
  }

  String _liquorText(int count) {
    if (count == 1) {
      return "panák";
    }

    if (count >= 2 && count <= 4) {
      return "panáky";
    }

    return "panáků";
  }

  String returnOverall() {
    return "Celkem: ${goals.totalGoals} gólů, ${goals.totalAssists} asistencí,"
        " ${beers.totalBeers} piv, ${beers.totalLiquors} panáků a ${fines.finesAmount} Kč pokut";
  }
}

class _GroupedPlayerFines {
  final int totalAmount;
  final List<String> fineDescriptions;
  final List<String> playerNames = [];

  _GroupedPlayerFines({
    required this.totalAmount,
    required this.fineDescriptions,
  });
}

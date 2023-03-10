import 'dart:ui';

import 'package:trus_app/features/beer/lines/player_lines.dart';

class PlayerLinesCalculator {
  List<double> x1 = [];
  List<double> x2 = [];
  List<double> y1 = [];
  List<double> y2 = [];

  List<double> liquorX1 = [];
  List<double> liquorX2 = [];
  List<double> liquorY1 = [];
  List<double> liquorY2 = [];
  bool isLiquorImage = false;
  final PlayerLines playerLines;
  final Size size;

  PlayerLinesCalculator(this.playerLines, this.size) {
    _initPlayerLines();
  }

  void _initPlayerLines() {
      for (int j = 0; j < playerLines.x1.length; j++) {
        addAllBeerPositions(_calculateBeerLinePosition(j, playerLines.x1[j], playerLines.x2[j], playerLines.y1[j], playerLines.y2[j],));
      }
      for (int j = 0; j < playerLines.liquorX1.length; j++) {
        addAllLiquorPositions(_calculateLiquorLinePosition(j, playerLines.liquorX1[j], playerLines.liquorX2[j], playerLines.liquorY1[j], playerLines.liquorY2[j],));
      }

  }

  void addAllBeerPositions(List<double> doubleList) {

    x1.add(doubleList[0]);
    x2.add(doubleList[1]);
    y1.add(doubleList[2]);
    y2.add(doubleList[3]);
  }

  void addAllLiquorPositions(List<double> doubleList) {
    liquorX1.add(doubleList[0]);
    liquorX2.add(doubleList[1]);
    liquorY1.add(doubleList[2]);
    liquorY2.add(doubleList[3]);
  }


  /// vypočítá pozice čáry dalšího přidaného piva
  ///
  /// @param i kolikáté pivo hráče to je. Ostatní parametry jsou double uložené random hodnoty
  List<double> _calculateBeerLinePosition(int i, double randomX1, double randomX2, double randomY1, double randomY2) {
    double x1;
    double x2;
    double y1;
    double y2;
    if (i == 4 || i == 9 || i == 14) {
      y1 = (size.height / 6) +
          randomY1 * size.height / 8 -
          size.height / 16;
      y2 = (size.height / 6) +
          randomY2 * size.height / 8 -
          size.height / 16;
    } else if (i == 19 || i == 24 || i == 29) {
      y1 = (size.height / 2) +
          randomY1 * size.height / 8 -
          size.height / 16;
      y2 = (size.height / 2) +
          20 +
          randomY2 * size.height / 8 -
          size.height / 16;
    } else if (i < 15) {
      y1 = randomY1 * size.height / 12;
      y2 = (size.height / 3) +
          randomY2 * size.height / 12 -
          size.height / 24;
    } else {
      y1 = (size.height / 3) + randomY1 * size.height / 12;
      y2 = (size.height / 3) * 2 +
          randomY2 * size.height / 12 -
          size.height / 24;
    }
    if (i == 4 || i == 19) {
      x1 = randomX1 * size.width / 15;
      x2 = (size.width / 15) * 5 +
          randomX2 * size.width / 15 -
          size.width / 30;
    } else if (i == 9 || i == 24) {
      x1 = (size.width / 15) * 5 +
          randomX1 * size.width / 15 -
          size.width / 30;
      x2 = (size.width / 15) * 10 +
          randomX2 * size.width / 15 -
          size.width / 30;
    } else if (i == 14 || i == 29) {
      x1 = (size.width / 15) * 10 +
          randomX1 * size.width / 15 -
          size.width / 30;
      x2 = size.width + randomX2 * size.width / 20 - size.width / 20;
    } else {
      if (i >= 15) {
        i = i - 15;
      }
      x1 = size.width / 15 +
          i * size.width / 15 +
          randomX1 * size.width / 30;
      x2 = size.width / 15 +
          i * size.width / 15 +
          randomX2 * size.width / 30;
    }
    return [x1, x2, y1, y2];
  }

  /// vypočítá pozice čáry dalšího přidaného tvrdýho
  ///
  /// @param i kolikátej tvrdej hráče to je
  List<double> _calculateLiquorLinePosition(int i, double randomX1, double randomX2, double randomY1, double randomY2) {
    double x1;
    double x2;
    double y1;
    double y2;
    if (i == 4 || i == 9 || i == 14 || i == 19) {
      y1 = (size.height / 6) * 5 +
          randomY1 * size.height / 8 -
          size.height / 16;
      y2 = (size.height / 6) * 5 +
          randomY2 * size.height / 8 -
          size.height / 16;
    } else {
      y1 = (size.height / 3) * 2 + randomY1 * size.height / 12;
      y2 = size.height +
          randomY2 * size.height / 12 -
          size.height / 24;
    }
    if (i == 4) {
      x1 = size.width*0.3 + randomX1 * size.width / 30;
      x2 = size.width*0.45 + randomX2 * size.width / 30;
    } else if (i == 9) {
      x1 = size.width*0.46  + randomX1 * size.width / 30;
      x2 = size.width*0.62 + randomX2 * size.width / 30;
    } else if (i == 14) {
      x1 = size.width*0.63 + randomX1 * size.width / 30;
      x2 = size.width*0.79 + randomX2 * size.width / 30;
    } else if (i == 19) {
      x1 = size.width*0.8 + randomX1 * size.width / 30;
      x2 = size.width*0.96 + randomX2 * size.width / 30;
    } else {
      x1 = (size.width / 3) +
          i * size.width / 30 +
          randomX1 * size.width / 40;
      x2 = (size.width / 3) +
          i * size.width / 30 +
          randomX2 * size.width / 40;
    }
    return [x1, x2, y1, y2];
  }

  bool isLiquorLinesDrawn() {
    return liquorX1.isNotEmpty;
  }

}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trus_app/features/beer/lines/player_lines.dart';
import 'package:trus_app/features/beer/lines/player_lines_calculator.dart';
import 'dart:ui' as ui;

import '../../../models/helper/beer_helper_model.dart';
import 'new_player_lines_calculator.dart';

class Painter extends CustomPainter{

  //List<BeerHelperModel> beers = [];
  //List<int> beerNumber = [];
  //List<int> liquorNumber = [];
  late final Paint borderPaint;
  late final Paint whitePaint;
  late final Paint linePaint;
  int inte = 0;
  bool animated = false;
  final PlayerLines playerLines;
  bool liquerDraw = false;
  final Random random = Random();
  //List<Point> listOfPoints = [];
  final double _progress;
  //List<double> newLineCoordinates;
  final NewPlayerLinesCalculator? newPlayerLinesCalculator;
  ui.Image image;

  static const int beerLimit = 30;
  static const int liquorLimit = 20;

  Painter(this.playerLines, this.newPlayerLinesCalculator, this._progress, this.image) {
    linePaint = Paint()..color=Colors.orange..strokeWidth=5.5..style=PaintingStyle.fill..strokeWidth=4..strokeCap=StrokeCap.round;
    borderPaint = Paint()..color=Colors.black..strokeWidth=5.5..style=PaintingStyle.stroke;
    whitePaint = Paint()..color=Colors.white;
  }

  double divideLine(double progress, double x1, double x2) {
    return x1+(progress*-1+1)*(x2-x1);
  }

  @override
  Future<void> paint(Canvas canvas, Size size) async {
    final Paint linePaint = Paint()..color=Colors.orange..strokeWidth=5.5..style=PaintingStyle.fill..strokeWidth=size.width/100..strokeCap=StrokeCap.round;
    canvas.drawRect(Rect.largest, borderPaint);
    PlayerLinesCalculator playerLinesCalculator = PlayerLinesCalculator(playerLines, size);
    for (int i = 0; i < playerLinesCalculator.x1.length; i++) {
      canvas.drawLine(Offset(playerLinesCalculator.x1[i], playerLinesCalculator.y1[i]),Offset(playerLinesCalculator.x2[i], playerLinesCalculator.y2[i]), linePaint);
    }
    for (int i = 0; i < playerLinesCalculator.liquorX1.length; i++) {
      canvas.drawLine(Offset(playerLinesCalculator.liquorX1[i], playerLinesCalculator.liquorY1[i]), Offset(playerLinesCalculator.liquorX2[i], playerLinesCalculator.liquorY2[i]), linePaint);
    }

    if(newPlayerLinesCalculator != null) {
      newPlayerLinesCalculator!.initPlayerLines(size);
      canvas.drawLine(
          Offset(newPlayerLinesCalculator!.x1, newPlayerLinesCalculator!.y1), Offset(divideLine(_progress, newPlayerLinesCalculator!.x1, newPlayerLinesCalculator!.x2), divideLine(_progress, newPlayerLinesCalculator!.y1, newPlayerLinesCalculator!.y2)), linePaint);
    }
    if(playerLinesCalculator.isLiquorLinesDrawn() || (newPlayerLinesCalculator != null && !newPlayerLinesCalculator!.isBeer)) {
      canvas.drawImage(image, Offset(10.0, (size.height / 5) * 4), Paint());
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
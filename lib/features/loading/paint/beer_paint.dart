import 'dart:ui';
import 'package:flutter/material.dart';

class BeerPaint {
  final Offset bottomLeft;
  final Offset bottomRight;
  final double height;
  final bool beerFoam;

  BeerPaint(this.bottomLeft, this.bottomRight, this.height, this.beerFoam);

  Path returnBeerPaint() {
    final Path path = Path();
    final double upperLeftY = bottomLeft.dy - height;
    final double upperRightY = bottomRight.dy - height;
    final double width = (bottomRight.dx - bottomLeft.dx).abs();
    path.moveTo(bottomLeft.dx, upperLeftY);
    path.lineTo(bottomLeft.dx, bottomLeft.dy);
    path.lineTo(bottomRight.dx, bottomLeft.dy);
    path.lineTo(bottomRight.dx, upperRightY);
    path.moveTo(bottomLeft.dx, upperRightY + height / 3);
    path.lineTo(bottomLeft.dx - height / 4, upperRightY + height / 3);
    path.lineTo(bottomLeft.dx - height / 4, upperRightY + (height / 3) * 2);
    path.lineTo(bottomLeft.dx, upperRightY + (height / 3) * 2);
    if (beerFoam) {
      path.moveTo(bottomLeft.dx, upperLeftY);
      path.quadraticBezierTo(bottomLeft.dx + width / 6, upperLeftY + height / 6,
          bottomLeft.dx + width / 3, upperLeftY);
      path.quadraticBezierTo(
        bottomLeft.dx + (width / 2),
        upperLeftY + height / 6,
        bottomLeft.dx + (width / 3) * 2,
        upperLeftY,
      );
      path.quadraticBezierTo(
        bottomRight.dx - width / 6,
        upperLeftY + height / 6,
        bottomRight.dx,
        upperLeftY,
      );
    }
    return path;
  }
}

import 'package:flutter/material.dart';
import 'dart:math' as math;

class FigureLinesCalculator {
  final Size size;
  final double bodyAngle;
  final double leftArmAngle;
  final double leftForearmAngle;
  final double rightArmAngle;
  final double rightForearmAngle;
  final double leftThighAngle;
  final double rightThighAngle;
  final double leftCalfAngle;
  final double rightCalfAngle;
  final double bodyX1;
  final double bodyY1;
  final double headRadius;
  final double firstRightLegAngle;
  late final double bodyLength;
  late final double upperLimbsLength;
  late final double bottomLimbsLength;
  List<Offset> bodyComponents = [];
  List<Offset> leftArmComponents = [];
  List<Offset> leftForearmComponents = [];
  List<Offset> rightArmComponents = [];
  List<Offset> rightForearmComponents = [];
  List<Offset> leftThighComponents = [];
  List<Offset> rightThighComponents = [];
  List<Offset> leftCalfComponents = [];
  List<Offset> rightCalfComponents = [];
  late Offset ballComponents;
  late Offset headComponents;

  FigureLinesCalculator(
      this.size,
      this.bodyX1,
      this.bodyY1,
      this.headRadius,
      this.bodyAngle,
      this.leftArmAngle,
      this.leftForearmAngle,
      this.rightArmAngle,
      this.rightForearmAngle,
      this.leftThighAngle,
      this.rightThighAngle,
      this.leftCalfAngle,
      this.rightCalfAngle,
      this.firstRightLegAngle) {
    bodyLength = (size.height / 2);
    upperLimbsLength = (size.height / 9)*2 ;
    bottomLimbsLength = (size.height / 3);
  }

  List<Offset> _calculateBodyOffsets(double x1, double y1, double angleInDegrees, double length) {
    final double angleInRadians = angleInDegrees * (math.pi / 180.0);// stupně převádíme na radiány
    final double x2 = x1 + (length * math.sin(angleInRadians));
    final double y2 = y1 + (length * math.cos(angleInRadians));
    return [Offset(x1, y1), Offset(x2, y2)];
  }

  void calculateComponents() {
    bodyComponents = _calculateBodyOffsets(bodyX1, bodyY1, bodyAngle, bodyLength);
    final double absoluteLeftArmAngle = bodyAngle + leftArmAngle;
    Offset armStartComponents = _calculateArmStartComponents(bodyX1, bodyY1, bodyComponents[1].dx, bodyComponents[1].dy);
    leftArmComponents = _calculateBodyOffsets(armStartComponents.dx, armStartComponents.dy, absoluteLeftArmAngle, upperLimbsLength);
    final double absoluteLeftForearmAngle = absoluteLeftArmAngle + leftForearmAngle;
    leftForearmComponents = _calculateBodyOffsets(leftArmComponents[1].dx, leftArmComponents[1].dy, absoluteLeftForearmAngle, upperLimbsLength);
    final double absoluteRightArmAngle = bodyAngle + rightArmAngle;
    rightArmComponents = _calculateBodyOffsets(armStartComponents.dx, armStartComponents.dy, absoluteRightArmAngle, upperLimbsLength);
    final double absoluteRightForearmAngle = absoluteRightArmAngle + rightForearmAngle;
    rightForearmComponents = _calculateBodyOffsets(rightArmComponents[1].dx, rightArmComponents[1].dy, absoluteRightForearmAngle, upperLimbsLength);
    final double absoluteLeftThighAngle = bodyAngle + leftThighAngle;
    leftThighComponents = _calculateBodyOffsets(bodyComponents[1].dx, bodyComponents[1].dy, absoluteLeftThighAngle, bottomLimbsLength);
    final double absoluteRightThighAngle = bodyAngle + rightThighAngle;
    rightThighComponents = _calculateBodyOffsets(bodyComponents[1].dx, bodyComponents[1].dy, absoluteRightThighAngle, bottomLimbsLength);
    final double absoluteLeftCalfAngle = absoluteLeftThighAngle + leftCalfAngle;
    leftCalfComponents = _calculateBodyOffsets(leftThighComponents[1].dx, leftThighComponents[1].dy, absoluteLeftCalfAngle, bottomLimbsLength);
    final double absoluteRightCalfAngle = absoluteRightThighAngle + rightCalfAngle;
    rightCalfComponents = _calculateBodyOffsets(rightThighComponents[1].dx, rightThighComponents[1].dy, absoluteRightCalfAngle, bottomLimbsLength);
    headComponents = Offset(bodyComponents[0].dx+10, bodyComponents[0].dy-headRadius);
    ballComponents = _calculateBallOffset();
  }

  Offset _calculateArmStartComponents(double bodyX1, double bodyY1, double bodyX2, double bodyY2, ) {
    //používáme lineární interpolaci
    double t = 1.0 / 10.0;  // poměr, kde budou ruce od hlavy
    double x = bodyX1 + t * (bodyX2 - bodyX1);
    double y = bodyY1 + t * (bodyY2 - bodyY1);
    return Offset(x, y);
  }

  Offset _calculateBallOffset() {
    List<Offset> helperBodyComponents = _calculateBodyOffsets(bodyX1, 0.0, bodyAngle, bodyLength);
    List<Offset> helperLegComponents = _calculateBodyOffsets(helperBodyComponents[1].dx, helperBodyComponents[1].dy, firstRightLegAngle, bottomLimbsLength*2);
    return Offset(helperLegComponents[1].dx, helperLegComponents[1].dy);
  }

}

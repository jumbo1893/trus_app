
import 'dart:ui';

class TablePaint {
  final Offset leftLeg;
  final Offset rightLeg;
  final double height;
  TablePaint(this.leftLeg, this.rightLeg, this.height);

  Path returnTablePaint() {
    final Path path = Path();
    path.moveTo(rightLeg.dx, rightLeg.dy); // Pravý dolní roh
    path.lineTo(rightLeg.dx, rightLeg.dy-height); // Pravý horní roh
    path.moveTo(leftLeg.dx, leftLeg.dy); // Levý dolní roh
    path.lineTo(leftLeg.dx, leftLeg.dy-height); // Levý horní roh
    double leftTableTopX = leftLeg.dx - 20;
    double rightTableTopX = rightLeg.dx + 20;
    path.moveTo(leftTableTopX, leftLeg.dy-height); // Levá deska
    path.lineTo(rightTableTopX, rightLeg.dy-height); // Pravá deska
    return path;
  }

}
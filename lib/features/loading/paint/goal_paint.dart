
import 'dart:ui';

class GoalPaint {
  final Offset leftPost;
  final Offset rightPost;
  final double height;
  GoalPaint(this.leftPost, this.rightPost, this.height);

  Path returnGoalPaint() {
    final Path path = Path();
    path.moveTo(rightPost.dx, rightPost.dy); // Pravý dolní roh
    path.lineTo(leftPost.dx, leftPost.dy); // Levý dolní roh
    path.lineTo(leftPost.dx, leftPost.dy-height); // Levý horní roh
    double rightPostX = rightPost.dx - (rightPost.dx -leftPost.dx)/2;
    path.lineTo(rightPostX, leftPost.dy-height); // Pravý horní roh
    path.lineTo(rightPost.dx, rightPost.dy);
    List<Offset> firstNet = _calculateNetOffset(rightPostX, leftPost.dy-height, rightPost.dx, rightPost.dy);
    List<Offset> firstNetEnd = _calculateNetOffsetEnd(leftPost.dx, leftPost.dy-height, leftPost.dx, leftPost.dy);
    for(int i = 0; i < firstNet.length; i++) {
      path.moveTo(firstNet[i].dx, firstNet[i].dy);
      path.lineTo(firstNetEnd[i].dx, firstNetEnd[i].dy);
    }
    return path;
  }

  List<Offset> _calculateNetOffset(double bodyX1, double bodyY1, double bodyX2, double bodyY2, ) {
    //používáme lineární interpolaci
    List<Offset> returnList = [];
    for(int i = 0; i < 5; i++) {
      double t = i * 2.0 / 10.0; // poměr, kde budou ruce od hlavy
      double x = bodyX1 + t * (bodyX2 - bodyX1);
      double y = bodyY1 + t * (bodyY2 - bodyY1);
      returnList.add(Offset(x, y));
    }
    return returnList;
  }

  List<Offset> _calculateNetOffsetEnd (double bodyX1, double bodyY1, double bodyX2, double bodyY2, ) {
    //používáme lineární interpolaci
    List<Offset> returnList = [];
    for(int i = 1; i <= 5; i++) {
      double t = i * 2.0 / 10.0; // poměr, kde budou ruce od hlavy
      double x = bodyX1 + t * (bodyX2 - bodyX1);
      double y = bodyY1 + t * (bodyY2 - bodyY1);
      returnList.add(Offset(x, y));
    }
    return returnList;
  }

}
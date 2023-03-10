class PlayerLines {
  List<double> x1 = [];
  List<double> x2 = [];
  List<double> y1 = [];
  List<double> y2 = [];

  List<double> liquorX1 = [];
  List<double> liquorX2 = [];
  List<double> liquorY1 = [];
  List<double> liquorY2 = [];
  bool isLiquorImage = false;

  PlayerLines();

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

  void removeLastBeerPosition() {
    print(x1.length);
    if (x1.isNotEmpty) {
      x1.removeLast();
      x2.removeLast();
      y1.removeLast();
      y2.removeLast();
    }
  }

  void removeLastLiquorPosition() {
    if (isLiquorLinesDrawn()) {
      liquorX1.removeLast();
      liquorX2.removeLast();
      liquorY1.removeLast();
      liquorY2.removeLast();
    }
  }

  bool isLiquorLinesDrawn() {
    return liquorX1.isNotEmpty;
  }

}

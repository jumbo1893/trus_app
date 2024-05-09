import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:trus_app/models/api/home/coordinate.dart';

import '../../../colors.dart';
import '../../../models/api/home/chart.dart';
import 'legend.dart';

class HomeChart extends StatefulWidget {
  final List<Chart> charts;
  const HomeChart({super.key, required this.charts});

  @override
  State<HomeChart> createState() => _HomeChartState();
}

class _HomeChartState extends State<HomeChart> {
  List<Color> gradientBeerColors = [
    orangeColor,
    Colors.yellow,
  ];

  List<Color> gradientMainPlayerColors = [
    orangeColor,
    Colors.yellow,
  ];

  List<Color> gradientLiquorColors = [
    Colors.red,
    Colors.brown,
  ];

  List<Color> gradientColors = [
    Colors.white54,
    Colors.grey,
  ];

  bool showFines = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1.70,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 18,
                  left: 12,
                  top: 24,
                  bottom: 12,
                ),
                child: LineChart(
                  beerData(!showFines),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: SizedBox(
                  height: 34,
                  child: Text(
                    showFines ? "statistika panáků" : "statistika pivek",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: SizedBox(
                  height: 34,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        showFines = !showFines;
                      });
                    },
                    child: Text(
                      showFines ? "přepni na pivka" : "přepni na panáky",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center,children: getLegends(),)
      ],
    );
  }

  List<Widget> getLegends() {
    List<Widget> legends = [];
    for(Chart chart in widget.charts) {
      legends.add(Legend(text: chart.player.name, gradientColors: getPlayerColors(chart)));
      legends.add(const SizedBox(width: 4,));
    }
    return legends;
  }

  double calculateHorizontalInterval(List<int> labels) {
    if(labels.length < 2) {
      return 2;
    }
    return labels[1].toDouble();
  }

  List<FlSpot> getFlSpots(List<Coordinate> coordinates, bool beer, bool liquor, bool fine) {
    List<FlSpot> spots = [];
    if(beer) {
      for(int i = 0; i < coordinates.length; i++) {
        spots.add(FlSpot(i.toDouble(), coordinates[i].beerNumber.toDouble()));
      }
    }
    if(liquor) {
      for(int i = 0; i < coordinates.length; i++) {
        spots.add(FlSpot(i.toDouble(), coordinates[i].liquorNumber.toDouble()));
      }
    }
    if(fine) {
      for(int i = 0; i < coordinates.length; i++) {
        spots.add(FlSpot(i.toDouble(), coordinates[i].fineAmount.toDouble()));
      }
    }
    return spots;
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    Widget text;
    if(widget.charts.isNotEmpty) {
      text = Text(widget.charts[0].coordinates[value.toInt()].matchInitials, style: style,);
    }
    else {
      text = const Text("");
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  List<int> findHorizontalInterval() {
    if(widget.charts.isNotEmpty) {
      return findChartWithTheHighestBeerMaximum().beerLabels;
    }
    return [0,5];
  }

  double findMaxX() {
    if(widget.charts.isNotEmpty) {
      return (findChartWithTheHighestBeerMaximum().coordinates.length-1).toDouble();
    }
    return 4;
  }

  double findMaxY() {
    if(widget.charts.isNotEmpty) {
      return findChartWithTheHighestBeerMaximum().beerMaximum.toDouble();
    }
    return 10;
  }

  Chart findChartWithTheHighestBeerMaximum() {
    List<Chart> chartList = [];
    chartList.addAll(widget.charts);
    return chartList.reduce((currentChart, nextChart) => currentChart.beerMaximum > nextChart.beerMaximum ? currentChart : nextChart);
  }

  LineChartData beerData(bool beer) {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (value) {
            return value
                .map((e) => LineTooltipItem(
                "${widget.charts[e.barIndex].player.name} ${e.y.toInt()}",
                const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,)))
                .toList();
          },
          tooltipBgColor: Colors.white,
          showOnTopOfTheChartBoxArea: true

        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: calculateHorizontalInterval(findHorizontalInterval()),
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: orangeColor,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.orange,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: null,
            getTitlesWidget: null,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color:  Colors.black),
      ),
      minX: 0,
      maxX: findMaxX(),
      minY: 0,
      maxY: findMaxY(),
      lineBarsData: getBeerCharData(beer)
    );
  }

  List<Color> getPlayerColors(Chart chart) {
    List<Chart> chartList = [];
    chartList.addAll(widget.charts);
    chartList.removeWhere((element) => element.mainPlayer);
    List<List<Color>> gradientColorsList = [[
      Colors.blue,
      Colors.blueGrey,
    ], [
      Colors.red,
      Colors.brown,
    ], [
      Colors.black26,
      Colors.grey,
    ], [
      Colors.green,
      Colors.greenAccent,
    ],
      [
        orangeColor,
        Colors.yellow,
      ]
    ];
    if(chart.mainPlayer) {
      return [
        orangeColor,
        Colors.yellow,
      ];
    }
    return gradientColorsList[chartList.indexOf(chart)];
  }

  List<LineChartBarData> getBeerCharData(bool beer) {
    List<LineChartBarData> lineCharBarDataList = [];
    for(Chart chart in widget.charts) {
      LineChartBarData lineChartBarData = LineChartBarData(spots: getFlSpots(chart.coordinates, beer, !beer, false),
          isCurved: true,
          gradient: LinearGradient(
            colors: getPlayerColors(chart),
          ),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ));
      lineCharBarDataList.add(lineChartBarData);
    }
    return lineCharBarDataList;
  }
}
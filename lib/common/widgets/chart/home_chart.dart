import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:trus_app/models/api/home/coordinate.dart';

import '../../../colors.dart';
import '../../../models/api/home/chart.dart';

class HomeChart extends StatefulWidget {
  final Chart chart;
  const HomeChart({super.key, required this.chart});

  @override
  State<HomeChart> createState() => _HomeChartState();
}

class _HomeChartState extends State<HomeChart> {
  List<Color> gradientBeerColors = [
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
    return Stack(
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
              showFines ? fineData() : beerData(),
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
                showFines ? "statistika pokut" : "statistika pivek/panáků",
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
                  showFines ? "přepni na pivka" : "přepni na pokuty",
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
    );
  }

  double calculateHorizontalInterval(List<int> labels) {
    if(labels.length < 2) {
      return 0;
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
    Widget text = Text(widget.chart.coordinates[value.toInt()].matchInitials, style: style,);
    /*switch (value.toInt()) {
      case 0:
        text = const Text('SEH', style: style);
        break;
      case 1:
        text = const Text('PUA', style: style);
        break;
      case 2:
        text = const Text('KAM', style: style);
        break;
      case 3:
        text = const Text('EIN', style: style);
        break;
      case 4:
        text = const Text('MOD', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }*/

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgetsForBeers(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    //String text = widget.chart.beerLabels[value.toInt()].toString();
    switch (value.toInt()) {
      case 0:
        text = '0';
        break;
      case 5:
        text = '5';
        break;
      case 10:
        text = '10';
        break;
      /*case 15:
        text = '15';
        break;*/
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    //String text = widget.chart.coordinates[value.toInt()].matchInitials;
    switch (value.toInt()) {
      case 0:
        text = '0';
        break;
      case 5:
        text = '5';
        break;
      case 10:
        text = '10';
        break;
      case 15:
        text = '15';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData beerData() {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (value) {
            return value
                .map((e) => LineTooltipItem(
                "${e.barIndex == 0 ? 'Piva:' : 'Panáky:'} ${e.y.toInt()} ",
                const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,)))
                .toList();
          }
        )
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: calculateHorizontalInterval(widget.chart.beerLabels),
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
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: (widget.chart.coordinates.length-1).toDouble(),
      minY: 0,
      maxY: widget.chart.beerMaximum.toDouble(),
      lineBarsData: [
        LineChartBarData(
          spots: getFlSpots(widget.chart.coordinates, true, false, false),
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientBeerColors,
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
          ),
        ),LineChartBarData(
          spots: getFlSpots(widget.chart.coordinates, false, true, false),
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientLiquorColors,
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
          ),
        ),
      ],
    );
  }

  LineChartData fineData() {
    return LineChartData(
      lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (value) {
                return value
                    .map((e) => LineTooltipItem(
                    "Pokuty: ${e.y.toInt()} Kč",
                    const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,)))
                    .toList();
              }
          )
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: calculateHorizontalInterval(
            widget.chart.fineLabels),
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
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: (widget.chart.coordinates.length - 1).toDouble(),
      minY: 0,
      maxY: widget.chart.fineMaximum.toDouble(),
      lineBarsData: [
        LineChartBarData(
          spots: getFlSpots(widget.chart.coordinates, false, false, true),
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientBeerColors,
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
          ),
        )
      ],
    );
  }
}
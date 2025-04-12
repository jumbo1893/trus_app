import 'dart:async';

import 'package:trus_app/models/api/home/chart.dart';
mixin ChartControllerMixin {

  final Map<String, Chart?> chartValues = {};
  final Map<String, bool> createdChartChecker = {};
  final Map<String, StreamController<Chart?>> chartControllers = {};

  void _setAlreadyCreated(String key) {
    createdChartChecker[key] = true;
  }

  void _createChartStream(String key) {
    if(!(createdChartChecker[key]?? false)) {
      _setAlreadyCreated(key);
      chartValues[key] = Chart.dummy();
      chartControllers[key] = StreamController<Chart?>.broadcast();
    }
  }

  Stream<Chart?> chartValue(String key) {
    _createChartStream(key);
    return chartControllers[key]?.stream ?? const Stream.empty();
  }

  void setChartValue(Chart? chart, String key) {
    _createChartStream(key);
    chartValues[key] = chart;
    chartControllers[key]?.add(chart);
  }

  void initChartFields(Chart? chart, String key) {
    _createChartStream(key);
    setChartValue(chart, key);
  }
}

import 'dart:async';

import 'package:trus_app/models/api/home/chart.dart';
mixin ChartListControllerMixin {

  final Map<String, List<Chart>> chartListValues = {};
  final Map<String, bool> createdChartListChecker = {};
  final Map<String, StreamController<List<Chart>>> chartListControllers = {};

  void _setAlreadyCreated(String key) {
    createdChartListChecker[key] = true;
  }

  void _createChartListStream(String key) {
    if(!(createdChartListChecker[key]?? false)) {
      _setAlreadyCreated(key);
      chartListValues[key] = [];
      chartListControllers[key] = StreamController<List<Chart>>.broadcast();
    }
  }

  Stream<List<Chart>> chartListValue(String key) {
    _createChartListStream(key);
    return chartListControllers[key]?.stream ?? const Stream.empty();
  }

  void setChartListValue(List<Chart> charts, String key) {
    _createChartListStream(key);
    chartListValues[key] = charts;
    chartListControllers[key]?.add(charts);
  }

  void initChartListFields(List<Chart> charts, String key) {
    _createChartListStream(key);
    setChartListValue(charts, key);
  }
}

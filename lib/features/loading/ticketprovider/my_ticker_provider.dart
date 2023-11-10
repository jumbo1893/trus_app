import 'package:flutter/scheduler.dart';

class MyTickerProvider implements TickerProvider {

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}

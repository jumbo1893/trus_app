import 'package:flutter/scheduler.dart';

import 'my_ticker_provider.dart';

class MyTickerProviderFactory {
  TickerProvider createTickerProvider() {
    return MyTickerProvider();
  }
}

import 'dart:core';

import 'package:trus_app/models/pkfl/pkfl_match_player.dart';

class PkflSeason {
  final String url;
  final String name;

  PkflSeason(this.url, this.name);

  @override
  String toString() {
    return 'PkflSeason{url: $url, name: $name}';
  }
}
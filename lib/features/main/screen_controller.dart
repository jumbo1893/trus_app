import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../../models/api/pkfl/pkfl_match_api_model.dart';

final screenControllerProvider = Provider((ref) {
  return ScreenController(

      ref: ref);
});

class ScreenController {
  final ProviderRef ref;
  final screenController = StreamController<Widget>.broadcast();
  PkflMatchApiModel? pkflMatch;
  late int matchId;

  ScreenController({
    required this.ref,
  });



}

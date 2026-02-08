import 'package:flutter_riverpod/flutter_riverpod.dart';

final backHandlerProvider =
StateProvider<BackHandler?>((ref) => null);

abstract class BackHandler {
  bool onBack();
}
import 'package:flutter/material.dart';
import 'staggered_fade_slide_in.dart';

extension AnimatedMenu on List<Widget> {
  List<Widget> withStaggeredAnimation({
    Duration baseDelay = const Duration(milliseconds: 70),
    Duration stepDelay = const Duration(milliseconds: 50),
  }) {
    return List.generate(length, (index) {
      return StaggeredFadeSlideIn(
        index: index,
        baseDelay: baseDelay,
        stepDelay: stepDelay,
        child: this[index],
      );
    });
  }
}
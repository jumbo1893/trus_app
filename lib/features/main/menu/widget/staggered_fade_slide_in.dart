import 'package:flutter/material.dart';

import 'fade_slide_in.dart';

class StaggeredFadeSlideIn extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final Duration baseDelay;
  final Duration stepDelay;
  final Offset beginOffset;
  final Curve curve;

  const StaggeredFadeSlideIn({
    super.key,
    required this.child,
    required this.index,
    this.duration = const Duration(milliseconds: 320),
    this.baseDelay = Duration.zero,
    this.stepDelay = const Duration(milliseconds: 30),
    this.beginOffset = const Offset(0, 0.05),
    this.curve = Curves.easeOutCubic,
  });

  Duration get _computedDelay {
    return Duration(
      milliseconds:
      baseDelay.inMilliseconds + (index * stepDelay.inMilliseconds),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      delay: _computedDelay,
      duration: duration,
      beginOffset: beginOffset,
      curve: curve,
      child: child,
    );
  }
}
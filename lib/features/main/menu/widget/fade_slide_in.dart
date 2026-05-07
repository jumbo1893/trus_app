import 'package:flutter/material.dart';

class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Offset beginOffset;
  final Curve curve;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 350),
    this.delay = Duration.zero,
    this.beginOffset = const Offset(0, 0.08),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration + delay,
      builder: (context, value, child) {
        final delayedProgress = delay == Duration.zero
            ? value
            : ((value * (duration + delay).inMilliseconds - delay.inMilliseconds) /
            duration.inMilliseconds)
            .clamp(0.0, 1.0);

        final curved = Curves.easeOutCubic.transform(delayedProgress);

        final dx = beginOffset.dx * (1 - curved);
        final dy = beginOffset.dy * (1 - curved);

        return Opacity(
          opacity: curved,
          child: Transform.translate(
            offset: Offset(dx * 100, dy * 100),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
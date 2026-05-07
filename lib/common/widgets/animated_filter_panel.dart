import 'package:flutter/material.dart';

class AnimatedFilterPanel extends StatelessWidget {
  final bool visible;
  final Widget child;

  const AnimatedFilterPanel({
    super.key,
    required this.visible,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: visible ? 1 : 0,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          offset: visible ? Offset.zero : const Offset(0, -0.08),
          child: visible ? child : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
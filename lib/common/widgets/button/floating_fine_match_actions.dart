import 'dart:math' as math;
import 'package:flutter/material.dart';

class FloatingFineMatchActions extends StatefulWidget {
  final Function(int index) onIconClicked;

  const FloatingFineMatchActions({
    super.key,
    required this.onIconClicked,
  });

  @override
  State<FloatingFineMatchActions> createState() => _FloatingFineMatchActionsState();
}

class _FloatingFineMatchActionsState extends State<FloatingFineMatchActions>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const List<IconData> icons = [
    Icons.check,
    Icons.group,
    Icons.accessible_forward,
    Icons.man,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(icons.length, (index) {
            final isPrimary = index == 0;

            return SizeTransition(
              sizeFactor: CurvedAnimation(
                parent: _controller,
                curve: Curves.easeOutCubic,
              ),
              axisAlignment: -1,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FloatingActionButton(
                  heroTag: 'fine_action_$index',
                  mini: true,
                  backgroundColor: isPrimary ? Colors.lightGreen : Colors.white,
                  onPressed: () => widget.onIconClicked(index),
                  child: Icon(
                    icons[index],
                    color: isPrimary ? Colors.black : Colors.orange,
                  ),
                ),
              ),
            );
          }),
          FloatingActionButton(
            heroTag: 'fine_action_toggle',
            onPressed: () {
              if (_controller.isDismissed) {
                _controller.forward();
              } else {
                _controller.reverse();
              }
            },
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 0.5 * math.pi,
                  child: Icon(
                    _controller.isDismissed ? Icons.more_vert : Icons.close,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
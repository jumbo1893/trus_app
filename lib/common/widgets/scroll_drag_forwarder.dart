import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A pinned summary forwards vertical drags to the adjacent results list.
class ScrollDragForwarder extends StatefulWidget {
  final ScrollController? controller;
  final Widget child;
  const ScrollDragForwarder({
    super.key,
    required this.controller,
    required this.child,
  });
  @override
  State<ScrollDragForwarder> createState() => _ScrollDragForwarderState();
}

class _ScrollDragForwarderState extends State<ScrollDragForwarder> {
  Drag? _drag;
  void _cancel() {
    _drag?.cancel();
    _drag = null;
  }

  @override
  void dispose() {
    _cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.translucent,
    onVerticalDragStart: (details) {
      _cancel();
      final controller = widget.controller;
      if (controller != null && controller.hasClients) {
        _drag = controller.position.drag(details, () => _drag = null);
      }
    },
    onVerticalDragUpdate: (details) => _drag?.update(details),
    onVerticalDragEnd: (details) {
      _drag?.end(details);
      _drag = null;
    },
    onVerticalDragCancel: _cancel,
    child: widget.child,
  );
}

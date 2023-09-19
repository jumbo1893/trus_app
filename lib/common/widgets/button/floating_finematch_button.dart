
import 'package:flutter/material.dart';
import 'package:trus_app/colors.dart';
import 'dart:math' as math;

class FloatingFineMatchButton extends StatefulWidget {
  final Function(bool multiselect) onMultiselectClicked;
  final Function(int index) onIconClicked;

  const FloatingFineMatchButton({
    Key? key,
    required this.onMultiselectClicked,
    required this.onIconClicked,
  }) : super(key: key);



  @override
  State<FloatingFineMatchButton> createState() => _FloatingFineMatchButtonState();
}

class _FloatingFineMatchButtonState extends State<FloatingFineMatchButton> with TickerProviderStateMixin {

  late AnimationController _controller;

  //musíme udělat init AnimationControlleru v initState, abysme mohli doplnit parametr vsync. Ten čerpá z TickerProviderStateMixin
  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    super.initState();
  }

  static const List<IconData> icons = [
    Icons.check,
    Icons.group,
    Icons.accessible_forward,
    Icons.man
  ];


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(icons.length, (int index) {
          Color backColor;
          Color iconColor;
          if (index == 0) {
            backColor = Colors.lightGreen;
            iconColor = Colors.black;
          } else {
            backColor = backgroundColor;
            iconColor = Colors.orange;
          }
          Widget child = Container(
            height: 70.0,
            width: 56.0,
            alignment: FractionalOffset.topCenter,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: _controller,
                curve: Interval(0.0, 1.0 - index / icons.length / 2.0,
                    curve: Curves.easeOut),
              ),
              child: FloatingActionButton(
                heroTag: null,
                backgroundColor: backColor,
                mini: true,
                child: Icon(icons[index], color: iconColor),
                onPressed: () {
                  widget.onIconClicked(index);
                },
              ),
            ),
          );
          return child;
        }).toList()
          ..add(
            FloatingActionButton(
              heroTag: null,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget? child) {
                  return Transform(
                    transform: Matrix4.rotationZ(
                        _controller.value * 0.5 * math.pi),
                    alignment: FractionalOffset.center,
                    child: Icon(_controller.isDismissed
                        ? Icons.checklist
                        : Icons.close),
                  );
                },
              ),
              onPressed: () {
                if (_controller.isDismissed) {
                  _controller.forward();
                  widget.onMultiselectClicked(true);
                } else {
                  _controller.reverse();
                  widget.onMultiselectClicked(false);
                  //checkedPlayers.clear();
                }
              },
            ),
          ),
      ),
    );
  }
}

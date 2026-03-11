import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trus_app/colors.dart';

class RandomFactBox extends StatefulWidget implements PreferredSizeWidget {
  const RandomFactBox({
    super.key,
    required this.facts,
    required this.padding,
  });

  final List<String> facts;
  final double padding;

  @override
  Size get preferredSize => const Size.fromHeight(kMinInteractiveDimension);

  @override
  State<RandomFactBox> createState() => _RandomFactBoxState();
}

class _RandomFactBoxState extends State<RandomFactBox>
    with SingleTickerProviderStateMixin {
  int randomFactNumber = 0;
  late final AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void setNewRandomFactNumber() {
    if (widget.facts.isEmpty) return;
    randomFactNumber = Random().nextInt(widget.facts.length);
  }

  void setNextRandomFactNumber(bool next) {
    if (widget.facts.isEmpty) return;

    if (next) {
      randomFactNumber = (randomFactNumber + 1) % widget.facts.length;
    } else {
      randomFactNumber = (randomFactNumber - 1) < 0
          ? widget.facts.length - 1
          : randomFactNumber - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final facts = widget.facts;

    if (facts.isEmpty) return const SizedBox.shrink();
    if (randomFactNumber >= facts.length) randomFactNumber = 0;

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    return Container(
      margin: const EdgeInsets.all(5.0),
      padding: const EdgeInsets.all(3.0),
      width: size.width - widget.padding * 2,
      decoration: BoxDecoration(border: Border.all(color: Colors.black54)),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Náhodná zajímavost #${randomFactNumber + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      key: const ValueKey('random_text_title'),
                    ),
                    Flexible(
                      child: GestureDetector(
                        onHorizontalDragEnd: (dragEndDetails) {
                          if (dragEndDetails.primaryVelocity == null) return;
                          setState(() {
                            if (dragEndDetails.primaryVelocity! < 0) {
                              setNextRandomFactNumber(true);
                            } else if (dragEndDetails.primaryVelocity! > 0) {
                              setNextRandomFactNumber(false);
                            }
                          });
                        },
                        child: Text(
                          facts[randomFactNumber],
                          textAlign: TextAlign.center,
                          key: const ValueKey('random_text'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              RotationTransition(
                turns: _animation,
                child: IconButton(
                  icon: const Icon(Icons.refresh, color: orangeColor, size: 40),
                  onPressed: () {
                    _animationController.forward(from: 0).whenComplete(() {
                      setState(setNewRandomFactNumber);
                    });
                  },
                  key: const ValueKey('random_text_refresh'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
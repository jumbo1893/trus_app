import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';

import '../../../features/home/widget/home_section_card.dart';

class RandomFactBox extends StatefulWidget {
  const RandomFactBox({
    super.key,
    required this.facts,
  });

  final List<String> facts;

  @override
  State<RandomFactBox> createState() => _RandomFactBoxState();
}

class _RandomFactBoxState extends State<RandomFactBox>
    with SingleTickerProviderStateMixin {
  int randomFactNumber = 0;
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void setNewRandomFactNumber() {
    if (widget.facts.isEmpty) return;

    int newIndex = randomFactNumber;
    if (widget.facts.length > 1) {
      while (newIndex == randomFactNumber) {
        newIndex = Random().nextInt(widget.facts.length);
      }
    }

    setState(() {
      randomFactNumber = newIndex;
    });
  }

  void setNextRandomFactNumber(bool next) {
    if (widget.facts.isEmpty) return;

    setState(() {
      if (next) {
        randomFactNumber = (randomFactNumber + 1) % widget.facts.length;
      } else {
        randomFactNumber = (randomFactNumber - 1) < 0
            ? widget.facts.length - 1
            : randomFactNumber - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final facts = widget.facts;
    final appColors = context.appColors;
    if (facts.isEmpty) return const SizedBox.shrink();
    if (randomFactNumber >= facts.length) randomFactNumber = 0;

    return HomeSectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (dragEndDetails) {
                final velocity = dragEndDetails.primaryVelocity;
                if (velocity == null) return;

                if (velocity < 0) {
                  setNextRandomFactNumber(true);
                } else if (velocity > 0) {
                  setNextRandomFactNumber(false);
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Náhodná zajímavost #${randomFactNumber + 1}',
                    key: const ValueKey('random_text_title'),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: appColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    facts[randomFactNumber],
                    key: const ValueKey('random_text'),
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: appColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: appColors.accentSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: RotationTransition(
              turns: _animation,
              child: IconButton(
                key: const ValueKey('random_text_refresh'),
                icon: Icon(
                  Icons.refresh_rounded,
                  color: appColors.accent,
                  size: 26,
                ),
                onPressed: () {
                  _animationController.forward(from: 0);
                  setNewRandomFactNumber();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
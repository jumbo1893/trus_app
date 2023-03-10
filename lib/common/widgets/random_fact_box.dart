import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/widgets/loader.dart';

class RandomFactBox extends StatefulWidget implements PreferredSizeWidget {
  const RandomFactBox({
    super.key,
    required this.randomFactStream,
    required this.padding,
  });

  final Stream<List<String>> randomFactStream;
  final double padding;

  @override
  Size get preferredSize => const Size.fromHeight(kMinInteractiveDimension);

  @override
  State<RandomFactBox> createState() => _RandomFactBoxState();
}

class _RandomFactBoxState extends State<RandomFactBox> with SingleTickerProviderStateMixin {
  int randomFactNumber = -1;
  int listLength = 0;
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

  void setNewRandomFactNumber(int listLength) {
    randomFactNumber = Random().nextInt(listLength);
  }

  void setNextRandomFactNumber(bool next) {
    if (randomFactNumber != -1) {
      if (next) {
        if (randomFactNumber == listLength-1) {
          randomFactNumber = 0;
        }
        else {
          randomFactNumber++;
        }
      }
      else {
        if (randomFactNumber == 0) {
          randomFactNumber = listLength-1;
        }
        else {
          randomFactNumber--;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _animation = Tween<double>(
        begin: 0,
        end: 1
    ).animate(_animationController);
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
              child: StreamBuilder<List<String>>(
                  stream: widget.randomFactStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Loader();
                    }
                    List<String> randomFactList = snapshot.data!;
                    listLength = randomFactList.length;
                    if (randomFactNumber == -1) {
                      setNewRandomFactNumber(randomFactList.length);
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Náhodná zajímavost #${randomFactNumber+1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            )),
                        Flexible(
                          child: GestureDetector(
                            onHorizontalDragEnd: (dragEndDetails) {
                              if (dragEndDetails.primaryVelocity! < 0) {
                                setState(() {
                                  setNextRandomFactNumber(true);
                                });
                              } else if(dragEndDetails.primaryVelocity! > 0){
                                setState(() {
                                  setNextRandomFactNumber(false);
                                });
                              }
                            },
                            child: Text(
                              randomFactList[randomFactNumber],
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
            ),
            RotationTransition(
              turns: _animation,
              child: IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: orangeColor,
                  size: 40,
                ),
                color: orangeColor,
                onPressed: () {
                  _animationController.forward(
                      from: 0
                  ).whenComplete(() => setState(() {
                    setNewRandomFactNumber(listLength);
                  }));

                },
              ),
            ),
          ],
        ),
      )),
    );
  }
}

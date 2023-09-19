import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/utils/utils.dart';
import 'package:trus_app/common/widgets/error.dart';
import 'package:trus_app/features/beer/controller/beer_controller.dart';
import 'package:trus_app/features/beer/lines/player_lines.dart';


import '../../../colors.dart';
import '../../../common/widgets/loader.dart';
import '../lines/new_player_lines_calculator.dart';
import '../lines/painter.dart';

class BeerPaintScreen extends ConsumerStatefulWidget {

  const BeerPaintScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<BeerPaintScreen> createState() => _BeerPaintScreenState();
}

class _BeerPaintScreenState extends ConsumerState<BeerPaintScreen>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  late Size size;
  late Animation<double> animation;
  final Random random = Random();
  late AnimationController controller;
  NewPlayerLinesCalculator? newPlayerLinesCalculator;
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    ref.read(beerControllerProvider).initPlayerLines();
    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    animation = Tween(begin: 1.0, end: 0.0).animate(controller)
      ..addListener(() {
        setState(() {
          _progress = animation.value;
        });
      });
  }

  Future<ui.Image> _loadImage() async {
    ByteData bd = await rootBundle.load("images/tvrdej.jpg");
    final Uint8List bytes = Uint8List.view(bd.buffer);
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.Image image = (await codec.getNextFrame()).image;
    image.height;
    return image;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void setNextPlayer() {
    if(!controller.isAnimating) {
      setState(() {
        if (!(ref.read(beerControllerProvider).playerIndex == ref.read(beerControllerProvider).beerList.length - 1)) {
          ref.read(beerControllerProvider).playerIndex++;
        } else {
          ref.read(beerControllerProvider).playerIndex = 0;
        }
        ref.read(beerControllerProvider).initStreamPaint();
      });

    }
  }

  void setPreviousPlayer() {
    if(!controller.isAnimating) {
      setState(() {
        if (ref.read(beerControllerProvider).playerIndex > 0) {
          ref.read(beerControllerProvider).playerIndex--;
        } else {
          ref.read(beerControllerProvider).playerIndex = ref.read(beerControllerProvider).beerList.length - 1;
        }
        ref.read(beerControllerProvider).initStreamPaint();
      });
    }
  }

  void addBeer() {
    if(!controller.isAnimating) {
      if (ref.read(beerControllerProvider).beerList[ref.read(beerControllerProvider).playerIndex].beerNumber < 30) {
        newPlayerLinesCalculator = NewPlayerLinesCalculator(
            returnRandomNumbersForLines(), true,
            ref.read(beerControllerProvider).beerList[ref.read(beerControllerProvider).playerIndex].beerNumber);
        ref.read(beerControllerProvider).beerList[ref.read(beerControllerProvider).playerIndex].addNumber(true);
        controller.forward(from: 0).whenComplete(() =>
            setState(() {
              ref.read(beerControllerProvider).playerLinesList[ref.read(beerControllerProvider).playerIndex].addAllBeerPositions(
                  newPlayerLinesCalculator!.newLineCoordinates);
              newPlayerLinesCalculator = null;
            }));
      }
      else {
        showSnackBarWithPostFrame(context: context, content: "Víc jak 30 piv nelze načárkovat!");
      }
    }
  }

  void removeBeer() {
    if(!controller.isAnimating) {
      setState(() {
        ref.read(beerControllerProvider).beerList[ref.read(beerControllerProvider).playerIndex].removeNumber(true);
        ref.read(beerControllerProvider).playerLinesList[ref.read(beerControllerProvider).playerIndex].removeLastBeerPosition();
      });
    }
  }

  void addLiquor() {
    if(!controller.isAnimating) {
      if (ref.read(beerControllerProvider).beerList[ref.read(beerControllerProvider).playerIndex].liquorNumber < 20) {
        newPlayerLinesCalculator = NewPlayerLinesCalculator(
            returnRandomNumbersForLines(), false,
            ref.read(beerControllerProvider).beerList[ref.read(beerControllerProvider).playerIndex].liquorNumber);
        ref.read(beerControllerProvider).beerList[ref.read(beerControllerProvider).playerIndex].addNumber(false);
        controller.forward(from: 0).whenComplete(() =>
            setState(() {
              ref.read(beerControllerProvider).playerLinesList[ref.read(beerControllerProvider).playerIndex]
                  .addAllLiquorPositions(
                  newPlayerLinesCalculator!.newLineCoordinates);
              newPlayerLinesCalculator = null;
            }));
      }
      else {
        showSnackBarWithPostFrame(context: context, content: "Víc jak 20 paňáků nelze načárkovat!");
      }
    }
  }

  void removeLiquor() {
    if(!controller.isAnimating) {
      setState(() {
        ref.read(beerControllerProvider).beerList[ref.read(beerControllerProvider).playerIndex].removeNumber(false);
        ref.read(beerControllerProvider).playerLinesList[ref.read(beerControllerProvider).playerIndex].removeLastLiquorPosition();
      });
    }
  }

  /*void _initPlayerLines() {
    playerLinesList = [];
    for (int i = 0; i < ref.read(beerControllerProvider).beerList.length; i++) {
      playerLinesList.add(PlayerLines());
      for (int j = 0; j < ref.read(beerControllerProvider).beerList[i].beerNumber; j++) {
        playerLinesList[i].addAllBeerPositions(returnRandomNumbersForLines());
      }
      for (int j = 0; j < ref.read(beerControllerProvider).beerList[i].liquorNumber; j++) {
        playerLinesList[i]
            .addAllLiquorPositions(returnRandomNumbersForLines());
      }
    }
  }*/

  List<double> returnRandomNumbersForLines() {
    return [random.nextDouble(), random.nextDouble(), random.nextDouble(), random.nextDouble()];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;
    if (ref.read(beerControllerProvider).playerLinesList.isNotEmpty) {
      return FutureBuilder<ui.Image>(
          future: _loadImage(),
          builder: (context, snapshot) {
            if (_image == null &&
                snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            }
            _image = snapshot.data!;
            Painter painter = Painter(ref.read(beerControllerProvider).playerLinesList[ref.read(beerControllerProvider).playerIndex],
                newPlayerLinesCalculator, _progress, snapshot.data!);

            return StreamBuilder<PlayerLines>(
              stream: ref.watch(beerControllerProvider).reload(),
              builder: (context, ssnapshot) {
                if (ssnapshot.connectionState != ConnectionState.waiting) {
                  painter = Painter(ssnapshot.data!,
                      newPlayerLinesCalculator, _progress, snapshot.data!);
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          SizedBox(
                              width: size.width / 6,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () {
                                  setPreviousPlayer();
                                },
                                color: orangeColor,
                              )),
                          SizedBox(
                              width: size.width / 1.5,
                              child: Text(
                                ref.read(beerControllerProvider).beerList[ref.read(beerControllerProvider).playerIndex].player.name,
                                style: const TextStyle(
                                    color: blackColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal),
                              )),
                          SizedBox(
                              width: size.width / 6,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_forward),
                                onPressed: () {
                                  setNextPlayer();
                                },
                                color: orangeColor,
                              )),
                        ],
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onVerticalDragEnd: (dragEndDetails) {
                          if (dragEndDetails.primaryVelocity! > 0) {
                            addBeer();
                          } else if (dragEndDetails.primaryVelocity! < 0) {
                            setState(() {
                              removeBeer();
                            });
                          }
                        },
                        onHorizontalDragEnd: (dragEndDetails) {
                          if (dragEndDetails.primaryVelocity! > 0) {
                            addLiquor();
                          } else if (dragEndDetails.primaryVelocity! < 0) {
                            setState(() {
                              removeLiquor();
                            });
                          }
                        },
                        child: CustomPaint(
                          painter: painter,
                          child: Container(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50,),
                    Row(
                      children: [
                        SizedBox(
                            width: size.width / 6,
                            child: const Icon(
                              Icons.info_outline, color: Colors.black,)),
                        SizedBox(
                            width: size.width / 1.3,
                            child: const Text(
                                "Vertikálním čárkováním se zapisují piva, horizontálním panáky"))
                      ],
                    ),
                  ],
                );
              }
            );
          });
    }
    return const ErrorScreen(error: 'Není dostatečný počet hráčů!',

    );
  }
}

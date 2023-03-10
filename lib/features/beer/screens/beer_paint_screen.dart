import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/utils/utils.dart';
import 'package:trus_app/features/beer/lines/player_lines.dart';
import 'package:trus_app/models/helper/beer_helper_model.dart';

import 'package:trus_app/models/match_model.dart';

import '../../../colors.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/loader.dart';
import '../lines/new_player_lines_calculator.dart';
import '../lines/painter.dart';

class BeerPaintScreen extends ConsumerStatefulWidget {
  final List<BeerHelperModel> beers;
  final Function(int) newBeerNumber;
  final Function(int) newLiquorNumber;
  final Function(int) pickedPlayer;
  final VoidCallback onChangeBeersPressed;
  const BeerPaintScreen({
    Key? key,
    required this.beers,
    required this.newBeerNumber,
    required this.newLiquorNumber,
    required this.pickedPlayer,
    required this.onChangeBeersPressed,
  }) : super(key: key);

  @override
  ConsumerState<BeerPaintScreen> createState() => _BeerPaintScreenState();
}

class _BeerPaintScreenState extends ConsumerState<BeerPaintScreen>
    with SingleTickerProviderStateMixin {
  int playerIndex = 0;
  double _progress = 0.0;
  late Size size;
  late Animation<double> animation;
  List<PlayerLines> playerLinesList = [];
  final Random random = Random();
  late AnimationController controller;
  NewPlayerLinesCalculator? newPlayerLinesCalculator;
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _initPlayerLines();
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
        if (!(playerIndex == widget.beers.length - 1)) {
          playerIndex++;
        } else {
          playerIndex = 0;
        }
      });
      widget.pickedPlayer(playerIndex);
    }
  }

  void setPreviousPlayer() {
    if(!controller.isAnimating) {
      setState(() {
        if (playerIndex > 0) {
          playerIndex--;
        } else {
          playerIndex = widget.beers.length - 1;
        }
      });
    }
    widget.pickedPlayer(playerIndex);
  }

  void addBeer() {
    if(!controller.isAnimating) {
      if (widget.beers[playerIndex].beerNumber < 30) {
        newPlayerLinesCalculator = NewPlayerLinesCalculator(
            returnRandomNumbersForLines(), true,
            widget.beers[playerIndex].beerNumber);
        widget.beers[playerIndex].addBeerNumber();
        controller.forward(from: 0).whenComplete(() =>
            setState(() {
              playerLinesList[playerIndex].addAllBeerPositions(
                  newPlayerLinesCalculator!.newLineCoordinates);
              newPlayerLinesCalculator = null;
            }));
        widget.newBeerNumber(widget.beers[playerIndex].beerNumber);
      }
      else {
        showSnackBar(context: context, content: "Víc jak 30 piv nelze načárkovat!");
      }
    }
  }

  void removeBeer() {
    if(!controller.isAnimating) {
      setState(() {
        widget.beers[playerIndex].removeBeerNumber();
        playerLinesList[playerIndex].removeLastBeerPosition();
      });
      widget.newBeerNumber(widget.beers[playerIndex].beerNumber);
    }
  }

  void addLiquor() {
    if(!controller.isAnimating) {
      if (widget.beers[playerIndex].liquorNumber < 20) {
        newPlayerLinesCalculator = NewPlayerLinesCalculator(
            returnRandomNumbersForLines(), false,
            widget.beers[playerIndex].liquorNumber);
        widget.beers[playerIndex].addLiquorNumber();
        controller.forward(from: 0).whenComplete(() =>
            setState(() {
              playerLinesList[playerIndex]
                  .addAllLiquorPositions(
                  newPlayerLinesCalculator!.newLineCoordinates);
              newPlayerLinesCalculator = null;
            }));
        widget.newLiquorNumber(widget.beers[playerIndex].beerNumber);
      }
      else {
        showSnackBar(context: context, content: "Víc jak 20 paňáků nelze načárkovat!");
      }
    }
  }

  void removeLiquor() {
    if(!controller.isAnimating) {
      setState(() {
        widget.beers[playerIndex].removeLiquorNumber();
        playerLinesList[playerIndex].removeLastLiquorPosition();
      });
      widget.newLiquorNumber(widget.beers[playerIndex].beerNumber);
    }
  }

  void _initPlayerLines() {
    playerLinesList = [];
    for (int i = 0; i < widget.beers.length; i++) {
      playerLinesList.add(PlayerLines());
      for (int j = 0; j < widget.beers[i].beerNumber; j++) {
        playerLinesList[i].addAllBeerPositions(returnRandomNumbersForLines());
      }
      for (int j = 0; j < widget.beers[i].liquorNumber; j++) {
        playerLinesList[i]
            .addAllLiquorPositions(returnRandomNumbersForLines());
      }
    }
  }

  List<double> returnRandomNumbersForLines() {
    return [random.nextDouble(), random.nextDouble(), random.nextDouble(), random.nextDouble()];
  }

  void changeBeers() {
    widget.onChangeBeersPressed();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return FutureBuilder<ui.Image>(
        future: _loadImage(),
        builder: (context, snapshot) {
          if (_image == null &&
              snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          _image = snapshot.data!;
          Painter painter = Painter(playerLinesList[playerIndex],
              newPlayerLinesCalculator, _progress, snapshot.data!);

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
                          widget.beers[playerIndex].player.name,
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
              SizedBox(height: 50,),
              Row(
                children: [
                  SizedBox(
                    width: size.width/6,
                      child: Icon(Icons.info_outline, color: Colors.black,)),
                  SizedBox(
                    width: size.width/1.3,
                      child: Text("Vertikálním čárkováním se zapisují piva, horizontálním panáky"))
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: CustomButton(
                    text: "Přidej piva", onPressed: changeBeers),
              ),
            ],
          );
        });
  }
}

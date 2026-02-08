import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/utils/utils.dart';
import 'package:trus_app/features/beer/controller/beer_notifier.dart';
import 'package:trus_app/features/beer/lines/new_player_lines_calculator.dart';
import 'package:trus_app/features/beer/lines/painter.dart';

import '../../../common/widgets/error.dart';
import '../../../common/widgets/loader.dart';

class BeerPaintScreen extends ConsumerStatefulWidget {
  const BeerPaintScreen({super.key});

  @override
  ConsumerState<BeerPaintScreen> createState() => _BeerPaintScreenState();
}

class _BeerPaintScreenState extends ConsumerState<BeerPaintScreen>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  late Animation<double> animation;
  late AnimationController controller;
  final Random random = Random();
  NewPlayerLinesCalculator? newPlayerLinesCalculator;
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    animation = Tween(begin: 1.0, end: 0.0).animate(controller)
      ..addListener(() {
        setState(() {
          _progress = animation.value;
        });
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<ui.Image> _loadImage() async {
    final bd = await rootBundle.load("images/tvrdej.jpg");
    final bytes = Uint8List.view(bd.buffer);
    final codec = await ui.instantiateImageCodec(bytes);
    return (await codec.getNextFrame()).image;
  }

  List<double> _randLine() {
    return [random.nextDouble(), random.nextDouble(), random.nextDouble(), random.nextDouble()];
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(beerNotifierProvider);
    final notifier = ref.read(beerNotifierProvider.notifier);

    if (notifier.playerLinesList.isEmpty || state.beers.isEmpty) {
      return const ErrorScreen(error: 'Není dostatečný počet hráčů!');
    }

    return FutureBuilder<ui.Image>(
      future: _image != null ? Future.value(_image) : _loadImage(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Loader();
        _image = snapshot.data!;

        final idx = state.playerIndex;
        final lines = notifier.playerLinesList[idx];

        Painter painter = Painter(lines, newPlayerLinesCalculator, _progress, _image!);

        void addBeer() {
          if (controller.isAnimating) return;
          int playerIndex = state.playerIndex;
          newPlayerLinesCalculator = notifier.getPlayerLinesCalculator(true);
          if(newPlayerLinesCalculator == null) {
            showSnackBarWithPostFrame(context: context, content: "Víc jak 30 piv nelze načárkovat!");
            return;
          }
          controller.forward(from: 0).whenComplete(() =>
              setState(() {
                notifier.addNumber(playerIndex, true, newPlayerLinesCalculator!.newLineCoordinates);
                newPlayerLinesCalculator = null;
              }));
        }

        void addLiquor() {
          if (controller.isAnimating) return;
          int playerIndex = state.playerIndex;
          newPlayerLinesCalculator = notifier.getPlayerLinesCalculator(false);
          if(newPlayerLinesCalculator == null) {
            //TODO udělat globální snackbar
            showSnackBar(context: context, content: "Víc jak 20 paňáků nelze načárkovat!");
            return;
          }
          controller.forward(from: 0).whenComplete(() =>
              setState(() {
                notifier.addNumber(playerIndex, false, newPlayerLinesCalculator!.newLineCoordinates);
                newPlayerLinesCalculator = null;
              }));
        }

        void removeBeer() {
          if (controller.isAnimating) return;
          notifier.removeNumber(idx, true);
        }

        void removeLiquor() {
          if (controller.isAnimating) return;
          notifier.removeNumber(idx, false);
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 50,
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 6,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: notifier.prevPlayer,
                      color: orangeColor,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1.5,
                    child: Text(
                      state.beers[idx].player.name,
                      style: const TextStyle(color: blackColor, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 6,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: notifier.nextPlayer,
                      color: orangeColor,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                onVerticalDragEnd: (d) {
                  if (d.primaryVelocity == null) return;
                  if (d.primaryVelocity! > 0) addBeer();
                  if (d.primaryVelocity! < 0) removeBeer();
                },
                onHorizontalDragEnd: (d) {
                  if (d.primaryVelocity == null) return;
                  if (d.primaryVelocity! > 0) addLiquor();
                  if (d.primaryVelocity! < 0) removeLiquor();
                },
                child: CustomPaint(
                  painter: painter,
                  child: Container(),
                ),
              ),
            ),
            const SizedBox(height: 50),
            const Row(
              children: [
                SizedBox(width: 60, child: Icon(Icons.info_outline, color: Colors.black)),
                Expanded(
                  child: Text("Vertikálním čárkováním se zapisují piva, horizontálním panáky"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

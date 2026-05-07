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
import '../widget/beer_paint_hint.dart';

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
    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
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
    final bd = await rootBundle.load("images/tvrdej_light.jpg");
    final bytes = Uint8List.view(bd.buffer);
    final codec = await ui.instantiateImageCodec(bytes);
    return (await codec.getNextFrame()).image;
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
        final player = state.beers[idx].player;
        final totalPlayers = state.beers.length;

        final painter = Painter(
          lines,
          newPlayerLinesCalculator,
          _progress,
          _image!,
        );

        void addBeer() {
          if (controller.isAnimating) return;
          final playerIndex = state.playerIndex;

          newPlayerLinesCalculator = notifier.getPlayerLinesCalculator(true);
          if (newPlayerLinesCalculator == null) {
            showSnackBarWithPostFrame(
              context: context,
              content: "Víc jak 30 piv nelze načárkovat!",
            );
            return;
          }

          controller.forward(from: 0).whenComplete(() {
            setState(() {
              notifier.addNumber(
                playerIndex,
                true,
                newPlayerLinesCalculator!.newLineCoordinates,
              );
              newPlayerLinesCalculator = null;
            });
          });
        }

        void addLiquor() {
          if (controller.isAnimating) return;
          final playerIndex = state.playerIndex;

          newPlayerLinesCalculator = notifier.getPlayerLinesCalculator(false);
          if (newPlayerLinesCalculator == null) {
            showSnackBar(
              context: context,
              content: "Víc jak 20 paňáků nelze načárkovat!",
            );
            return;
          }

          controller.forward(from: 0).whenComplete(() {
            setState(() {
              notifier.addNumber(
                playerIndex,
                false,
                newPlayerLinesCalculator!.newLineCoordinates,
              );
              newPlayerLinesCalculator = null;
            });
          });
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
          children: [
            _PaintPlayerSwitcher(
              playerName: player.name,
              currentIndex: idx + 1,
              totalCount: totalPlayers,
              onPrev: notifier.prevPlayer,
              onNext: notifier.nextPlayer,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(80),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
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
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const BeerPaintHint(),
            const SizedBox(height: 6),
          ],
        );
      },
    );
  }
}

class _PaintPlayerSwitcher extends StatelessWidget {
  final String playerName;
  final int currentIndex;
  final int totalCount;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _PaintPlayerSwitcher({
    required this.playerName,
    required this.currentIndex,
    required this.totalCount,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 5),
            color: Colors.black12,
          ),
        ],
      ),
      child: Row(
        children: [
          _ArrowCircleButton(
            icon: Icons.arrow_back_rounded,
            onTap: onPrev,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                Text(
                  playerName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$currentIndex / $totalCount',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _ArrowCircleButton(
            icon: Icons.arrow_forward_rounded,
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

class _ArrowCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ArrowCircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.orange.withAlpha(18),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            color: orangeColor,
            size: 24,
          ),
        ),
      ),
    );
  }
}
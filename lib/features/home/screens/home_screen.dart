import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widgets/chart/home_chart.dart';
import '../../../common/widgets/pick_chart_player.dart';
import '../../../common/widgets/random_fact_box.dart';
import '../../../common/widgets/loader.dart';
import '../../../models/api/home/home_setup.dart';
import '../../../models/pkfl/pkfl_match.dart';
import '../../general/error/api_executor.dart';
import '../controller/home_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const double padding = 20;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return FutureBuilder<HomeSetup?>(
        //future: ref.read(homeControllerProvider).setupHome(),
      future: executeApi<HomeSetup?>(() async {
        return await ref.read(homeControllerProvider).setupHome();
      },() => setState(() {

      }), context, false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return const Loader();
          } else if (snapshot.hasError) {
            Future.delayed(
                Duration.zero,
                () => showErrorDialog(snapshot.error!.toString(),
                    () => setState(() {}), context));
            return const Loader();
          }
          HomeSetup homeSetup = snapshot.data!;
          return SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/nazev.png',
                      height: 76,
                      width: 331,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      margin: const EdgeInsets.all(5.0),
                      padding: const EdgeInsets.all(3.0),
                      width: size.width - padding * 2,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black54)),
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            const Text('Příští zápas Trusu:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                )),
                            FutureBuilder<PkflMatch?>(
                                future: ref
                                    .read(homeControllerProvider)
                                    .getNextPkflMatch(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Loader();
                                  }
                                  var pkflMatch = snapshot.data;
                                  return Text(
                                    pkflMatch?.toStringForHomeScreen() ??
                                        "Zatím neznámý",
                                    textAlign: TextAlign.center,
                                  );
                                }),
                          ],
                        ),
                      )),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      padding: const EdgeInsets.all(3.0),
                      width: size.width - padding * 2,
                      child: Center(
                          child: Row(
                        children: [
                          const Icon(
                            Icons.cake,
                            color: orangeColor,
                            size: 40,
                          ),
                          Flexible(
                            child: Text(
                              homeSetup.nextBirthday,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      )),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    homeSetup.chart != null
                        ? (homeSetup.chart!.coordinates.isNotEmpty
                            ? HomeChart(
                                chart: homeSetup.chart!,
                              )
                            : Container())
                        : PickChartPlayer(
                            size: size,
                            padding: padding,
                            onPlayerSelected: (player) => ref.watch(homeControllerProvider).setupPlayerId(player.id!).whenComplete(() => setState(() {ref.read(homeControllerProvider).playerId = player.id!;})),
                          ),
                    RandomFactBox(
                      padding: padding,
                      randomFactStream:
                          ref.watch(homeControllerProvider).getRandomFacts(),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}

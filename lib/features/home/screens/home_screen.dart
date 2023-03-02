import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/common/widgets/custom_button.dart';

import '../../../common/random_fact_box.dart';
import '../../../common/widgets/loader.dart';
import '../../../models/pkfl/pkfl_match.dart';
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
    ref.read(homeControllerProvider).initRandomFact();
    return Scaffold(
      body: SafeArea(
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
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.black54)),
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
                        const Icon(Icons.cake, color: orangeColor, size: 40,

                        ),
                        StreamBuilder<String>(
                            stream: ref
                                .watch(homeControllerProvider)
                                .getNextPlayerBirthday(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Loader();
                              }
                              return Flexible(
                                child: Text(snapshot.data ?? "",
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }),
                      ],
                    )),
              ),
              RandomFactBox(padding: padding, randomFactStream: ref.watch(homeControllerProvider).randomFacts(),)
            ],
          ),
        ),
      ),
    );
  }
}

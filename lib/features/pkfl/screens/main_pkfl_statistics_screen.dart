import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/models/enum/spinner_options.dart';
import 'package:trus_app/models/helper/percentage_loader_model.dart';
import 'package:trus_app/models/pkfl/pkfl_player_stats.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widgets/custom_text.dart';
import '../../../common/widgets/dropdown/pkfl_stats_dropdown.dart';
import '../../../common/widgets/icon_text_field.dart';
import '../controller/pkfl_stats_controller.dart';

class MainPkflStatisticsScreen extends ConsumerStatefulWidget {
  const MainPkflStatisticsScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<MainPkflStatisticsScreen> createState() =>
      _MainPkflStatisticsScreenState();
}

class _MainPkflStatisticsScreenState
    extends ConsumerState<MainPkflStatisticsScreen> {
  SpinnerOption? selectedValue;
  bool orderDescending = true;
  bool currentSeason = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void setSelectedSpinnerOption(SpinnerOption option) {
    selectedValue = option;
    updatePlayerStats();
  }

  void updatePlayerStats() {
    ref.read(pkflStatsControllerProvider).setPkflPlayerStats(
        currentSeason,
        selectedValue ?? SpinnerOption.values[0],
        orderDescending,
        _searchController.text);
  }

  void onTabChanged(int tab) {
    if (tab == 0) {
      currentSeason = true;
    } else {
      currentSeason = false;
    }
    updatePlayerStats();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(pkflStatsControllerProvider).snackBar().listen((event) {
      showSnackBar(context: context, content: event);
    });
    final size = MediaQuery.of(context).size;
    const double padding = 8.0;
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            toolbarHeight: 0,
            bottom: TabBar(
              onTap: (tab) => onTabChanged(tab),
              labelColor: blackColor,
              indicatorColor: orangeColor,
              tabs: [
                FittedBox(
                    child: Tab(
                  child: CustomText(text: "Aktuální sezona"),
                )),
                FittedBox(
                    child: Tab(
                  child: CustomText(text: "Všechny zápasy"),
                )),
              ],
            ),
          ),
          body: Builder(
            builder: (context) {
              return StreamBuilder<bool>(
                  stream: ref.watch(pkflStatsControllerProvider).loaderData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      updatePlayerStats();
                    } else if (snapshot.data == true) {
                      //updatePlayerStats();
                      return StreamBuilder<PercentageLoaderModel>(
                          stream: ref
                              .watch(pkflStatsControllerProvider)
                              .loaderTextData(),
                          builder: (context, stringSnapshot) {
                            return Center(
                              child: CircularPercentIndicator(
                                radius: 150.0,
                                lineWidth: 5.0,
                                percent: stringSnapshot.data?.percentage ?? 0.0,
                                center: Text(
                                    stringSnapshot.data?.text ?? "Načítám...",
                                    textAlign: TextAlign.center),
                                progressColor: Colors.green,
                              ),
                            );
                          });
                    }
                    //updatePlayerStats();
                    return Scaffold(
                      body: Padding(
                        padding: const EdgeInsets.all(padding),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                    height: 60,
                                    width: size.width / 2.5 - padding,
                                    child: PkflStatsDropdown(
                                      onValueSelected: (pickedSpinnerOption) =>
                                          {
                                        setSelectedSpinnerOption(
                                            pickedSpinnerOption!),
                                        _searchController.clear()
                                      },
                                      initValue: selectedValue,
                                    )),
                                SizedBox(
                                    width: size.width / 5,
                                    child: Center(
                                      child: IconButton(
                                        icon: (orderDescending
                                            ? const Icon(Icons.arrow_upward)
                                            : const Icon(Icons.arrow_downward)),
                                        onPressed: () {
                                          orderDescending = !orderDescending;
                                          updatePlayerStats();
                                        },
                                        color: orangeColor,
                                      ),
                                    )),
                                SizedBox(
                                    width: size.width / 2.5 - padding,
                                    child: IconTextField(
                                      textController: _searchController,
                                      labelText: "hledat",
                                      onIconPressed: () {
                                        updatePlayerStats();
                                      },
                                      icon: const Icon(Icons.search,
                                          color: blackColor),
                                    )),
                              ],
                            ),
                            StreamBuilder<List<PkflPlayerStats>>(
                                stream: ref
                                    .watch(pkflStatsControllerProvider)
                                    .pkflPlayerStats(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    updatePlayerStats();
                                  }
                                  return Expanded(
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: (snapshot.data ?? []).length,
                                      itemBuilder: (context, index) {
                                        /*players = sortStatsByDrinks(
                                          filterPlayers(snapshot.data!),
                                          orderDescending);*/
                                        var player = //players[index - 1];
                                            snapshot.data![index];
                                        return Column(
                                          children: [
                                            InkWell(
                                              onTap: () {},
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                    border: Border(
                                                        bottom: BorderSide(
                                                  color: Colors.grey,
                                                ))),
                                                child: ListTile(
                                                  title: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 16),
                                                    child: Text(
                                                      player.name,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18),
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    player
                                                        .toStringBySpinnerOption(
                                                            selectedValue ??
                                                                SpinnerOption
                                                                    .values[0]),
                                                    style: const TextStyle(
                                                        color:
                                                            listviewSubtitleColor),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        );
                                      },
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),
                    );
                  });
            },
          ),
        ),
      ),
    );
  }
}

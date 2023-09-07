import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/listview/listview_beer_add_model.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/beer/controller/beer_controller.dart';
import 'package:trus_app/features/beer/screens/beer_paint_screen.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/helper/beer_helper_model.dart';
import 'package:trus_app/models/match_model.dart';

import '../../../../common/widgets/custom_button.dart';
import '../../../colors.dart';
import '../../../common/utils/utils.dart';
import '../../../common/widgets/builder/add_builder.dart';
import '../../../common/widgets/builder/error_future_builder.dart';
import '../../../common/widgets/builder/stream_add_builder.dart';
import '../../../common/widgets/button/confirm_button.dart';
import '../../../common/widgets/dropdown/match_dropdown2.dart';
import '../../../common/widgets/dropdown/match_dropdown_without_stream.dart';
import '../../../common/widgets/dropdown/season_api_dropdown.dart';
import '../../match/controller/match_controller.dart';
import '../../notification/controller/notification_controller.dart';

import 'package:http/http.dart' as http;

class BeerSimpleScreen extends ConsumerStatefulWidget {
  final VoidCallback onButtonConfirmPressed;
  final Function(MatchApiModel match) setMatch;
  final MatchApiModel mainMatch;
  final bool isFocused;
  const BeerSimpleScreen({
    Key? key,
    required this.setMatch,
    required this.mainMatch,
    required this.onButtonConfirmPressed,
    required this.isFocused,
  }) : super(key: key);

  @override
  ConsumerState<BeerSimpleScreen> createState() => _BeerSimpleScreenState();
}

class _BeerSimpleScreenState extends ConsumerState<BeerSimpleScreen> {


  @override
  Widget build(BuildContext context) {
    if (widget.isFocused) {
      final size = MediaQuery.of(context).size;
      const double padding = 0.0;
      return ErrorFutureBuilder<void>(
          future: ref
              .read(beerControllerProvider)
              .initScreen(widget.mainMatch.id),
          context: context,
          onDialogCancel: () => {widget.onButtonConfirmPressed()},
          widget: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                automaticallyImplyLeading: false,
                title: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: size.width),
                    child: MatchDropdown2(
                      onMatchSelected: (match) => ref
                          .watch(beerControllerProvider)
                          .setMatch(match),
                      matchesStream: ref
                          .watch(beerControllerProvider)
                          .matches(),
                      initMatchListStream: () => ref.read(beerControllerProvider).initMatchesStream(),
                      matchReader: ref.read(beerControllerProvider),
                    )),
              ),
              body: Padding(
                padding: const EdgeInsets.all(padding),
                child: Column(children: [
                  Row(
                    children: [
                      SizedBox(
                          width: size.width / 2 - padding,
                          child: SeasonApiDropdown(
                            onSeasonSelected: (season) => ref
                                .watch(beerControllerProvider)
                                .setSeason(season),
                            seasonList:
                            ref.watch(beerControllerProvider).getSeasons(),
                            pickedSeason:
                            ref.watch(beerControllerProvider).pickedSeason(),
                            initData: () => ref
                                .watch(beerControllerProvider)
                                .setInitSeason(),
                          )),
                      SizedBox(
                          width: size.width / 4 -padding
                      ),
                      SizedBox(
                          width: size.width / 4,
                          child: IconButton(
                            icon: const Icon(
                              Icons.compare_arrows, color: blackColor,
                            ),
                            onPressed: () { ref.read(beerControllerProvider).switchScreen();},)),

                    ],
                  ),
                  StreamBuilder<bool>(
                    stream: ref.watch(beerControllerProvider).screen(),
                    builder: (context, snapshot) {
                      if (snapshot.data?? ref.read(beerControllerProvider).isSimpleScreen) {
                        return Expanded(
                          child: StreamAddBuilder(
                            addController: ref.watch(beerControllerProvider),
                            doubleListview: true,
                          ),
                        );
                      }
                      else {
                        return const Expanded(
                          child: BeerPaintScreen(

                          ),
                        );
                      }
                    }
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ConfirmButton(
                      text: "Potvrď změny",
                      context: context,
                      confirmOperations: ref.read(beerControllerProvider),
                      onOperationComplete: () => {widget.setMatch(ref.read(beerControllerProvider).pickedMatch!), widget.onButtonConfirmPressed()},
                      id: -1,
                    ),
                  ),
                ]),
              ),
          )
      );
    } else {
      return Container();
    }
    /*final size = MediaQuery.of(context).size;
      return StreamBuilder<List<MatchModel>>(
          stream: null,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            }
            List<MatchModel> matches = snapshot.data!;
            this.matches = matches;
            if (matches.isEmpty) {
              return const Text("Nebyl nalezen žádný zápas");
            }
            matches.sort(
                    (a, b) => b.date.compareTo(a.date));
            selectedValue ??= matches[0];
            return Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  title: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: size.width),
                    child: MatchDropdownWithoutStream(
                      onMatchSelected: (matchModel) =>
                          _setNewMatch(matchModel!),
                      initMatch: selectedValue ?? matches[0],
                      matchList: matches,
                    ),
                  ),
                ),

                body: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: StreamBuilder<List<BeerHelperModel>>(
                    stream: ref
                        .watch(beerControllerProvider)
                        .beersByMatch(
                        selectedValue ?? matches[0]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Loader();
                      }
                      beers = snapshot.data!;
                      if (!commit) {
                        setNewBeerNumber(snapshot.data!.length);
                      }
                      if (ref
                          .read(beerControllerProvider)
                          .simpleScreen) {
                        return Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  var beerPlayer = snapshot.data![index];
                                  return Column(
                                    children: [
                                      InkWell(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0, left: 8, right: 8),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                                border: Border(
                                                    bottom: BorderSide(
                                                      color: Colors.grey,
                                                    ))),
                                            child: ListviewBeerAddModel(
                                              onBeerNumberChanged: (number) {
                                                beerNumber[index] = number;
                                              },
                                              onLiquorNumberChanged: (number) {
                                                liquorNumber[index] = number;
                                              },
                                              padding: 16,
                                              helperModel: beerPlayer,
                                              name: beerPlayer.player.name,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: CustomButton(
                                  text: "Přidej piva", onPressed: changeBeers),
                            ),
                          ],
                        );
                      }
                      return BeerPaintScreen(
                        beers: snapshot.data!,
                        newBeerNumber: (number) {
                          beerNumber[paintScreenPlayerIndex] = number;
                        },
                        newLiquorNumber: (number) {
                          liquorNumber[paintScreenPlayerIndex] = number;
                        },
                        pickedPlayer: (number) {
                          paintScreenPlayerIndex = number;
                        },
                        onChangeBeersPressed: changeBeers,


                      );
                    },
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () =>
                      setState(() {
                        //ref.read(beerControllerProvider).simpleScreen =! ref.read(beerControllerProvider).simpleScreen;
                        printa();
                        //simpleScreen = !simpleScreen;
                      }),
                  elevation: 4.0,

                  child: const Icon(Icons.change_circle_outlined),
                ));
          }
      );*/
  }
}

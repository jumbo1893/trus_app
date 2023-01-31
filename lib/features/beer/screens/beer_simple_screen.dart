import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/listview/listview_beer_add_model.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/common/widgets/dropdown/match_dropdown.dart';
import 'package:trus_app/features/beer/controller/beer_controller.dart';
import 'package:trus_app/models/helper/beer_helper_model.dart';
import 'package:trus_app/models/helper/fine_match_helper_model.dart';
import 'package:trus_app/models/match_model.dart';

import '../../../../common/widgets/custom_button.dart';
import '../../../common/utils/utils.dart';
import '../../../common/widgets/dropdown/match_dropdown_without_stream.dart';
import '../../../models/player_model.dart';
import '../../fine/match/controller/fine_match_controller.dart';
import '../../match/controller/match_controller.dart';

class BeerSimpleScreen extends ConsumerStatefulWidget {
  final VoidCallback onButtonConfirmPressed;
  final Function(MatchModel matchModel) setMainMatch;
  final MatchModel mainMatch;
  const BeerSimpleScreen({
    Key? key,
    required this.setMainMatch,
    required this.mainMatch,
    required this.onButtonConfirmPressed,
  }) : super(key: key);

  @override
  ConsumerState<BeerSimpleScreen> createState() => _BeerSimpleScreenState();
}

class _BeerSimpleScreenState extends ConsumerState<BeerSimpleScreen> {
  MatchModel? selectedValue; //ukládáme zde zvolený zápas ze spinneru z appbaru
  List<BeerHelperModel> beers = [];
  List<int> beerNumber = [];
  List<int> liquorNumber = [];
  List<String> matchPlayers = []; // list hráčů, kteří se účastnili zápasu

  void changeBeers() {
    showLoaderSnackBar(context: context);
    for (int i = 0; i < beerNumber.length; i++) {
      if (beerNumber[i] != -1 || liquorNumber[i] != -1) {
        addBeer(beers[i].id, beers[i].player.id, beerNumber[i] == -1 ? beers[i].beerNumber : beerNumber[i], liquorNumber[i] == -1 ? beers[i].liquorNumber : liquorNumber[i]);
      }
    }
    hideSnackBar(context);
    showSnackBar(
      context: context,
      content: "Stavy pivek a jiných pochutin úspěšně změněny",
    );
    widget.onButtonConfirmPressed.call();
  }

  Future<void> addBeer(String id, String playerId, int beerNumber, int liquorNumber) async {
    if (await ref.read(beerControllerProvider).addBeerInMatch(context, id,
        selectedValue!.id, playerId, beerNumber, liquorNumber)) {
    }
  }

  void setNewBeerNumber(int length) {
    beerNumber.clear();
    liquorNumber.clear();
    for (int i = 0; i < length; i++) {
      beerNumber.add(-1);
      liquorNumber.add(-1);
    }
  }

  void _setNewMatch(MatchModel matchModel) {
    setState(() {
      selectedValue = matchModel;
    });
    widget.setMainMatch(matchModel);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return StreamBuilder<List<MatchModel>>(
    stream: ref.watch(matchControllerProvider).matches(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Loader();
      }
      List<MatchModel> matches = snapshot.data!;
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
                  onMatchSelected: (matchModel) => _setNewMatch(matchModel!),
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
                setNewBeerNumber(snapshot.data!.length);
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
                      child: CustomButton(text: "Přidej piva", onPressed: changeBeers),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      }
    );
  }
}

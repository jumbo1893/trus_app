import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/beer/controller/beer_controller.dart';
import 'package:trus_app/features/beer/screens/beer_paint_screen.dart';
import 'package:trus_app/features/home/screens/home_screen.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import '../../../colors.dart';
import '../../../common/widgets/builder/error_future_builder.dart';
import '../../../common/widgets/builder/stream_add_builder.dart';
import '../../../common/widgets/button/confirm_button.dart';
import '../../../common/widgets/dropdown/match_dropdown.dart';
import '../../../common/widgets/dropdown/season_api_dropdown.dart';
import '../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../main/screen_controller.dart';

class BeerSimpleScreen extends CustomConsumerStatefulWidget {
  static const String id = "beer-simple-screen";

  const BeerSimpleScreen({
    Key? key,
  }) : super(key: key, title: "Přidat pivo", name: id);

  @override
  ConsumerState<BeerSimpleScreen> createState() => _BeerSimpleScreenState();
}

class _BeerSimpleScreenState extends ConsumerState<BeerSimpleScreen> {
  @override
  Widget build(BuildContext context) {
    if (ref
        .read(screenControllerProvider)
        .isScreenFocused(BeerSimpleScreen.id)) {
      final size = MediaQuery.of(context).size;
      const double padding = 0.0;
      return ErrorFutureBuilder<void>(
          future: ref
              .read(beerControllerProvider)
              .initScreen(ref.read(screenControllerProvider).matchId),
          context: context,
          widget: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: size.width),
                  child: MatchDropdown(
                    onMatchSelected: (match) =>
                        ref.watch(beerControllerProvider).setMatch(match),
                    matchesStream: ref.watch(beerControllerProvider).matches(),
                    initMatchListStream: () =>
                        ref.read(beerControllerProvider).initMatchesStream(),
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
                          initData: () =>
                              ref.watch(beerControllerProvider).setInitSeason(),
                        )),
                    SizedBox(width: size.width / 4 - padding),
                    SizedBox(
                        width: size.width / 4,
                        child: IconButton(
                          icon: const Icon(
                            Icons.compare_arrows,
                            color: blackColor,
                          ),
                          onPressed: () {
                            ref.read(beerControllerProvider).switchScreen();
                          },
                        )),
                  ],
                ),
                StreamBuilder<bool>(
                    stream: ref.watch(beerControllerProvider).screen(),
                    builder: (context, snapshot) {
                      if (snapshot.data ??
                          ref.read(beerControllerProvider).isSimpleScreen) {
                        return Expanded(
                          child: StreamAddBuilder(
                            addController: ref.watch(beerControllerProvider),
                            doubleListview: true,
                          ),
                        );
                      } else {
                        return const Expanded(
                          child: BeerPaintScreen(),
                        );
                      }
                    }),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ConfirmButton(
                    text: "Potvrď změny",
                    context: context,
                    confirmOperations: ref.read(beerControllerProvider),
                    onOperationComplete: () => {
                      ref.read(screenControllerProvider).setMatchId(
                          (ref.read(beerControllerProvider).pickedMatch!.id!)),
                      ref
                          .read(screenControllerProvider)
                          .changeFragment(HomeScreen.id)
                    },
                    id: -1,
                  ),
                ),
              ]),
            ),
          ));
    } else {
      return Container();
    }
  }
}

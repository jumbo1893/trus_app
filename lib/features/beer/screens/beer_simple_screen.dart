import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/custom_button.dart';
import 'package:trus_app/common/widgets/notifier/loader/loading_overlay.dart';
import 'package:trus_app/common/widgets/screen/custom_consumer_stateful_widget.dart';
import 'package:trus_app/features/beer/beer_screen_mode.dart';
import 'package:trus_app/features/beer/controller/beer_notifier.dart';

import '../../../common/widgets/builder/add_list_builder_double.dart';
import '../../../common/widgets/dropdown/match_dropdown_notifier.dart';
import '../../../common/widgets/notifier/dropdown/custom_dropdown.dart';
import '../../main/screen_controller.dart';
import '../../season/controller/season_dropdown_notifier.dart';
import '../../season/season_args.dart';
import 'beer_paint_screen.dart';

class BeerSimpleScreen extends CustomConsumerStatefulWidget {
  static const String id = "beer-simple-screen";

  const BeerSimpleScreen({Key? key})
      : super(key: key, title: "Přidat pivo", name: id);

  @override
  ConsumerState<BeerSimpleScreen> createState() => _BeerSimpleScreenState();
}

class _BeerSimpleScreenState extends ConsumerState<BeerSimpleScreen> {
  bool _initDone = false;

  @override
  Widget build(BuildContext context) {
    final sc = ref.read(screenControllerProvider);
    final state = ref.watch(beerNotifierProvider);
    final notifier = ref.read(beerNotifierProvider.notifier);

    if (!_initDone) {
      _initDone = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.init(matchId: sc.matchId);
      });
    }

    return LoadingOverlay(
      state: state,
      onClearError: () {},
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: state.matches.when(
            loading: () => const SizedBox(height: 24),
            error: (_, __) => const SizedBox.shrink(),
            data: (matches) => ConstrainedBox(
              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
              child: MatchDropdownNotifier(
                matches: matches,
                selected: state.selectedMatch,
                onSelected: notifier.selectMatch,
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: CustomDropdown(
                    hint: "Vyber sezonu",
                    notifier: ref.read(
                      seasonDropdownNotifierProvider(const SeasonArgs(false, true, true)).notifier,
                    ),
                    state: ref.watch(
                      seasonDropdownNotifierProvider(const SeasonArgs(false, true, true)),
                    ),
                  ),
                ),
                const Spacer(),
                TextButton(
                  
                  onPressed: notifier.toggleMode, 
                  child: Text(
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      state.mode == BeerScreenMode.list? "Přepni na čárky" :  "Přepni na klasiku"),
                ),
              ],
            ),
            Expanded(
              child: state.mode == BeerScreenMode.list
                  ? AddListBuilderDouble(
                appBarText: null,
                items: state.beers,
                onBeerAdd: (i) => notifier.addNumber(i, true, null),
                onBeerRemove: (i) => notifier.removeNumber(i, true),
                onLiquorAdd: (i) => notifier.addNumber(i, false, null),
                onLiquorRemove: (i) => notifier.removeNumber(i, false),
              )
                  : const BeerPaintScreen(),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: CustomButton(
                text: "Potvrď změny",
                onPressed: notifier.changeBeers,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

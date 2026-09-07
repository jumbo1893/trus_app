import 'package:trus_app/common/widgets/match_context_header.dart';
import '../../main/controller/screen_notifier.dart';
import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/screen/custom_consumer_stateful_widget.dart';
import 'package:trus_app/common/widgets/toggle_mode.dart';
import 'package:trus_app/features/beer/controller/beer_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';

import '../../../common/widgets/animated_filter_panel.dart';
import '../../../common/widgets/bar/bottom_bar.dart';
import '../../../common/widgets/builder/add_list_builder_double.dart';
import '../../../common/widgets/dropdown/custom_dropdown_sheet.dart';
import '../../../common/widgets/dropdown/match_dropdown_sheet.dart';
import '../../../common/widgets/filter_card.dart';
import '../../season/controller/season_dropdown_notifier.dart';
import '../../season/season_args.dart';
import '../state/beer_state.dart';
import '../widget/beer_tally_icon.dart';
import 'beer_paint_screen.dart';

class BeerSimpleScreen extends CustomConsumerStatefulWidget {
  static const String id = "beer-simple-screen";

  const BeerSimpleScreen({Key? key})
    : super(key: key, title: "Zápis piv", name: id);

  @override
  ConsumerState<BeerSimpleScreen> createState() => _BeerSimpleScreenState();
}

class _BeerSimpleScreenState extends ConsumerState<BeerSimpleScreen>
    with WidgetsBindingObserver {
  bool _initDone = false;
  late final ScrollController _scrollController;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        mounted &&
        ref.read(screenNotifierProvider).currentScreenId ==
            BeerSimpleScreen.id) {
      ref.read(beerNotifierProvider.notifier).refreshOnResume();
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final state = ref.read(beerNotifierProvider);

    if (state.drawMode) {
      if (_showFilters) {
        setState(() => _showFilters = false);
      }
      return;
    }

    final offset = _scrollController.offset;

    if (_showFilters && offset > 40) {
      setState(() => _showFilters = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  Widget _buildModeToggle(
    BuildContext context,
    BeerState state,
    BeerNotifier notifier,
  ) {
    return ToggleMode(
      secondChoice: state.drawMode,
      onChanged: notifier.toggleMode,
      firstLabel: "Seznam",
      secondLabel: "Čárkování",
      firstIcon: Icons.format_list_bulleted_rounded,
      secondIconWidget: BeerTallyIcon(
        size: 18,
        color: context.appColors.textPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sc = ref.read(screenVariablesNotifierProvider);
    final state = ref.watch(beerNotifierProvider);
    final notifier = ref.read(beerNotifierProvider.notifier);

    if (!_initDone) {
      _initDone = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.init(matchId: sc.matchId);
      });
    }

    final seasonProvider = seasonDropdownNotifierProvider(
      const SeasonArgs(false, true, true),
    );

    final modeToggle = _buildModeToggle(context, state, notifier);

    return Scaffold(
      backgroundColor: context.appColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            MatchContextHeader(
              match: state.selectedMatch,
              hasChanges: state.hasChanges,
              onChange: () {
                if (_scrollController.hasClients) _scrollController.jumpTo(0);
                setState(() => _showFilters = !_showFilters);
              },
            ),
            AnimatedFilterPanel(
              visible: _showFilters,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: FilterCard(
                  child: Column(
                    children: [
                      state.matches.when(
                        loading: () => const SizedBox(height: 72),
                        error: (_, __) => const Text(
                          'Zápasy se nepodařilo načíst. Vrať se a zkus zápis otevřít znovu.',
                        ),
                        data: (matches) => MatchDropdownSheet(
                          hint: "Vyber zápas",
                          matches: matches,
                          selected: state.selectedMatch,
                          onSelected: notifier.selectMatch,
                        ),
                      ),
                      const SizedBox(height: 12),
                      CustomDropdownSheet(
                        hint: "Vyber sezonu",
                        notifier: ref.read(seasonProvider.notifier),
                        state: ref.watch(seasonProvider),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: modeToggle,
            ),

            Expanded(
              child: state.matches.hasError
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Zápis se nepodařilo načíst.'),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: () => notifier.init(matchId: sc.matchId),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Zkusit znovu'),
                          ),
                        ],
                      ),
                    )
                  : state.matches.hasValue && state.beers.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.group_outlined, size: 40),
                            const SizedBox(height: 12),
                            Text(
                              state.selectedMatch == null
                                  ? 'V této sezoně zatím není vybraný zápas.'
                                  : 'Pro tento zápas zatím nejsou k dispozici hráči.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => ref
                                  .read(screenNotifierProvider.notifier)
                                  .changeByFragmentId('matches-hub'),
                              child: const Text('Přejít na zápasy'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : !state.drawMode
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: AddListBuilderDouble(
                        compact: true,
                        scrollController: _scrollController,
                        items: state.beers,
                        onBeerAdd: (i) => notifier.addNumber(i, true, null),
                        onBeerRemove: (i) => notifier.removeNumber(i, true),
                        onLiquorAdd: (i) => notifier.addNumber(i, false, null),
                        onLiquorRemove: (i) => notifier.removeNumber(i, false),
                      ),
                    )
                  : const Padding(
                      padding: EdgeInsets.fromLTRB(12, 8, 12, 0),
                      child: BeerPaintScreen(),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(
        enabled: state.hasChanges,
        onConfirm: () async {
          try {
            await notifier.changeBeers();
          } catch (_) {
            /* Error is shown by the notifier. */
          }
        },
      ),
    );
  }
}

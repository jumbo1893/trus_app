import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/filter_card.dart';
import 'package:trus_app/features/fine/match/controller/fine_match_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';

import '../../../../common/widgets/animated_filter_panel.dart';
import '../../../../common/widgets/dropdown/custom_dropdown_sheet.dart';
import '../../../../common/widgets/dropdown/match_dropdown_sheet.dart';
import '../../../../common/widgets/screen/custom_consumer_stateful_widget.dart';
import '../../../season/controller/season_dropdown_notifier.dart';
import '../../../season/season_args.dart';
import '../widget/fine_match_action_bar.dart';
import '../widget/fine_match_listview.dart';
import '../../../../common/widgets/toggle_mode.dart';

class FineMatchScreen extends CustomConsumerStatefulWidget {
  static const String id = "fine-match-screen";

  const FineMatchScreen({
    Key? key,
  }) : super(key: key, title: "Přidání pokut", name: id);

  @override
  ConsumerState<FineMatchScreen> createState() => _FineMatchScreenState();
}

class _FineMatchScreenState extends ConsumerState<FineMatchScreen> {
  bool _initDone = false;
  late final ScrollController _scrollController;
  bool _showFilters = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final offset = _scrollController.offset;

    if (_showFilters && offset > 40) {
      setState(() {
        _showFilters = false;
      });
    } else if (!_showFilters && offset <= 12) {
      setState(() {
        _showFilters = true;
      });
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sc = ref.read(screenVariablesNotifierProvider);
    final state = ref.watch(fineMatchNotifierProvider);
    final notifier = ref.read(fineMatchNotifierProvider.notifier);

    final seasonProvider =
    seasonDropdownNotifierProvider(const SeasonArgs(false, true, true));

    if (!_initDone) {
      _initDone = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.init(matchId: sc.matchId);
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AnimatedFilterPanel(
              visible: _showFilters,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: FilterCard(
                  child: Column(
                    children: [
                      state.matches.when(
                        loading: () => const SizedBox(height: 72),
                        error: (_, __) => const SizedBox.shrink(),
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
                      const SizedBox(height: 12),
                      ToggleMode(
                        firstLabel: "Jeden hráč",
                        firstIcon: Icons.person,
                        secondLabel: "Více hráčů",
                        secondIcon: Icons.checklist_rounded,
                        secondChoice: state.multiCheck,
                        onChanged: notifier.switchScreen,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: FineMatchListview(
                  scrollController: _scrollController,
                  checkedPlayers: state.checkedPlayers,
                  multiselect: state.multiCheck,
                  onPlayerChecked: (player) => notifier.toggleCheckedPlayer(player),
                  onPlayerSelected: (player) => notifier.setSelectedPlayer(player),
                  players: state.allPlayers,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: state.multiCheck
          ? FineMatchActionBar(
        compact: !_showFilters,
        selectedCount: state.checkedPlayers.length,
        onSelectAll: notifier.selectAllPlayers,
        onSelectPlaying: notifier.selectPlayingPlayers,
        onSelectNotPlaying: notifier.selectNotPlayingPlayers,
        onConfirm: notifier.confirmSelection,
        onClearSelection: notifier.cleanCheckPlayers,
      )
          : null,
    );
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/notifier/safe_state_notifier.dart';
import 'package:trus_app/features/home/screens/home_screen.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/models/api/helper/redirect/redirect.dart';

import '../../../models/api/helper/redirect/redirect_api_model.dart';
import '../../beer/screens/beer_simple_screen.dart';
import '../../fine/match/screens/fine_match_screen.dart';
import '../../general/app_bar_title.dart';
import '../../general/global_variables_controller.dart';
import '../../general/screen_name.dart';
import '../../goal/screen/goal_screen.dart';
import '../../match/match_notifier_args.dart';
import '../../match/screens/add_match_screen.dart';
import '../../match/screens/match_detail_screen.dart';
import '../../match_participation/screens/match_participation_screen.dart';
import '../../player/screens/view_player_screen.dart';
import '../../player/screens/add_player_screen.dart';
import '../../match_participation/participation_flow.dart';
import '../screens.dart';
import '../state/screen_state.dart';

final screenNotifierProvider =
    StateNotifierProvider<ScreenNotifier, ScreenState>((ref) {
      return ScreenNotifier(ref: ref);
    });

class ScreenNotifier extends SafeStateNotifier<ScreenState> {
  ScreenNotifier({ref}) : super(ref, ScreenState.initial());

  int _bottomIndexFor(String screenId) {
    if (screenId == HomeScreen.id) return 0;
    if (screenId == FineMatchScreen.id) return 1;
    if (statisticScreenList.contains(screenId)) return 3;
    return 2;
  }

  //screen

  void saveScrollOffset(String screenId, double offset) {
    final next = Map<String, double>.from(state.scrollOffsets);
    next[screenId] = offset;
    state = state.copyWith(scrollOffsets: next);
  }

  double? getScrollOffset(String screenId) => state.scrollOffsets[screenId];

  // ---- navigation ----

  /// obstará logiku po kliku na zpětné tlačítko.
  void onBackButtonTap() {
    if (state.currentScreenId == GoalScreen.id) {
      final list = List<String>.from(state.backButtonFragmentList);
      if (list.isNotEmpty) list.removeLast();
      state = state.copyWith(backButtonFragmentList: list);
      changeByFragmentId(HomeScreen.id);
      return;
    }
    changeByBackButton();
  }

  void changeByFragmentId(String screenId) {
    if (state.currentScreenId == AddPlayerScreen.id &&
        screenId != AddPlayerScreen.id &&
        ref.read(pendingParticipationProvider) != null) {
      ref.read(pendingParticipationProvider.notifier).state = null;
    }
    addScreenIdToBackButtonList(screenId);
    manageBackButton(screenId);
    _changeFragment(screenId);
  }

  void changeByBackButton() {
    if (state.currentScreenId == AddPlayerScreen.id &&
        ref.read(pendingParticipationProvider) != null) {
      ref.read(pendingParticipationProvider.notifier).state = null;
    }
    List<String> backButtonFragmentList = List<String>.from(
      state.backButtonFragmentList,
    );
    if (backButtonFragmentList.isEmpty) return;
    backButtonFragmentList.removeLast();
    state = state.copyWith(backButtonFragmentList: backButtonFragmentList);
    String lastScreenId = backButtonFragmentList.isNotEmpty
        ? backButtonFragmentList.last
        : HomeScreen.id;
    manageBackButton(lastScreenId);
    _changeFragment(lastScreenId);
  }

  void addScreenIdToBackButtonList(String screenId) {
    List<String> backButtonFragmentList = List<String>.from(
      state.backButtonFragmentList,
    );
    backButtonFragmentList.add(screenId);
    state = state.copyWith(backButtonFragmentList: backButtonFragmentList);
  }

  void manageBackButton(String screenId) {
    List<String> backButtonFragmentList = List<String>.from(
      state.backButtonFragmentList,
    );
    if (screenId == HomeScreen.id) {
      backButtonFragmentList.clear();
      state = state.copyWith(backButtonFragmentList: backButtonFragmentList);
    }
    if (backButtonFragmentList.isEmpty) {
      state = state.copyWith(backButtonVisible: false);
    } else {
      state = state.copyWith(backButtonVisible: true);
    }
  }

  void _changeFragment(String screenId) {
    final idx = getFragmentNumberByFragmentId(screenId);
    final bottomIndex = _bottomIndexFor(screenId);

    final isHome = screenId == HomeScreen.id;
    final title = isHome ? "" : _titleFor(screenId);

    safeSetState(
      state.copyWith(
        currentScreenId: screenId,
        currentPageIndex: idx,
        selectedBottomSheetIndex: bottomIndex,

        showPlayerStatsTitle: isHome,
        appBarTitleText: title,
      ),
    );
  }

  String _titleFor(String screenId) {
    Widget widget = getFragmentByFragmentId(screenId);
    if (widget is AppBarTitle) {
      return (widget as AppBarTitle).appBarTitle();
    }
    return "Trus |";
  }

  Widget getFragmentByFragmentId(String fragmentId) {
    return widgetList.firstWhere(
      (w) => (w as ScreenName).screenName() == fragmentId,
      orElse: () => widgetList[0],
    );
  }

  int getFragmentNumberByFragmentId(String fragmentId) {
    final screen = getFragmentByFragmentId(fragmentId);
    return widgetList.indexOf(screen);
  }

  void redirect(RedirectApiModel redirect) {
    if (redirect.match != null) {
      ref
          .read(screenVariablesNotifierProvider.notifier)
          .setMatch(redirect.match!);
      ref
          .read(screenVariablesNotifierProvider.notifier)
          .setMatchId(redirect.match!.id!);
    }
    if (redirect.player != null) {
      ref
          .read(screenVariablesNotifierProvider.notifier)
          .setPlayer(redirect.player!);
    }
    if (redirect.footballMatch != null) {
      ref
          .read(screenVariablesNotifierProvider.notifier)
          .setFootballMatch(redirect.footballMatch!);
    }
    if (redirect.season != null) {
      ref
          .read(screenVariablesNotifierProvider.notifier)
          .setSeason(redirect.season!);
    }
    chooseRedirect(redirect.redirect);
  }

  void chooseRedirect(Redirect? redirect) {
    switch (redirect) {
      case Redirect.playerBeerStats:
        changeByFragmentId(BeerSimpleScreen.id);
      case Redirect.matchWithPlayerBottomsheet:
        final appTeam = ref.read(globalVariablesControllerProvider).appTeam;
        final footballMatch = ref
            .read(screenVariablesNotifierProvider)
            .footballMatch;
        if (footballMatch == null) return;
        final matchId =
            footballMatch.findMatchIdForCurrentAppTeamInMatchIdAndAppTeamIdList(
              appTeam,
            ) ??
            -1;

        if (matchId == -1) {
          ref
              .read(screenVariablesNotifierProvider.notifier)
              .setMatchNotifierArgs(
                MatchNotifierArgs.newByFootballMatchWithBottomSheet(
                  footballMatch,
                ),
              );
          changeFragment(AddMatchScreen.id);
        } else {
          ref
              .read(screenVariablesNotifierProvider.notifier)
              .setMatchNotifierArgs(
                MatchNotifierArgs.editWithBottomSheet(matchId),
              );
          changeFragment(MatchDetailScreen.id);
        }
      case Redirect.matchParticipation:
        final footballMatch = ref
            .read(screenVariablesNotifierProvider)
            .footballMatch;
        if (footballMatch?.id == null) return;
        ref
            .read(screenVariablesNotifierProvider.notifier)
            .setFootballMatchId(footballMatch!.id!);
        changeByFragmentId(MatchParticipationScreen.id);
      case Redirect.playerFineStats:
        // TODO: Handle this case.
        throw UnimplementedError();
      case null:
        return;
      case Redirect.viewPlayer:
        changeByFragmentId(ViewPlayerScreen.id);
    }
  }

  Widget get currentWidget => getFragmentByFragmentId(state.currentScreenId);
}

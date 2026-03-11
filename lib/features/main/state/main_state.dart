import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/main/main_ui_event_type.dart';

import '../../../models/api/achievement/achievement_detail.dart';
import '../../../models/api/player/stats/player_stats.dart';
import '../../home/screens/home_screen.dart';

class MainState {
  final AsyncValue<PlayerStats> playerStats;
  final int? currentPlayerId;
  final bool wsConnected;
  final String userName;
  final MainUiEventType? uiEvent;
  final int selectedBottomSheetIndex;
  final bool backButtonVisible;
  final List<String> backButtonFragmentList;
  final bool showPlayerStatsTitle;
  final String appBarTitleText;
  //snackbar
  final String? snackBarMessage;

  //error
  final String? errorMessage;

  //screen
  final String currentScreenId;
  final int currentPageIndex;
  final Map<String, double> scrollOffsets;


  MainState({
    required this.playerStats,
    required this.currentPlayerId,
    required this.wsConnected,
    required this.userName,
    required this.uiEvent,
    required this.selectedBottomSheetIndex,
    required this.backButtonVisible,
    required this.backButtonFragmentList,
    required this.showPlayerStatsTitle,
    required this.appBarTitleText,

    this.snackBarMessage,

    this.errorMessage,

    required this.currentScreenId,
    required this.currentPageIndex,
    required this.scrollOffsets,
  });

  factory MainState.initial() => MainState(
    playerStats: const AsyncValue.loading(),
    currentPlayerId: null,
    wsConnected: false,
    userName: "Uživatel neznámý trouba",
    uiEvent: null,
    selectedBottomSheetIndex: 0,
    backButtonVisible: false,
    backButtonFragmentList: const [],
    showPlayerStatsTitle: true,
    appBarTitleText: "",
    currentPageIndex: 0,
    currentScreenId: HomeScreen.id,
    scrollOffsets: const {},
  );

  MainState copyWith({
    AsyncValue<PlayerStats>? playerStats,
    AchievementDetail? selectedAchievement,
    int? currentPlayerId,
    bool? wsConnected,
    String? userName,
    MainUiEventType? uiEvent,
    int? selectedBottomSheetIndex,
    bool? backButtonVisible,
    List<String>? backButtonFragmentList,
    bool? showPlayerStatsTitle,
    String? appBarTitleText,
    String? errorMessage,
    String? snackBarMessage,
    int? currentPageIndex,
    String? currentScreenId,
    Map<String, double>? scrollOffsets,
  }) {
    return MainState(
      playerStats: playerStats ?? this.playerStats,
      currentPlayerId: currentPlayerId ?? this.currentPlayerId,
      wsConnected: wsConnected ?? this.wsConnected,
      userName: userName ?? this.userName,
      uiEvent: uiEvent ?? this.uiEvent,
      selectedBottomSheetIndex: selectedBottomSheetIndex ?? this.selectedBottomSheetIndex,
      backButtonVisible: backButtonVisible ?? this.backButtonVisible,
      backButtonFragmentList: backButtonFragmentList ?? this.backButtonFragmentList,
      showPlayerStatsTitle: showPlayerStatsTitle ?? this.showPlayerStatsTitle,
      appBarTitleText: appBarTitleText ?? this.appBarTitleText,
      errorMessage: errorMessage ?? this.errorMessage,
      snackBarMessage: snackBarMessage ?? this.snackBarMessage,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      currentScreenId: currentScreenId ?? this.currentScreenId,
      scrollOffsets: scrollOffsets ?? this.scrollOffsets,
    );
  }
}


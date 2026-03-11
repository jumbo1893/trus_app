import '../../home/screens/home_screen.dart';

class ScreenState {
  final int selectedBottomSheetIndex;
  final bool backButtonVisible;
  final List<String> backButtonFragmentList;
  final bool showPlayerStatsTitle;
  final String appBarTitleText;

  //screen
  final String currentScreenId;
  final int currentPageIndex;
  final Map<String, double> scrollOffsets;

  ScreenState({
    required this.selectedBottomSheetIndex,
    required this.backButtonVisible,
    required this.backButtonFragmentList,
    required this.showPlayerStatsTitle,
    required this.appBarTitleText,
    required this.currentScreenId,
    required this.currentPageIndex,
    required this.scrollOffsets,
  });

  factory ScreenState.initial() => ScreenState(
        selectedBottomSheetIndex: 0,
        backButtonVisible: false,
        backButtonFragmentList: const [],
        showPlayerStatsTitle: true,
        appBarTitleText: '',
        currentPageIndex: 0,
        currentScreenId: HomeScreen.id,
        scrollOffsets: const {},
      );

  ScreenState copyWith({
    int? selectedBottomSheetIndex,
    bool? backButtonVisible,
    List<String>? backButtonFragmentList,
    bool? showPlayerStatsTitle,
    String? appBarTitleText,
    int? currentPageIndex,
    String? currentScreenId,
    Map<String, double>? scrollOffsets,
  }) {
    return ScreenState(
      selectedBottomSheetIndex:
          selectedBottomSheetIndex ?? this.selectedBottomSheetIndex,
      backButtonVisible: backButtonVisible ?? this.backButtonVisible,
      backButtonFragmentList:
          backButtonFragmentList ?? this.backButtonFragmentList,
      showPlayerStatsTitle: showPlayerStatsTitle ?? this.showPlayerStatsTitle,
      appBarTitleText: appBarTitleText ?? this.appBarTitleText,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      currentScreenId: currentScreenId ?? this.currentScreenId,
      scrollOffsets: scrollOffsets ?? this.scrollOffsets,
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_notifier.dart';
import 'package:trus_app/features/general/notifier/app_notifier.dart';
import 'package:trus_app/features/season/controller/season_dropdown_notifier.dart';
import 'package:trus_app/features/statistics/repository/stats_api_service.dart';
import 'package:trus_app/features/statistics/stats_level.dart';
import 'package:trus_app/models/api/goal/goal_detailed_model.dart';
import 'package:trus_app/models/api/interfaces/detailed_response_model.dart';
import 'package:trus_app/models/api/receivedfine/received_fine_detailed_model.dart';
import 'package:trus_app/models/api/receivedfine/stats/received_fine_stats_detail_models.dart';
import 'package:trus_app/models/api/season_api_model.dart';
import 'package:trus_app/models/helper/title_and_text.dart';

import '../../../common/widgets/notifier/dropdown/dropdown_state.dart';
import '../../../config.dart';
import '../../../models/api/attendance/attendance_detailed_model.dart';
import '../../../models/api/beer/beer_detailed_model.dart';
import '../../../models/api/interfaces/model_to_string.dart';
import '../stat_args.dart';
import '../state/stats_state.dart';

final statsNotifierProvider = StateNotifierProvider.autoDispose
    .family<StatsNotifier, StatsState, StatsArgs>((ref, args) {
  return StatsNotifier(
    ref: ref,
    statsApiService: ref.read(statsApiServiceProvider),
    api: args.api,
    matchOrPlayer: args.matchOrPlayer,
  );
});

class StatsNotifier extends AppNotifier<StatsState>
    implements  IListviewNotifier {
  final StatsApiService statsApiService;

  StatsNotifier({
    required Ref ref,
    required this.statsApiService,
    required String api,
    required bool matchOrPlayer,
  }) : super(ref, StatsState.initial(api, matchOrPlayer)) {
    ref.listen<DropdownState>(
        seasonDropdownNotifierProvider(statisticsSeasonArgs),
            (_, next) {
          SeasonApiModel? season = next.selected as SeasonApiModel?;
          if (season != null) {
            clearFilter();
            Future.microtask(() => _loadRootStats(season.id!));
          }
        }, fireImmediately: true);
  }

  Future<void> _loadRootStats(int seasonId) async {
    state = state.copyWith(
      stats: const AsyncValue.loading(),
      overall: const AsyncValue.loading(),
      level: StatsLevel.root,
    );
    final response = await runUiWithResult<DetailedResponseModel>(
          () => statsApiService.getDetailedStats(
        null,
        seasonId,
        null,
        state.matchOrPlayer,
        state.filter,
        null,
        state.api,
      ),
      showLoading: false,
      successSnack: null,
    );
    _applyResponse(response);
  }

  Future<void> loadDetail(ModelToString modelToString) async {
    final selectedSeason = ref
        .read(
      seasonDropdownNotifierProvider(
        statisticsSeasonArgs,
      ),
    )
        .selected as SeasonApiModel?;

    if (selectedSeason == null) {
      return;
    }

    final selectedId = _getSelectedModelId(
      state.matchOrPlayer,
      modelToString,
    );

    final titleAndText = getOverallDetail(
      state.matchOrPlayer,
      modelToString,
      selectedSeason,
      null,
    );

    if (state.api == receivedFineApi) {
      await _loadReceivedFineDetail(
        selectedId: selectedId,
        seasonId: selectedSeason.id!,
        titleAndText: titleAndText,
      );
      return;
    }

    final response = await runUiWithResult<DetailedResponseModel>(
          () => statsApiService.getDetailedStats(
        state.matchOrPlayer ? selectedId : null,
        selectedSeason.id!,
        state.matchOrPlayer ? null : selectedId,
        !state.matchOrPlayer,
        null,
        null,
        state.api,
      ),
      loadingMessage: "Načítám detail statistik…",
      showLoading: true,
      successSnack: null,
    );

    ui.showStatsBottomSheet(
      titleAndText.title,
      titleAndText.text,
      response.modelList(),
    );
  }

  Future<void> _loadReceivedFineDetail({
    required int selectedId,
    required int seasonId,
    required TitleAndText titleAndText,
  }) async {
    final ReceivedFineStatsDetailResponse response;

    if (state.matchOrPlayer) {
      response = await runUiWithResult<ReceivedFineMatchDetailResponse>(
            () => statsApiService.getReceivedFineMatchDetail(selectedId),
        loadingMessage: "Načítám detail pokut…",
        showLoading: true,
        successSnack: null,
      );
    } else {
      response = await runUiWithResult<ReceivedFinePlayerDetailResponse>(
            () => statsApiService.getReceivedFinePlayerDetail(selectedId, seasonId),
        loadingMessage: "Načítám detail pokut…",
        showLoading: true,
        successSnack: null,
      );
    }

    ui.showFineStatsBottomSheet(
      titleAndText.title,
      titleAndText.text,
      response,
    );
  }

  int _getSelectedModelId(bool matchOrPlayer, ModelToString modelToString) {
    if (state.api == beerApi) {
      BeerDetailedModel model = modelToString as BeerDetailedModel;
      return matchOrPlayer ? model.match!.id! : model.player!.id!;
    } else if (state.api == goalApi) {
      GoalDetailedModel model = modelToString as GoalDetailedModel;
      return matchOrPlayer ? model.match!.id! : model.player!.id!;
    } else if (state.api == receivedFineApi) {
      ReceivedFineDetailedModel model =
      modelToString as ReceivedFineDetailedModel;
      return matchOrPlayer ? model.match!.id! : model.player!.id!;
    }
    else if (state.api == attendanceApi) {
      AttendanceDetailedModel model = modelToString as AttendanceDetailedModel;
      return state.matchOrPlayer ? model.match!.id! : model.player!.id!;
    }
    return -1;
  }

  TitleAndText getOverallDetail(bool matchOrPlayer, ModelToString modelToString,
      SeasonApiModel season, ModelToString? firstDetailModel) {
    if (state.api == beerApi) {
      BeerDetailedModel model = modelToString as BeerDetailedModel;
      if (matchOrPlayer) {
        return TitleAndText(
            title: "Piva v zápase:", text: model.match!.listViewTitle());
      }
      return TitleAndText(
          title: "Piva hráče ${model.player!.listViewTitle()}:",
          text: "v sezoně ${season.listViewTitle()}");
    } else if (state.api == goalApi) {
      GoalDetailedModel model = modelToString as GoalDetailedModel;
      if (matchOrPlayer) {
        return TitleAndText(
            title: "Góly v zápase:", text: model.match!.listViewTitle());
      }
      return TitleAndText(
          title: "Góly hráče ${model.player!.listViewTitle()}:",
          text: "v sezoně ${season.listViewTitle()}");
    } else if (state.api == receivedFineApi) {
      ReceivedFineDetailedModel model =
      modelToString as ReceivedFineDetailedModel;
      if (matchOrPlayer) {
        if (firstDetailModel != null) {
          return TitleAndText(
              title:
              "Pokuty hráče ${(firstDetailModel as ReceivedFineDetailedModel).player!.listViewTitle()}:",
              text: "v zápase ${model.match!.listViewTitle()}");
        }
        return TitleAndText(
            title: "Pokuty v zápase:", text: model.match!.listViewTitle());
      }
      if (firstDetailModel != null) {
        return TitleAndText(
            title: "Pokuty hráče ${model.player!.listViewTitle()}:",
            text:
            "v zápase ${(firstDetailModel as ReceivedFineDetailedModel).match!.listViewTitle()}");
      }
      return TitleAndText(
          title: "Pokuty hráče ${model.player!.listViewTitle()}:",
          text: "v sezoně ${season.listViewTitle()}");
    }
    else if (state.api == attendanceApi) {
      AttendanceDetailedModel model = modelToString as AttendanceDetailedModel;

      if (matchOrPlayer) {
        return TitleAndText(
          title: "Účast v zápase:",
          text: model.match!.listViewTitle(),
        );
      }

      return TitleAndText(
        title: "Účast hráče ${model.player!.listViewTitle()}:",
        text: "v sezoně ${season.listViewTitle()}",
      );
    }
    return TitleAndText(title: "", text: "");
  }

  void _applyResponse(DetailedResponseModel response) {
    var models = response.modelList();

    if (!state.orderDescending) {
      models = models.reversed.toList();
    }
    TitleAndText titleAndText =
    TitleAndText(title: "Celkem:", text: response.overallStats());
    state = state.copyWith(
      stats: AsyncValue.data(models),
      overall: AsyncValue.data(titleAndText),
    );
  }

  ///pouze lokální změna
  void toggleOrder() {
    state.stats.whenData((modelList) {
      final reversed = modelList.reversed.toList();
      state = state.copyWith(
        stats: AsyncValue.data(reversed),
        orderDescending: !state.orderDescending,
      );
    });
  }

  /// API volání
  Future<void> search(String text) async {
    SeasonApiModel? season = ref
        .read(seasonDropdownNotifierProvider(statisticsSeasonArgs))
        .selected as SeasonApiModel?;
    if (season == null) return;

    final trimmed = text.trim();
    final filter = trimmed.isEmpty ? null : trimmed;
    state = state.copyWith(filter: filter);
    await _loadRootStats(season.id!);
  }

  void clearFilter() {
    state = state.copyWith(filter: "");
  }

  @override
  selectListviewItem(ModelToString model) async {
    await loadDetail(model);
  }
}

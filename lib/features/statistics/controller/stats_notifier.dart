import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_notifier.dart';
import 'package:trus_app/features/general/notifier/app_notifier.dart';
import 'package:trus_app/common/utils/season_util.dart';
import 'package:trus_app/features/statistics/repository/stats_api_service.dart';
import 'package:trus_app/features/statistics/stats_level.dart';
import 'package:trus_app/models/api/goal/goal_detailed_model.dart';
import 'package:trus_app/models/api/interfaces/detailed_response_model.dart';
import 'package:trus_app/models/api/receivedfine/received_fine_detailed_model.dart';
import 'package:trus_app/models/api/receivedfine/stats/received_fine_stats_detail_models.dart';
import 'package:trus_app/models/api/season_api_model.dart';
import 'package:trus_app/models/helper/title_and_text.dart';

import '../filter/statistics_filter.dart';
import '../filter/statistics_filter_options.dart';
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
    implements IListviewNotifier {
  final StatsApiService statsApiService;
  Timer? _searchDebounce;
  int _requestGeneration = 0;
  bool _initialized = false;
  List<SeasonApiModel> _seasons = [];

  StatsNotifier({
    required Ref ref,
    required this.statsApiService,
    required String api,
    required bool matchOrPlayer,
  }) : super(ref, StatsState.initial(api, matchOrPlayer)) {
    ref.listen<AsyncValue<List<SeasonApiModel>>>(
      statisticsSeasonsProvider,
      (_, next) => next.when(
        loading: () {},
        error: (error, stack) => Future.microtask(() {
          if (mounted && !_initialized) {
            state = state.copyWith(stats: AsyncValue.error(error, stack));
          }
        }),
        data: (seasons) {
          _seasons = seasons;
          if (_initialized) return;
          _initialized = true;
          Future.microtask(() {
            if (!mounted) return;
            final id = seasons.isEmpty ? null : returnCurrentSeason(seasons).id;
            applyFilters(StatisticsFilter(seasonIds: {if (id != null) id}));
          });
        },
      ),
      fireImmediately: true,
    );
  }

  Future<void> _loadRootStats() async {
    final generation = ++_requestGeneration;
    state = state.copyWith(
      stats: const AsyncValue.loading(),
      overall: const AsyncValue.loading(),
      level: StatsLevel.root,
    );
    try {
      final response = await statsApiService.getDetailedStats(
        null,
        null,
        null,
        state.matchOrPlayer,
        state.filter,
        null,
        state.api,
        advancedFilter: state.advancedFilter,
      );
      if (mounted && generation == _requestGeneration) _applyResponse(response);
    } catch (error, stack) {
      if (mounted && generation == _requestGeneration) {
        state = state.copyWith(
          stats: AsyncValue.error(error, stack),
          overall: AsyncValue.error(error, stack),
        );
      }
    }
  }

  Future<void> loadDetail(ModelToString modelToString) async {
    final filters = state.advancedFilter;
    final seasonNames = _seasons
        .where((season) => filters.seasonIds.contains(season.id))
        .map((season) => season.name)
        .join(', ');

    final selectedId = _getSelectedModelId(state.matchOrPlayer, modelToString);

    final titleAndText = getOverallDetail(
      state.matchOrPlayer,
      modelToString,
      '${seasonNames.isEmpty ? 'Všechny sezony' : seasonNames}'
      '${filters.opponentNames.isEmpty ? '' : ' · ${filters.opponentNames.join(', ')}'}',
      null,
    );

    if (state.api == receivedFineApi) {
      await _loadReceivedFineDetail(
        selectedId: selectedId,
        filters: filters,
        titleAndText: titleAndText,
      );
      return;
    }

    final response = await runUiWithResult<DetailedResponseModel>(
      () => statsApiService.getDetailedStats(
        state.matchOrPlayer ? selectedId : null,
        null,
        state.matchOrPlayer ? null : selectedId,
        !state.matchOrPlayer,
        null,
        null,
        state.api,
        advancedFilter: filters,
      ),
      loadingMessage: "Načítám detail statistik…",
      showLoading: true,
      successSnack: null,
    );

    if (!mounted) return;
    ui.showStatsBottomSheet(
      titleAndText.title,
      titleAndText.text,
      response.modelList(),
    );
  }

  Future<void> _loadReceivedFineDetail({
    required int selectedId,
    required StatisticsFilter filters,
    required TitleAndText titleAndText,
  }) async {
    final ReceivedFineStatsDetailResponse response;

    if (state.matchOrPlayer) {
      response = await runUiWithResult<ReceivedFineMatchDetailResponse>(
        () => statsApiService.getReceivedFineMatchDetail(
          selectedId,
          advancedFilter: filters,
        ),
        loadingMessage: "Načítám detail pokut…",
        showLoading: true,
        successSnack: null,
      );
    } else {
      response = await runUiWithResult<ReceivedFinePlayerDetailResponse>(
        () => statsApiService.getReceivedFinePlayerDetail(
          selectedId,
          null,
          advancedFilter: filters,
        ),
        loadingMessage: "Načítám detail pokut…",
        showLoading: true,
        successSnack: null,
      );
    }

    if (!mounted) return;
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
    } else if (state.api == attendanceApi) {
      AttendanceDetailedModel model = modelToString as AttendanceDetailedModel;
      return state.matchOrPlayer ? model.match!.id! : model.player!.id!;
    }
    return -1;
  }

  TitleAndText getOverallDetail(
    bool matchOrPlayer,
    ModelToString modelToString,
    String periodDescription,
    ModelToString? firstDetailModel,
  ) {
    if (state.api == beerApi) {
      BeerDetailedModel model = modelToString as BeerDetailedModel;
      if (matchOrPlayer) {
        return TitleAndText(
          title: "Piva v zápase:",
          text: model.match!.listViewTitle(),
        );
      }
      return TitleAndText(
        title: "Piva hráče ${model.player!.listViewTitle()}:",
        text: periodDescription,
      );
    } else if (state.api == goalApi) {
      GoalDetailedModel model = modelToString as GoalDetailedModel;
      if (matchOrPlayer) {
        return TitleAndText(
          title: "Góly v zápase:",
          text: model.match!.listViewTitle(),
        );
      }
      return TitleAndText(
        title: "Góly hráče ${model.player!.listViewTitle()}:",
        text: periodDescription,
      );
    } else if (state.api == receivedFineApi) {
      ReceivedFineDetailedModel model =
          modelToString as ReceivedFineDetailedModel;
      if (matchOrPlayer) {
        if (firstDetailModel != null) {
          return TitleAndText(
            title:
                "Pokuty hráče ${(firstDetailModel as ReceivedFineDetailedModel).player!.listViewTitle()}:",
            text: "v zápase ${model.match!.listViewTitle()}",
          );
        }
        return TitleAndText(
          title: "Pokuty v zápase:",
          text: model.match!.listViewTitle(),
        );
      }
      if (firstDetailModel != null) {
        return TitleAndText(
          title: "Pokuty hráče ${model.player!.listViewTitle()}:",
          text:
              "v zápase ${(firstDetailModel as ReceivedFineDetailedModel).match!.listViewTitle()}",
        );
      }
      return TitleAndText(
        title: "Pokuty hráče ${model.player!.listViewTitle()}:",
        text: periodDescription,
      );
    } else if (state.api == attendanceApi) {
      AttendanceDetailedModel model = modelToString as AttendanceDetailedModel;

      if (matchOrPlayer) {
        return TitleAndText(
          title: "Účast v zápase:",
          text: model.match!.listViewTitle(),
        );
      }

      return TitleAndText(
        title: "Účast hráče ${model.player!.listViewTitle()}:",
        text: periodDescription,
      );
    }
    return TitleAndText(title: "", text: "");
  }

  void _applyResponse(DetailedResponseModel response) {
    var models = response.modelList();

    if (!state.orderDescending) {
      models = models.reversed.toList();
    }
    TitleAndText titleAndText = TitleAndText(
      title: "Celkem:",
      text: response.overallStats(),
    );
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
    state = state.copyWith(filter: text);
    _searchDebounce?.cancel();
    ++_requestGeneration;
    _searchDebounce = Timer(const Duration(milliseconds: 300), _loadRootStats);
  }

  void clearFilter() {
    state = state.copyWith(filter: '');
    applyFilters(const StatisticsFilter());
  }

  void applyFilters(StatisticsFilter filters) {
    _searchDebounce?.cancel();
    state = state.copyWith(
      advancedFilter: filters,
      orderDescending: filters.descending,
    );
    _loadRootStats();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  selectListviewItem(ModelToString model) async {
    await loadDetail(model);
  }
}

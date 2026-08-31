import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/football/repository/football_repository.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';
import 'package:trus_app/features/goal/screen/goal_screen.dart';
import 'package:trus_app/features/home/screens/home_screen.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/features/match/match_notifier_args.dart';
import 'package:trus_app/features/match/repository/match_repository.dart';
import 'package:trus_app/features/match/state/match_edit_state.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/api/match/match_setup.dart';
import 'package:trus_app/models/api/match/match_stats.dart';
import 'package:trus_app/models/api/season_api_model.dart';
import 'package:trus_app/models/enum/match_detail_options.dart';

import '../../../../common/utils/field_validator.dart';
import '../../../../common/widgets/notifier/dropdown/i_dropdown_notifier.dart';
import '../../../../common/widgets/notifier/listview/i_listview_notifier.dart';
import '../../../../models/api/football/detail/football_match_detail.dart';
import '../../../../models/api/interfaces/dropdown_item.dart';
import '../../../../models/api/player/player_api_model.dart';
import '../../../../models/enum/crud.dart';
import '../../../general/notifier/base_crud_notifier.dart';
import '../../state/footbal_match_detail_state.dart';
import '../../state/match_stats_state.dart';
import '../match_notifier.dart';
import 'match_edit_flow_resolver.dart';
import 'match_edit_loader.dart';
import 'match_edit_state_mapper.dart';
import 'match_options_builder.dart';

final matchEditNotifierProvider = StateNotifierProvider.autoDispose
    .family<MatchEditNotifier, MatchEditState, MatchNotifierArgs>((ref, args) {
      final matchRepository = ref.read(matchRepositoryProvider);
      final footballRepository = ref.read(footballRepositoryProvider);

      return MatchEditNotifier(
        ref: ref,
        args: args,
        screenVariablesNotifier: ref.read(
          screenVariablesNotifierProvider.notifier,
        ),
        globalVariablesController: ref.read(globalVariablesControllerProvider),
        loader: MatchEditLoader(
          matchRepository: matchRepository,
          footballRepository: footballRepository,
        ),
        resolver: const MatchEditFlowResolver(),
        mapper: const MatchEditStateMapper(),
        optionsBuilder: const MatchOptionsBuilder(),
      );
    });

class MatchEditNotifier extends BaseCrudNotifier<MatchApiModel, MatchEditState>
    implements IDropdownNotifier, IListviewNotifier {
  final MatchNotifierArgs args;
  final GlobalVariablesController globalVariablesController;
  final ScreenVariablesNotifier screenVariablesNotifier;
  final MatchEditLoader loader;
  final MatchEditFlowResolver resolver;
  final MatchEditStateMapper mapper;
  final MatchOptionsBuilder optionsBuilder;

  MatchEditNotifier({
    required Ref ref,
    required this.args,
    required this.screenVariablesNotifier,
    required this.globalVariablesController,
    required this.loader,
    required this.resolver,
    required this.mapper,
    required this.optionsBuilder,
  }) : super(
         ref,
         MatchEditState(
           name: "",
           date: DateTime.now(),
           home: true,
           homeGoalNumber: null,
           awayGoalNumber: null,
           seasons: const AsyncValue.data([]),
           selectedSeason: null,
           allPlayers: const [],
           selectedPlayers: const [],
           allFans: const [],
           selectedFans: const [],
           footballMatch: null,
           matchOptions: const [],
           initialTab: args.preferredScreen,
           weather: "",
           footballMatchDetailState: FootballMatchDetailState.init(),
           matchStatsState: MatchStatsState.init(),
         ),
       ) {
    Future.microtask(() => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final flow = resolver.resolve(args);

    switch (flow) {
      case MatchFlow.createEmpty:
        await _handleCreateEmpty();
        break;

      case MatchFlow.createFromFootballMatch:
        await _handleCreateFromFootballMatch(args.footballMatchApiModel!);
        break;

      case MatchFlow.editFromHomeByMatchId:
        await _handleEditByMatchId(args.matchId!);
        break;

      case MatchFlow.openDetailByMatchId:
        await _handleOpenDetailByMatchId(args.matchId!);
        break;

      case MatchFlow.openFootballDetailOnly:
        await _handleOpenFootballDetailOnly(args.footballMatchApiModel!);
        break;

      case MatchFlow.openFootballDetailByFootballMatchId:
        await _handleOpenFootballDetailByFootballMatchId(args.footballMatchId!);
        break;

      case MatchFlow.openMutualOnly:
        await _handleOpenMutualOnly(args.footballMatchApiModel!);
        break;
    }
  }

  /// -------------------------
  /// Handlers / flows
  /// -------------------------

  Future<void> _handleCreateEmpty() async {
    state = state.copyWith(
      matchOptions: const [MatchDetailOptions.editMatch],
      initialTab: MatchDetailOptions.editMatch,
    );

    final cached = loader.cachedSetup(null);
    if (cached != null) {
      state = mapper.applySetup(state, cached);
    }

    final fresh = await runUiWithResult<MatchSetup>(
      () => loader.fetchSetup(null),
      showLoading: cached == null,
      successSnack: null,
    );

    if (!mounted) return;

    state = mapper.applySetup(state, fresh);
  }

  Future<void> _handleCreateFromFootballMatch(FootballMatchApiModel fm) async {
    state = state.copyWith(
      matchOptions: const [MatchDetailOptions.editMatch],
      initialTab: MatchDetailOptions.editMatch,
      footballMatch: fm,
    );

    final userTeamId = globalVariablesController.appTeam!.team.id;

    final cached = loader.cachedSetup(null);
    if (cached != null) {
      state = mapper.applyStateByFootballMatch(
        state,
        footballMatch: fm,
        userTeamId: userTeamId,
        setup: cached,
      );
    }

    final fresh = await runUiWithResult<MatchSetup>(
      () => loader.fetchSetup(null, footballMatchId: fm.id),
      showLoading: cached == null,
      successSnack: null,
    );

    if (!mounted) return;

    state = mapper.applyStateByFootballMatch(
      state,
      footballMatch: fm,
      userTeamId: userTeamId,
      setup: fresh,
    );
  }

  Future<void> _handleEditByMatchId(int matchId) async {
    state = state.copyWith(
      matchOptions: const [MatchDetailOptions.editMatch],
      initialTab: MatchDetailOptions.editMatch,
    );

    final cached = loader.cachedSetup(matchId);
    if (cached != null) {
      state = mapper.applySetup(state, cached);
    }

    final fresh = await runUiWithResult<MatchSetup>(
      () => loader.fetchSetup(matchId),
      showLoading: cached == null,
      successSnack: null,
    );

    if (!mounted) return;

    state = mapper.applySetup(state, fresh);
  }

  Future<void> _handleOpenDetailByMatchId(int matchId) async {
    final cached = loader.cachedSetup(matchId);
    if (cached != null) {
      _applyOpenDetailSetup(
        matchId: matchId,
        setup: cached,
        refreshDetailData: false,
      );
    }

    final fresh = await runUiWithResult<MatchSetup>(
      () => loader.fetchSetup(matchId),
      showLoading: cached == null,
      successSnack: null,
    );

    if (!mounted) return;

    _applyOpenDetailSetup(
      matchId: matchId,
      setup: fresh,
      refreshDetailData: true,
    );
  }

  Future<void> _handleOpenFootballDetailOnly(FootballMatchApiModel fm) async {
    final matchId = _matchIdFromFootballMatch(fm);

    state = state.copyWith(
      initialTab: MatchDetailOptions.footballMatchDetail,
      matchOptions: const [],
      footballMatch: fm,
    );

    _loadFootballDetail(
      fm,
      includeEditTab: false,
      includeStatsTab: matchId != null,
      refresh: true,
    );

    if (matchId != null) {
      _loadMatchStats(matchId, includeEditTab: false, refresh: true);
    }
  }

  Future<void> _handleOpenFootballDetailByFootballMatchId(
    int footballMatchId,
  ) async {
    state = state.copyWith(
      initialTab: MatchDetailOptions.footballMatchDetail,
      matchOptions: const [],
      footballMatch: null,
    );

    final cached = loader.cachedFootballDetail(footballMatchId);
    if (cached != null) {
      _applyFootballDetailFromPush(cached, refreshStats: false);
    }

    final fresh = await runUiWithResult<FootballMatchDetail>(
      () => loader.fetchFootballDetail(footballMatchId),
      loadingMessage: "Načítám zápas…",
      showLoading: cached == null,
      successSnack: null,
    );

    if (!mounted) return;

    _applyFootballDetailFromPush(fresh, refreshStats: true);
  }

  Future<void> _handleOpenMutualOnly(FootballMatchApiModel fm) async {
    final matchId = _matchIdFromFootballMatch(fm);

    state = state.copyWith(
      initialTab: MatchDetailOptions.mutualMatches,
      matchOptions: const [],
      footballMatch: fm,
    );

    _loadFootballDetail(
      fm,
      includeEditTab: false,
      includeStatsTab: matchId != null,
      refresh: true,
    );

    if (matchId != null) {
      _loadMatchStats(matchId, includeEditTab: false, refresh: true);
    }
  }

  void _applyOpenDetailSetup({
    required int matchId,
    required MatchSetup setup,
    required bool refreshDetailData,
  }) {
    state = mapper.applySetup(state, setup);

    final fm = _footballMatchFromSetup(setup);

    if (fm == null) {
      state = state.copyWith(
        matchOptions: const [MatchDetailOptions.editMatch],
        initialTab: MatchDetailOptions.editMatch,
      );
      return;
    }

    state = state.copyWith(
      initialTab: MatchDetailOptions.footballMatchDetail,
      matchOptions: const [MatchDetailOptions.editMatch],
      footballMatch: fm,
    );

    _loadFootballDetail(
      fm,
      includeEditTab: true,
      includeStatsTab: true,
      refresh: refreshDetailData,
    );

    _loadMatchStats(matchId, includeEditTab: true, refresh: refreshDetailData);
  }

  void _applyFootballDetailFromPush(
    FootballMatchDetail detail, {
    required bool refreshStats,
  }) {
    final fm = detail.footballMatch;
    final matchId = _matchIdFromFootballMatch(fm);

    state = state.copyWith(
      footballMatch: fm,
      initialTab: MatchDetailOptions.footballMatchDetail,
    );

    _applyFootballDetail(
      detail,
      includeEditTab: false,
      includeStatsTab: matchId != null,
    );

    if (matchId != null) {
      _loadMatchStats(matchId, includeEditTab: false, refresh: refreshStats);
    }
  }

  /// -------------------------
  /// Detail / stats loading
  /// -------------------------

  Future<void> _loadFootballDetail(
    FootballMatchApiModel fm, {
    required bool includeEditTab,
    required bool includeStatsTab,
    required bool refresh,
  }) async {
    final footballMatchId = fm.id;
    if (footballMatchId == null) return;

    final cached = loader.cachedFootballDetail(footballMatchId);
    if (cached != null) {
      _applyFootballDetail(
        cached,
        includeEditTab: includeEditTab,
        includeStatsTab: includeStatsTab,
      );
    }

    if (!refresh) return;

    final fresh = await runUiWithResult<FootballMatchDetail>(
      () => loader.fetchFootballDetail(footballMatchId),
      showLoading: cached == null,
      successSnack: null,
    );

    if (!mounted) return;

    _applyFootballDetail(
      fresh,
      includeEditTab: includeEditTab,
      includeStatsTab: includeStatsTab,
    );
  }

  Future<void> _loadMatchStats(
    int matchId, {
    required bool includeEditTab,
    required bool refresh,
  }) async {
    final cached = loader.cachedStats(matchId);
    if (cached != null) {
      _applyMatchStats(cached, includeEditTab: includeEditTab);
    }

    if (!refresh) return;

    final fresh = await runUiWithResult<MatchStats>(
      () => loader.fetchStats(matchId),
      showLoading: cached == null,
      successSnack: null,
    );

    if (!mounted) return;

    _applyMatchStats(fresh, includeEditTab: includeEditTab);
  }

  void _applyFootballDetail(
    FootballMatchDetail detail, {
    required bool includeEditTab,
    required bool includeStatsTab,
  }) {
    state = state.copyWith(
      footballMatchDetailState: mapper.mapFootballDetail(
        detail,
        state.footballMatchDetailState,
      ),
    );

    final computed = optionsBuilder.fromFootballDetail(
      detail,
      includeEditTab: includeEditTab,
      includeStatsTab: includeStatsTab,
    );

    state = state.copyWith(
      matchOptions: optionsBuilder.mergeOrdered(state.matchOptions, computed),
    );

    _ensureInitialTabExists();
  }

  void _applyMatchStats(MatchStats stats, {required bool includeEditTab}) {
    state = state.copyWith(
      matchStatsState: mapper.mapMatchStats(stats, state.matchStatsState),
    );

    final computed = optionsBuilder.fromFootballDetail(
      null,
      includeEditTab: includeEditTab,
      includeStatsTab: true,
    );

    state = state.copyWith(
      matchOptions: optionsBuilder.mergeOrdered(state.matchOptions, computed),
    );

    _ensureInitialTabExists();
  }

  void _ensureInitialTabExists() {
    if (state.matchOptions.isEmpty) return;

    if (!state.matchOptions.contains(state.initialTab)) {
      state = state.copyWith(initialTab: state.matchOptions.first);
    }
  }

  FootballMatchApiModel? _footballMatchFromSetup(MatchSetup setup) {
    return setup.match?.footballMatch ?? setup.footballMatch;
  }

  int? _matchIdFromFootballMatch(FootballMatchApiModel fm) {
    return fm.findMatchIdForCurrentAppTeamInMatchIdAndAppTeamIdList(
      globalVariablesController.appTeam,
    );
  }

  /// -------------------------
  /// UI actions
  /// -------------------------

  void setName(String value) {
    state = state.copyWith(name: value);
  }

  void setHome(bool home) {
    state = state.copyWith(home: home);
  }

  void setDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  void setHomeGoalNumber(String value) {
    state = state.copyWith(homeGoalNumber: int.tryParse(value));
  }

  void setAwayGoalNumber(String value) {
    state = state.copyWith(awayGoalNumber: int.tryParse(value));
  }

  void togglePlayer(player, bool fan) {
    final selected = fan ? [...state.selectedFans] : [...state.selectedPlayers];

    if (selected.any((p) => p.getId() == player.id)) {
      selected.removeWhere((p) => p.getId() == player.id);
    } else {
      selected.add(player);
    }

    state = fan
        ? state.copyWith(selectedFans: selected)
        : state.copyWith(selectedPlayers: selected);
  }

  void setSelectedPlayers(List<PlayerApiModel> players, bool fan) {
    state = fan
        ? state.copyWith(selectedFans: List.of(players))
        : state.copyWith(selectedPlayers: List.of(players));
  }

  @override
  selectDropdown(DropdownItem item) {
    state = state.copyWith(selectedSeason: item);
  }

  /// -------------------------
  /// CRUD
  /// -------------------------

  @override
  MatchApiModel buildModel() {
    return MatchApiModel(
      id: state.model?.id,
      name: state.name,
      date: state.date,
      home: state.home,
      homeGoalNumber: state.homeGoalNumber,
      awayGoalNumber: state.awayGoalNumber,
      playerIdList:
          state.selectedPlayers.map((e) => e.getId()).toList() +
          state.selectedFans.map((e) => e.getId()).toList(),
      seasonId: (state.selectedSeason as SeasonApiModel).id!,
      footballMatch: state.footballMatch,
    );
  }

  void submitCrud(Crud crud, bool goal) {
    submit(
      crud: crud,
      loadingText: switch (crud) {
        Crud.create => "Přidávám zápas…",
        Crud.update => "Upravuji zápas…",
        Crud.delete => "Mažu zápas…",
      },
      successSnack: switch (crud) {
        Crud.create => "Zápas přidán",
        Crud.update => "Zápas upraven",
        Crud.delete => "Zápas smazán",
      },
      onSuccessRedirect: HomeScreen.id,
      invalidateProvider: matchNotifierProvider,
      onSuccessAction: (model) {
        if (crud != Crud.delete && goal) {
          screenVariablesNotifier.setMatchId(model!.id!);
          screenVariablesNotifier.setMatch(model);
          changeFragment(GoalScreen.id);
        } else {
          changeFragment(HomeScreen.id);
        }
      },
    );
  }

  @override
  Future<void> create(MatchApiModel model) async {
    final matchApiModel = await loader.matchRepository.api.addMatch(model);

    state = state.copyWith(model: matchApiModel);

    loader.matchRepository.invalidateMatchSetup(null);

    if (matchApiModel.id != null) {
      loader.matchRepository.invalidateMatchSetup(matchApiModel.id);
      loader.matchRepository.invalidateMatchStats(matchApiModel.id);
    }
  }

  @override
  Future<void> update(MatchApiModel model) async {
    await loader.matchRepository.api.editMatch(model, model.id!);

    loader.matchRepository.invalidateMatchSetup(model.id);
    loader.matchRepository.invalidateMatchStats(model.id);
  }

  @override
  Future<void> delete(MatchApiModel model) async {
    await loader.matchRepository.api.deleteMatch(model.id!);

    loader.matchRepository.invalidateMatchSetup(model.id);
    loader.matchRepository.invalidateMatchStats(model.id);
  }

  /// -------------------------
  /// Validation + BaseCrud glue
  /// -------------------------

  @override
  bool validate() => _validateName();

  bool _validateName() {
    final errorText = validateEmptyField(state.name);
    state = state.copyWith(errors: {'name': errorText});
    return errorText.isEmpty;
  }

  @override
  MatchEditState copyWithState({Map<String, String>? errors}) {
    return state.copyWith(errors: errors);
  }

  @override
  selectListviewItem(ModelToString model) {
    if (model is FootballMatchApiModel) {
      screenVariablesNotifier.setMatchNotifierArgs(
        MatchNotifierArgs.footballMatchDetail(model),
      );
    }
  }
}

// lib/features/match/controller/match_edit_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/football/repository/football_repository.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';
import 'package:trus_app/features/match/match_notifier_args.dart';
import 'package:trus_app/features/match/repository/match_repository.dart';
import 'package:trus_app/features/match/state/match_edit_state.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/api/season_api_model.dart';
import 'package:trus_app/models/enum/match_detail_options.dart';

import '../../../../common/utils/field_validator.dart';
import '../../../../common/widgets/notifier/dropdown/i_dropdown_notifier.dart';
import '../../../../common/widgets/notifier/listview/i_listview_notifier.dart';
import '../../../../common/widgets/notifier/loader/loading_state.dart';
import '../../../../models/api/interfaces/dropdown_item.dart';
import '../../../general/notifier/base_crud_notifier.dart';
import '../../../general/repository/api_result.dart';
import '../../../main/screen_controller.dart';
import '../../state/footbal_match_detail_state.dart';
import 'match_edit_flow_resolver.dart';
import 'match_edit_loader.dart';
import 'match_edit_state_mapper.dart';
import 'match_options_builder.dart';

final matchEditNotifierProvider = StateNotifierProvider.autoDispose
    .family<MatchEditNotifier, MatchEditState, MatchNotifierArgs>((ref, args) {
  final matchRepository = ref.read(matchRepositoryProvider);
  final footballRepository = ref.read(footballRepositoryProvider);

  return MatchEditNotifier(
    args: args,
    screenController: ref.read(screenControllerProvider),
    globalVariablesController: ref.read(globalVariablesControllerProvider),
    loader: MatchEditLoader(matchRepository: matchRepository, footballRepository: footballRepository),
    resolver: const MatchEditFlowResolver(),
    mapper: const MatchEditStateMapper(),
    optionsBuilder: const MatchOptionsBuilder(),
  );
});

class MatchEditNotifier extends BaseCrudNotifier<MatchApiModel, MatchEditState>
    implements IDropdownNotifier, IListviewNotifier {
  final MatchNotifierArgs args;
  final GlobalVariablesController globalVariablesController;
  final ScreenController screenController;
  final MatchEditLoader loader;
  final MatchEditFlowResolver resolver;
  final MatchEditStateMapper mapper;
  final MatchOptionsBuilder optionsBuilder;

  MatchEditNotifier({
    required this.args,
    required this.screenController,
    required this.globalVariablesController,
    required this.loader,
    required this.resolver,
    required this.mapper,
    required this.optionsBuilder,
  }) : super(
    MatchEditState(
      name: "",
      date: DateTime.now(),
      home: true,
      seasons: const AsyncValue.data([]),
      selectedSeason: null,
      allPlayers: const [],
      selectedPlayers: const [],
      allFans: const [],
      selectedFans: const [],
      footballMatch: null,
      matchOptions: const [],
      initialTab: args.preferredScreen,
      footballMatchDetailState: FootballMatchDetailState.init(),
    ),
    screenController,
  ) {
    _bootstrap();
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

      case MatchFlow.openMutualOnly:
        await _handleOpenMutualOnly(args.footballMatchApiModel!);
        break;
    }
  }

  /// -------------------------
  /// Handlers (flows)
  /// -------------------------

  Future<void> _handleCreateEmpty() async {
    state = state.copyWith(
      matchOptions: const [MatchDetailOptions.editMatch],
      initialTab: MatchDetailOptions.editMatch,
      loading: state.loading.loading("Načítám zápas…"),
    );

    final cached = loader.cachedSetup(null);
    if (cached != null) {
      state = mapper.applySetup(state, cached).copyWith(
        loading: state.loading.idle(),
      );
    }

    final fresh = await loader.fetchSetup(null);
    if (!mounted) return;

    state = mapper.applySetup(state, fresh).copyWith(
      loading: state.loading.idle(),
    );
  }

  Future<void> _handleCreateFromFootballMatch(FootballMatchApiModel fm) async {
    state = state.copyWith(
      matchOptions: const [MatchDetailOptions.editMatch],
      initialTab: MatchDetailOptions.editMatch,
      loading: state.loading.loading("Načítám zápas…"),
    );

    // setup cache-first (null protože vytváříš)
    final cached = loader.cachedSetup(null);
    if (cached != null) {
      final userTeamId = globalVariablesController.appTeam!.team.id;
      state = mapper.applyStateByFootballMatch(
        state,
        footballMatch: fm,
        userTeamId: userTeamId,
        setup: cached,
      ).copyWith(loading: state.loading.idle());
    }

    final fresh = await loader.fetchSetup(null);
    if (!mounted) return;

    final userTeamId = globalVariablesController.appTeam!.team.id;
    state = mapper.applyStateByFootballMatch(
      state,
      footballMatch: fm,
      userTeamId: userTeamId,
      setup: fresh,
    ).copyWith(loading: state.loading.idle());
  }

  Future<void> _handleEditByMatchId(int matchId) async {
    state = state.copyWith(
      matchOptions: const [MatchDetailOptions.editMatch],
      initialTab: MatchDetailOptions.editMatch,
      loading: state.loading.loading("Načítám zápas…"),
    );

    final cached = loader.cachedSetup(matchId);
    if (cached != null) {
      state = mapper.applySetup(state, cached).copyWith(loading: state.loading.idle());
    }

    final fresh = await loader.fetchSetup(matchId);
    if (!mounted) return;

    state = mapper.applySetup(state, fresh).copyWith(loading: state.loading.idle());
  }

  Future<void> _handleOpenDetailByMatchId(int matchId) async {
    // otevření detailu zápasu z matchId: chceme edit + (pokud existuje footballMatch) i detaily
    state = state.copyWith(
      loading: state.loading.loading("Načítám zápas…"),
    );

    final cached = loader.cachedSetup(matchId);
    if (cached != null) {
      state = mapper.applySetup(state, cached).copyWith(loading: state.loading.idle());
      if (cached.footballMatch != null) {
        // důležité: rovnou nastav "initialTab" až když víš, že tab existuje
        state = state.copyWith(
          initialTab: MatchDetailOptions.footballMatchDetail,
          matchOptions: const [MatchDetailOptions.editMatch],
        );
        _loadFootballDetail(cached.footballMatch!, includeEditTab: true);
      } else {
        state = state.copyWith(
          matchOptions: const [MatchDetailOptions.editMatch],
          initialTab: MatchDetailOptions.editMatch,
        );
      }
    }

    final fresh = await loader.fetchSetup(matchId);
    if (!mounted) return;

    state = mapper.applySetup(state, fresh).copyWith(loading: state.loading.idle());

    if (fresh.footballMatch != null) {
      state = state.copyWith(
        initialTab: MatchDetailOptions.footballMatchDetail,
        matchOptions: const [MatchDetailOptions.editMatch],
      );
      _loadFootballDetail(fresh.footballMatch!, includeEditTab: true);
    } else {
      state = state.copyWith(
        matchOptions: const [MatchDetailOptions.editMatch],
        initialTab: MatchDetailOptions.editMatch,
      );
    }
  }

  Future<void> _handleOpenFootballDetailOnly(FootballMatchApiModel fm) async {
    // jen detail (bez edit tabu)
    state = state.copyWith(
      initialTab: MatchDetailOptions.footballMatchDetail,
      matchOptions: const [],
      loading: state.loading.loading("Načítám zápas…"),
    );
    _loadFootballDetail(fm, includeEditTab: false);
  }

  Future<void> _handleOpenMutualOnly(FootballMatchApiModel fm) async {
    // mutual jako preferovaný, ale taby se dopočítají z detailu
    state = state.copyWith(
      initialTab: MatchDetailOptions.mutualMatches,
      matchOptions: const [],
      loading: state.loading.loading("Načítám zápas…"),
    );
    _loadFootballDetail(fm, includeEditTab: false);
  }

  /// -------------------------
  /// Football detail loading
  /// -------------------------

  void _loadFootballDetail(FootballMatchApiModel fm, {required bool includeEditTab}) async {
    // lokální loading jen pro detail část (nepřekresluje celý screen zbytečně)
    state = state.copyWith(
      footballMatchDetailState: state.footballMatchDetailState.copyWith(
        loading: state.footballMatchDetailState.loading.loading("Načítám detail…"),
      ),
    );

    final cached = loader.cachedFootballDetail(fm.id!);
    if (cached != null) {
      _applyFootballDetail(cached, includeEditTab: includeEditTab);
    }

    final fresh = await loader.fetchFootballDetail(fm.id!);
    if (!mounted) return;

    _applyFootballDetail(fresh, includeEditTab: includeEditTab);
  }

  void _applyFootballDetail(detail, {required bool includeEditTab}) {
    // 1) detail data
    state = state.copyWith(
      loading: state.loading.idle(),
      footballMatchDetailState: mapper.mapFootballDetail(
        detail,
        state.footballMatchDetailState,
      ),
    );

    // 2) taby (merge bez duplicit + fix order)
    final computed = optionsBuilder.fromFootballDetail(detail, includeEditTab: includeEditTab);
    state = state.copyWith(
      matchOptions: optionsBuilder.mergeOrdered(state.matchOptions, computed),
    );

    // 3) bezpečnost: pokud preferred initial tab teď není v matchOptions → fallback
    if (!state.matchOptions.contains(state.initialTab)) {
      state = state.copyWith(initialTab: state.matchOptions.first);
    }
  }

  /// -------------------------
  /// UI actions
  /// -------------------------

  void setName(String value) => state = state.copyWith(name: value);

  void setHome(bool home) => state = state.copyWith(home: home);

  void setDate(DateTime date) => state = state.copyWith(date: date);

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

  void setSelectedPlayers(players, bool fan) {
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
      playerIdList: state.selectedPlayers.map((e) => e.getId()).toList() +
          state.selectedFans.map((e) => e.getId()).toList(),
      seasonId: (state.selectedSeason as SeasonApiModel).id!,
      footballMatch: state.footballMatch,
    );
  }

  @override
  Future<ApiResult<void>> create(MatchApiModel model) async {
    final result = await executeApi(() => loader.matchRepository.api.addMatch(model));
    loader.matchRepository.invalidateMatchSetup(null);
    return result;
  }

  @override
  Future<ApiResult<void>> update(MatchApiModel model) async {
    final result = await executeApi(
          () => loader.matchRepository.api.editMatch(model, model.id!),
    );
    loader.matchRepository.invalidateMatchSetup(model.id);
    return result;
  }

  @override
  Future<ApiResult<void>> delete(MatchApiModel model) async {
    final result =
    await executeApi(() => loader.matchRepository.api.deleteMatch(model.id!));
    loader.matchRepository.invalidateMatchSetup(model.id);
    return result;
  }

  @override
  bool validate() => _validateName();

  bool _validateName() {
    final errorText = validateEmptyField(state.name);
    state = state.copyWith(errors: {'name': errorText});
    return errorText.isEmpty;
  }

  @override
  MatchEditState copyWithState({
    LoadingState? loading,
    Map<String, String>? errors,
    String? successMessage,
  }) {
    return state.copyWith(
      loading: loading,
      errors: errors,
      successMessage: successMessage,
    );
  }

  @override
  selectListviewItem(ModelToString model) {
    if (model is FootballMatchApiModel) {
      screenController.setMatchNotifierArgs(MatchNotifierArgs.footballMatchDetail(model));
    }
  }
}

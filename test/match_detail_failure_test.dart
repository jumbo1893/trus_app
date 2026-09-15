import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/common/repository/exception/server_exception.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/features/main/ui/ui_feedback_notifier.dart';
import 'package:trus_app/features/match/controller/edit/match_edit_notifier.dart';
import 'package:trus_app/features/match/controller/edit/match_edit_loader.dart';
import 'package:trus_app/features/match/controller/edit/match_edit_flow_resolver.dart';
import 'package:trus_app/features/match/controller/edit/match_edit_state_mapper.dart';
import 'package:trus_app/features/match/controller/edit/match_options_builder.dart';
import 'package:trus_app/features/match/match_notifier_args.dart';
import 'package:trus_app/features/match/state/match_edit_state.dart';
import 'package:trus_app/models/api/auth/app_team_api_model.dart';
import 'package:trus_app/models/api/football/team_api_model.dart';
import 'package:trus_app/models/api/football/football_match_api_model.dart';
import 'package:trus_app/models/api/football/detail/football_match_detail.dart';
import 'package:trus_app/models/api/helper/long_and_long.dart';
import 'package:trus_app/models/api/match/match_stats.dart';

class _Loader implements MatchEditLoader {
  int statsRequests = 0;
  @override
  MatchStats? cachedStats(int id) => null;
  @override
  FootballMatchDetail? cachedFootballDetail(int id) => null;
  @override
  Future<MatchStats> fetchStats(int id) async {
    statsRequests++;
    throw ServerException('Statistiky dočasně nedostupné');
  }

  @override
  Future<FootballMatchDetail> fetchFootballDetail(int id) async =>
      throw ServerException('Detail dočasně nedostupný');
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'parallel detail and statistics failures are handled, not uncaught futures',
    () async {
      final loader = _Loader();
      final football = FootballMatchApiModel.noMatch();
      football.matchIdAndAppTeamIdList.add(
        LongAndLong(firstId: 3, secondId: 1),
      );
      final provider = StateNotifierProvider<MatchEditNotifier, MatchEditState>(
        (ref) {
          final globals = ref.read(globalVariablesControllerProvider);
          globals.setAppTeam(
            AppTeamApiModel(
              id: 1,
              name: 'Team',
              ownerName: '',
              team: TeamApiModel(id: 1, name: 'Team'),
            ),
          );
          return MatchEditNotifier(
            ref: ref,
            args: MatchNotifierArgs.footballMatchDetail(football),
            screenVariablesNotifier: ref.read(
              screenVariablesNotifierProvider.notifier,
            ),
            globalVariablesController: globals,
            loader: loader,
            resolver: const MatchEditFlowResolver(),
            mapper: const MatchEditStateMapper(),
            optionsBuilder: const MatchOptionsBuilder(),
          );
        },
      );
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(provider);
      await Future<void>.delayed(Duration.zero);
      expect(loader.statsRequests, 1);
      expect(container.read(uiFeedbackProvider).isLoading, isFalse);
      expect(container.read(uiFeedbackProvider).effects, hasLength(2));
    },
  );
}

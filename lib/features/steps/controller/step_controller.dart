import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/notifier/safe_state_notifier.dart';
import 'package:trus_app/features/steps/repository/health_step_service.dart';
import 'package:trus_app/features/steps/repository/step_api_service.dart';
import 'package:trus_app/features/steps/state/step_state.dart';
import 'package:trus_app/features/steps/service/step_sync_scheduler.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';
import 'package:trus_app/models/api/step/step_models.dart';

final stepControllerProvider =
    StateNotifierProvider.autoDispose<StepController, StepsState>((ref) {
      return StepController(
        ref: ref,
        api: ref.read(stepApiServiceProvider),
        health: HealthStepService(),
      );
    });

class StepController extends SafeStateNotifier<StepsState> {
  final StepApiService api;
  final HealthStepService health;

  StepController({required Ref ref, required this.api, required this.health})
    : super(ref, StepsState.initial()) {
    Future.microtask(load);
  }

  Future<void> load() async {
    final consent = await AsyncValue.guard(api.getConsent);
    if (!mounted) return;
    safeSetState(state.copyWith(consent: consent));
    if (consent.valueOrNull == true) {
      if (!await health.hasReadPermission()) {
        await api.setConsent(false);
        await ref.read(stepSyncSchedulerProvider).disable();
        if (mounted) {
          safeSetState(state.copyWith(consent: const AsyncValue.data(false)));
        }
        return;
      }
      final appTeam = ref.read(globalVariablesControllerProvider).appTeam;
      if (appTeam != null) {
        await ref.read(stepSyncSchedulerProvider).enable(appTeam.id);
      }
      await syncAndLoad();
    }
  }

  Future<void> grantConsent() async {
    safeSetState(state.copyWith(consent: const AsyncValue.loading()));
    bool granted;
    try {
      granted = await health.requestPermission();
    } catch (_) {
      if (mounted) {
        safeSetState(state.copyWith(consent: const AsyncValue.data(false)));
      }
      ui.showSnack(
        'Zdravotní data nejsou na tomto zařízení dostupná nebo nejsou správně nastavená.',
      );
      return;
    }
    if (!granted) {
      if (mounted) {
        safeSetState(state.copyWith(consent: const AsyncValue.data(false)));
      }
      ui.showSnack('Přístup ke krokům nebyl udělen.');
      return;
    }
    final enabled = await runUiWithResult(
      () => api.setConsent(true),
      loadingMessage: 'Ukládám souhlas…',
      successSnack: 'Počítání kroků bylo povoleno.',
    );
    if (!mounted) return;
    safeSetState(state.copyWith(consent: AsyncValue.data(enabled)));
    // Znovu načteme celý stav až po návratu ze systémového permission flow.
    // Obrazovka tak okamžitě přejde ze souhlasu na aktuální leaderboard.
    await load();
  }

  Future<void> revokeConsent() async {
    final enabled = await runUiWithResult(
      () => api.setConsent(false),
      loadingMessage: 'Ukládám nastavení…',
    );
    if (!mounted) return;
    await ref.read(stepSyncSchedulerProvider).disable();
    safeSetState(
      state.copyWith(
        consent: AsyncValue.data(enabled),
        leaderboard: const AsyncValue.loading(),
      ),
    );
  }

  Future<void> selectPeriod(StepPeriod period) async {
    safeSetState(state.copyWith(period: period));
    await loadLeaderboard();
  }

  void selectSortField(StepSortField field) {
    final sorting = Map<StepPeriod, StepSortConfig>.of(state.sorting);
    sorting[state.period] = state.currentSort.copyWith(field: field);
    safeSetState(state.copyWith(sorting: sorting));
  }

  void toggleSortDirection() {
    final sorting = Map<StepPeriod, StepSortConfig>.of(state.sorting);
    sorting[state.period] = state.currentSort.copyWith(
      descending: !state.currentSort.descending,
    );
    safeSetState(state.copyWith(sorting: sorting));
  }

  Future<void> syncAndLoad() async {
    if (state.syncing) return;
    safeSetState(state.copyWith(syncing: true));
    try {
      if (!await health.hasReadPermission()) {
        await api.setConsent(false);
        await ref.read(stepSyncSchedulerProvider).disable();
        if (mounted) {
          safeSetState(state.copyWith(consent: const AsyncValue.data(false)));
        }
        return;
      }
      final days = await health.readLastDays();
      await runUiWithResult(() => api.sync(days), showLoading: false);
      await ref
          .read(stepSyncSchedulerProvider)
          .recordSyncedCount(days.last.stepCount);
      await loadLeaderboard();
    } catch (error, stack) {
      if (mounted) {
        safeSetState(
          state.copyWith(leaderboard: AsyncValue.error(error, stack)),
        );
      }
    } finally {
      if (mounted) safeSetState(state.copyWith(syncing: false));
    }
  }

  Future<void> loadLeaderboard() async {
    safeSetState(state.copyWith(leaderboard: const AsyncValue.loading()));
    final result = await AsyncValue.guard(
      () => api.getLeaderboard(state.period),
    );
    if (mounted) safeSetState(state.copyWith(leaderboard: result));
  }

  Future<StepHistoryData> loadHistory({int? userId, int days = 30}) =>
      api.getHistory(userId: userId, days: days);
}

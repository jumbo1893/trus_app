import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/repository/api_result.dart';
import 'package:trus_app/features/home/repository/home_repository.dart';
import 'package:trus_app/services/crash_reporting_service.dart';
import 'package:trus_app/features/footbar/repository/footbar_repository.dart';
import 'package:trus_app/features/footbar/state/footbar_connect_state.dart';
import 'package:trus_app/features/general/notifier/safe_state_notifier.dart';
import 'package:trus_app/features/main/controller/screen_variables_notifier.dart';
import 'package:trus_app/models/api/footbar/footbar_profile.dart';

final footbarConnectNotifierProvider =
    StateNotifierProvider.autoDispose<
      FootbarConnectNotifier,
      FootbarConnectState
    >((ref) {
      return FootbarConnectNotifier(
        ref,
        ref.read(footbarRepositoryProvider),
        ref.read(screenVariablesNotifierProvider.notifier),
      );
    });

class FootbarConnectNotifier extends SafeStateNotifier<FootbarConnectState> {
  final FootbarRepository repository;
  final ScreenVariablesNotifier screenController;

  FootbarConnectNotifier(Ref ref, this.repository, this.screenController)
    : super(ref, FootbarConnectState.initial()) {
    Future.microtask(_loadProfile);
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    final cached = repository.getCachedProfile();
    if (cached != null) {
      _applySetup(cached);
    }
    try {
      final profile = await runUi<FootbarProfile>(
        () => repository.fetchProfile(),
        showLoading: (cached == null),
        successSnack: null,
      );
      if (!mounted) return;
      if (profile is ApiSuccess<FootbarProfile>) _applySetup(profile.data);
    } catch (error, stack) {
      await CrashReportingService.recordError(
        error,
        stack,
        reason: 'Footbar profile load failed',
      );
    }
  }

  void _applySetup(FootbarProfile profile) {
    state = state.copyWith(
      active: profile.active,
      nickname: profile.nickname,
      favFoot: profile.favFoot,
      favPosition: profile.favPosition,
      firstName: profile.firstName,
      lastName: profile.lastName,
      gender: profile.gender,
      dateOfBirth: profile.dateOfBirth,
      profilePic: profile.profilePic,
      ageCategory: profile.ageCategory,
      height: profile.heightToString() ?? "",
      weight: profile.weightToString() ?? "",
      strength: profile.strength,
      countryFlag: profile.countryFlag,
    );
  }

  Future<void> exchangeFootbarCode(String code) async {
    final result = await runUiWithResult<bool>(
      () => repository.api.exchangeCode(code),
      showLoading: true,
      loadingMessage: "Propojuji s Footbar účtem",
    );
    if (!mounted) return;
    if (result) {
      repository.invalidateProfile();
      ref.read(homeRepositoryProvider).invalidateSetup();
      ui.showSnack("Úspěšně propojeno s Footbar účtem!");
      _loadProfile();
    } else {
      ui.showSnack("Chyba při připojení");
    }
  }

  Future<String> getUrlFootbarConnection() async {
    final result = await runUiWithResult<String>(
      () => repository.api.connectToFootbar(),
      showLoading: true,
      loadingMessage: "Propojuji s Footbarem",
    );
    return result;
  }
}

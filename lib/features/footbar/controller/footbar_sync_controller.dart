import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/utils/calendar.dart';
import 'package:trus_app/features/footbar/repository/footbar_api_service.dart';

import '../../mixin/view_controller_mixin.dart';

final footbarSyncControllerProvider = Provider((ref) {
  final footbarService = ref.watch(footbarApiServiceProvider);
  return FootbarSyncController(
      footbarService: footbarService,
      ref: ref);
});

class FootbarSyncController with ViewControllerMixin {
  final FootbarApiService footbarService;
  final Ref ref;
  late DateTime? lastUpdate;

  final String lastUpdateKey = "footbar_last_update";

  FootbarSyncController({
    required this.footbarService,
    required this.ref,
  });

  void loadLastUpdate() {
    initViewFields(
        lastUpdate == null? "Ještě neproběhla" : formatDateForFrontend(lastUpdate!), lastUpdateKey);
  }

  Future<void> viewLastUpdate() async {
    Future.delayed(Duration.zero, () => loadLastUpdate());
  }

  Future<void> setupLastSync() async {
    lastUpdate = await _setupLastSync();
  }

  Future<DateTime?> _setupLastSync() async {
    return await footbarService.getSessionLastSyncDate();
  }

  Future<void> syncAppTeamActivities() async {
    lastUpdate = await footbarService.syncAppTeamActivites();
  }

}

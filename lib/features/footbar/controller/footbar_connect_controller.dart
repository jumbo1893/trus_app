import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/footbar/repository/footbar_api_service.dart';
import 'package:trus_app/features/mixin/boolean_controller_mixin.dart';
import 'package:trus_app/models/api/footbar/footbar_profile.dart';

import '../../mixin/view_controller_mixin.dart';

final footbarConnectControllerProvider = Provider((ref) {
  final footbarService = ref.watch(footbarApiServiceProvider);
  return FootbarConnectController(
      footbarService: footbarService,
      ref: ref);
});

class FootbarConnectController with ViewControllerMixin, BooleanControllerMixin {
  final FootbarApiService footbarService;
  final Ref ref;
  late FootbarProfile footbarProfile;

  final String activeKey = "footbar_active";
  final String activeTextKey = "footbar_active_text";
  final String nicknameKey = "footbar_nickname";
  final String favPositionKey = "footbar_fav_position";
  final String heightKey = "footbar_height";
  final String weightKey = "footbar_weight";

  FootbarConnectController({
    required this.footbarService,
    required this.ref,
  });

  void loadViewProfile() {
    initBooleanFields(
        !footbarProfile.active, activeKey);
    initViewFields(
        footbarProfile.active? "Propojen" : "Nepropojen", activeTextKey);
    initViewFields(
        footbarProfile.nickname?? "", nicknameKey);
    initViewFields(
        footbarProfile.favPosition?? "", favPositionKey);
    initViewFields(
        footbarProfile.heightToString()?? "", heightKey);
    initViewFields(
        footbarProfile.weightToString()?? "", weightKey);
  }

  Future<void> viewProfile() async {
    Future.delayed(Duration.zero, () => loadViewProfile());
  }

  Future<void> setupFootbarProfile() async {
    footbarProfile = await _setupFootbarProfile();
  }

  Future<FootbarProfile> _setupFootbarProfile() async {
    return await footbarService.getCurrentProfile();
  }

  Future<bool> exchangeFootbarCode(String code) async {
    return await footbarService.exchangeCode(code);
  }

  Future<String> getUrlFootbarConnection() async {
    return await footbarService.connectToFootbar();
  }
}

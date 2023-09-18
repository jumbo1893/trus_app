import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/add_controller.dart';
import 'package:trus_app/features/general/confirm_operations.dart';
import 'package:trus_app/models/api/interfaces/confirm_to_string.dart';

import '../../../../models/api/fine_api_model.dart';
import '../../../../models/api/interfaces/add_to_string.dart';
import '../../../../models/api/receivedfine/received_fine_api_model.dart';
import '../../../../models/api/receivedfine/received_fine_list.dart';
import '../../../../models/api/receivedfine/received_fine_response.dart';
import '../../../general/future_add_controller.dart';
import '../../repository/fine_api_service.dart';
import '../repository/fine_match_api_service.dart';



final finePlayerController = Provider((ref) {
  final fineMatchApiService = ref.watch(fineMatchApiServiceProvider);
  final fineApiService = ref.watch(fineApiServiceProvider);
  return FinePlayerController(
      fineMatchApiService: fineMatchApiService,
      fineApiService: fineApiService,
      ref: ref);
});

class FinePlayerController implements FutureAddController, ConfirmOperations {
  final FineMatchApiService fineMatchApiService;
  final FineApiService fineApiService;
  final ProviderRef ref;
  List<ReceivedFineApiModel> receivedFines = [];
  late int playerId;
  late int matchId;
  late bool multiple;
  late List<int> playerIdList;


  FinePlayerController({
    required this.fineMatchApiService,
    required this.fineApiService,
    required this.ref,
  });

  @override
  Future<List<AddToString>> getModels() async {
    return receivedFines;
  }

  @override
  void addNumber(int index, bool goal) {
    receivedFines[index].addNumber(goal);
  }

  @override
  void removeNumber(int index, bool goal) {
    receivedFines[index].removeNumber(goal);
  }

  Future<void> setupPlayer(int playerId, int matchId) async {
    this.playerId = playerId;
    this.matchId = matchId;
    multiple = false;
    receivedFines = await fineMatchApiService.setupFinePlayer(playerId, matchId);
  }

  Future<void> setupMultiFines(List<int> playerIdList, int matchId) async {
    this.playerIdList = playerIdList;
    this.matchId = matchId;
    multiple = true;
    receivedFines = convertFinesToReceivedFines(await fineApiService.getFines());
  }

  List<ReceivedFineApiModel> convertFinesToReceivedFines(List<FineApiModel> fineList) {
    List<ReceivedFineApiModel> returnList = [];
    for(FineApiModel fine in fineList) {
      returnList.add(ReceivedFineApiModel(matchId: matchId, playerId: -1, fine: fine, fineNumber: 0));
    }
    return returnList;
  }

  Future<ReceivedFineResponse> _saveFinesToRepository(ReceivedFineList receivedFineList) async {
    return await fineMatchApiService.addFines(receivedFineList, multiple);
  }

  @override
  Future<ConfirmToString> addModel(int? notUsed) async {
    ReceivedFineList receivedFineList = ReceivedFineList(matchId: matchId, playerId: multiple ? null : playerId, playerIdList: multiple ? playerIdList : null, fineList: receivedFines);
    return await _saveFinesToRepository(receivedFineList);
  }
}

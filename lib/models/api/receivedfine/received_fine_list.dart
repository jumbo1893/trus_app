import 'package:trus_app/models/api/receivedfine/received_fine_api_model.dart';


class ReceivedFineList {
  final int matchId;
  final int? playerId;
  final List<int>? playerIdList;
  final List<ReceivedFineApiModel> fineList;

  ReceivedFineList({
    required this.matchId,
    required this.playerId,
    required this.playerIdList,
    required this.fineList,
  });


  Map<String, dynamic> toJson() {
    return {
      "playerId": playerId,
      "matchId": matchId,
      "playerIdList": playerIdList,
      "fineList": fineList,
    };
  }
}
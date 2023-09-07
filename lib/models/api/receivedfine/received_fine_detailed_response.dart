import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/api/player_api_model.dart';
import 'package:trus_app/models/api/receivedfine/received_fine_detailed_model.dart';
import 'package:trus_app/models/api/season_api_model.dart';


class ReceivedFineDetailedResponse {
  final int playersCount;
  final int matchesCount;
  final int finesNumber;
  final int finesAmount;
  final List<ReceivedFineDetailedModel> fineList;

  ReceivedFineDetailedResponse({
    required this.playersCount,
    required this.matchesCount,
    required this.finesNumber,
    required this.finesAmount,
    required this.fineList,
  });

  factory ReceivedFineDetailedResponse.fromJson(Map<String, dynamic> json) {
    return ReceivedFineDetailedResponse(
      playersCount: json["playersCount"] ?? 0,
      matchesCount: json["matchesCount"] ?? 0,
      finesNumber: json["finesNumber"] ?? 0,
      finesAmount: json["finesAmount"] ?? 0,
      fineList: List<ReceivedFineDetailedModel>.from((json['fineList'] as List<dynamic>).map((fine) => ReceivedFineDetailedModel.fromJson(fine))),
    );
  }

  String overallStatsToString() {
    return "$finesNumber pokut ve výši $finesAmount Kč v $playersCount hráčích a $matchesCount zápasech";
  }
}

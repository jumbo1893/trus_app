import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/fine_api_model.dart';
import 'package:trus_app/models/api/interfaces/json_and_http_converter.dart';

import '../interfaces/add_to_string.dart';

class ReceivedFineApiModel implements JsonAndHttpConverter, AddToString{
  final int? id;
  final int matchId;
  final int playerId;
  final FineApiModel fine;
  int fineNumber;

  ReceivedFineApiModel({
    this.id,
    required this.matchId,
    required this.playerId,
    required this.fine,
    required this.fineNumber,
  });

  @override
  factory ReceivedFineApiModel.fromJson(Map<String, dynamic> json) {
    return ReceivedFineApiModel(
      id: json["id"],
      matchId: json["matchId"] ?? 0,
      playerId: json["playerId"] ?? 0,
      fine: FineApiModel.fromJson(json["fine"]),
      fineNumber: json["fineNumber"] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "matchId": matchId,
      "playerId": playerId,
      "fine": fine,
      "fineNumber": fineNumber,
    };
  }

  @override
  String httpRequestClass() {
    return receivedFineApi;
  }

  @override
  void addNumber(bool goal) {
    fineNumber++;
  }

  @override
  int number(bool goal) {
    return fineNumber;
  }

  @override
  String numberToString(bool goal) {
    return fineNumber.toString();
  }

  @override
  void removeNumber(bool goal) {
    if (fineNumber > 0) {
      fineNumber--;
    }
  }

  get name {
    if(fine.inactive) {
      return "${fine.name}( inactive)";
    }
    return fine.name;
  }

  @override
  String toStringForListView() {
    return "$name (${fine.amount.toString()} Kč)";
  }
}
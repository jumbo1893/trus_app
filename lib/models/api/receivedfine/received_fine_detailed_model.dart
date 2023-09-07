import 'package:trus_app/config.dart';
import 'package:trus_app/models/api/fine_api_model.dart';
import 'package:trus_app/models/api/player_api_model.dart';

import '../interfaces/add_to_string.dart';
import '../interfaces/model_to_string.dart';
import '../match/match_api_model.dart';

class ReceivedFineDetailedModel implements ModelToString {
  int? id;
  final int fineNumber;
  final int fineAmount;
  final PlayerApiModel? player;
  final MatchApiModel? match;
  final FineApiModel? fine;

  ReceivedFineDetailedModel({
    this.id,
    required this.fineNumber,
    required this.fineAmount,
    this.player,
    this.match,
    this.fine,
  });

  factory ReceivedFineDetailedModel.fromJson(Map<String, dynamic> json) {
    return ReceivedFineDetailedModel(
      id: json["id"] ?? 0,
      fineNumber: json["fineNumber"] ?? 0,
      fineAmount: json["fineAmount"] ?? 0,
      player: json["player"] != null ? PlayerApiModel.fromJson(json["player"]) : null,
      match: json["match"] != null ? MatchApiModel.fromJson(json["match"]) : null,
      fine: json["fine"] != null ? FineApiModel.fromJson(json["fine"]) : null,
    );
  }

  @override
  int getId() {
    return id?? -1;
  }

  @override
  String listViewTitle() {
    if(match != null) {
      return match!.listViewTitle();
    }
    else if (player != null) {
      return player!.listViewTitle();
    }
    else if (fine != null) {
      return "${fine!.name} v hodnotě ${fine!.amount} Kč";
    }
    else {
      return "neznámý hráč či zápas";
    }
  }

  @override
  String toStringForAdd() {
    return "";
  }

  @override
  String toStringForConfirmationDelete() {
    return "";
  }

  @override
  String toStringForEdit(String originName) {
    return "";
  }

  @override
  String toStringForListView() {
    return "Počet pokut: $fineNumber v celkové výši $fineAmount Kč";
  }
}

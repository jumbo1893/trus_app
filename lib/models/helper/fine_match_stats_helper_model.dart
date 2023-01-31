import '../fine_model.dart';

class FineMatchStatsHelperModel {
  final FineModel fine;
  final String id;
  final String playerId;
  final String matchId;
  final int number;

  FineMatchStatsHelperModel({
    required this.id,
    required this.fine,
    required this.playerId,
    required this.matchId,
    required this.number,
  });

  int getTotalAmountOfFine() {
    return number*fine.amount;
  }

  @override
  String toString() {
    return 'FineMatchHelperModel{id: $id, fine: $fine, number: $number}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is FineMatchStatsHelperModel &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

//

}

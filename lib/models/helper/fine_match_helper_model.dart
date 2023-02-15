import 'package:trus_app/models/helper/helper_model.dart';

import '../fine_model.dart';

class FineMatchHelperModel implements IHelperModel {
  final FineModel fine;
  final String id;
  int number;

  FineMatchHelperModel({
    required this.id,
    required this.fine,
    required this.number,
  });

  /*void addNumber() {
    number++;
  }

  void removeNumber() {
    if(number > 0) {
      number--;
    }
  }*/


  @override
  String toString() {
    return 'FineMatchHelperModel{id: $id, fine: $fine, number: $number}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is FineMatchHelperModel &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  int getNumber(String? field) {
    return number;
  }

  @override
  void addNumber(String? field) {
    number++;
  }

  @override
  void removeNumber(String? field) {
    if(number > 0) {
      number--;
    }
  }

  @override
  String toStringForListviewAddModel() {
    return "${fine.name} (${fine.amount} Kč)";
  }

//

}

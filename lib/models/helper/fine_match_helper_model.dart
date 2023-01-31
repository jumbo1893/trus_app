import '../fine_model.dart';

class FineMatchHelperModel {
  final FineModel fine;
  final String id;
  int number;

  FineMatchHelperModel({
    required this.id,
    required this.fine,
    required this.number,
  });

  void addNumber() {
    number++;
  }

  void removeNumber() {
    if(number > 0) {
      number--;
    }
  }


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

//

}

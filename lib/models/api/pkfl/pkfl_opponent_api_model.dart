
class PkflOpponentApiModel {
  int id;
  String name;

  PkflOpponentApiModel({
    required this.name,
    required this.id,
  });



  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "id": id,
    };
  }

  factory PkflOpponentApiModel.fromJson(Map<String, dynamic> json) {
    return PkflOpponentApiModel(
      name: json["name"] ?? "",
      id: json["id"],
    );
  }


  @override
  String toString() {
    return name;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PkflOpponentApiModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

}

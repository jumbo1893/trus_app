
class PkflSeasonApiModel {
  int id;
  String name;
  String url;

  PkflSeasonApiModel({
    required this.name,
    required this.url,
    required this.id,
  });



  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "id": id,
      "url": url,
    };
  }

  factory PkflSeasonApiModel.fromJson(Map<String, dynamic> json) {
    return PkflSeasonApiModel(
      name: json["name"] ?? "",
      id: json["id"],
      url: json["url"],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PkflSeasonApiModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

}

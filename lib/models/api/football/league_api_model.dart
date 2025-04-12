
import '../../../config.dart';
import '../interfaces/json_and_http_converter.dart';
import '../interfaces/model_to_string.dart';

class LeagueApiModel implements JsonAndHttpConverter, ModelToString  {
  int? id;
  final String name;
  final int rank;
  final String organization;
  final String organizationUnit;
  final String uri;
  final String year;
  final List<int> tableTeamIdList;
  final bool currentLeague;

  LeagueApiModel({
    this.id,
    required this.name,
    required this.rank,
    required this.organization,
    required this.organizationUnit,
    required this.uri,
    required this.year,
    required this.tableTeamIdList,
    required this.currentLeague,
  });

  LeagueApiModel.dummy()
      : id = -100,
        rank = 0,
        name = "",
        organization = "",
        organizationUnit = "",
        uri = "",
        year = "",
        tableTeamIdList = [],
        currentLeague = false;

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "rank": rank,
      "organization": organization,
      "organizationUnit": organizationUnit,
      "uri": uri,
      "year": year,
      "tableTeamIdList": tableTeamIdList,
      "currentLeague": currentLeague,
    };
  }

  factory LeagueApiModel.fromJson(Map<String, dynamic> json) {
    return LeagueApiModel(
      id: json["id"],
      name: json["name"],
      rank: json["rank"],
      organization: json["organization"],
      organizationUnit: json["organizationUnit"],
      uri: json["uri"],
      year: json["year"],
      tableTeamIdList: List<int>.from(json["tableTeamIdList"] ?? []),
      currentLeague: json["currentLeague"],
    );
  }


  @override
  String toString() {
    return name;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeagueApiModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  int getId() {
    return id?? -1;
  }

  @override
  String httpRequestClass() {
    return footballTableApi;
  }

  @override
  String listViewTitle() {
    return name;
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
    return year;

  }

}

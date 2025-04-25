


class AppTeamRegistration {
  final String name;
  final int footballTeamId;

  AppTeamRegistration({
    required this.name,
    required this.footballTeamId,
  });


  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "footballTeamId": footballTeamId,
    };
  }

  factory AppTeamRegistration.fromJson(Map<String, dynamic> json) {
    return AppTeamRegistration(
      footballTeamId: json["footballTeamId"],
      name: json["name"],
    );
  }
}

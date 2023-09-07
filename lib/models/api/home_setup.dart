
class HomeSetup {
  String nextBirthday;
  List<String> randomFacts;


  HomeSetup({
    required this.nextBirthday,
    required this.randomFacts,
  });


  @override
  factory HomeSetup.fromJson(Map<String, dynamic> json) {
    return HomeSetup(
      nextBirthday: json["nextBirthday"] ?? "",
      randomFacts: (json['randomFacts'] as List).cast<String>(),
    );
  }

}

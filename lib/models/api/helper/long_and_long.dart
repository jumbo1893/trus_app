

class LongAndLong {
  final int firstId;
  final int secondId;

  LongAndLong(
      {required this.firstId,
      required this.secondId,
    });

  factory LongAndLong.fromJson(Map<String, dynamic> json) {
    return LongAndLong(
      firstId: json["firstId"],
      secondId: json["secondId"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "firstId": firstId,
      "secondId": secondId,
    };
  }
}

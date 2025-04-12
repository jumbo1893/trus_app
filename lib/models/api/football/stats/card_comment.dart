import 'package:trus_app/models/api/football/football_match_api_model.dart';

class CardComment {
  FootballMatchApiModel footballMatch;
  String comment;

  CardComment(
      {required this.footballMatch,
      required this.comment,
    });

  factory CardComment.fromJson(Map<String, dynamic> json) {
    return CardComment(
      footballMatch: FootballMatchApiModel.fromJson(json["footballMatch"]),
      comment: json["comment"],
    );
  }
}

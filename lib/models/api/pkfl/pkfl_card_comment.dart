import 'package:trus_app/models/api/pkfl/pkfl_match_api_model.dart';

class PkflCardComment {
  PkflMatchApiModel pkflMatch;
  String comment;

  PkflCardComment(
      {required this.pkflMatch,
      required this.comment,
    });

  factory PkflCardComment.fromJson(Map<String, dynamic> json) {
    return PkflCardComment(
      pkflMatch: PkflMatchApiModel.fromJson(json["pkflMatch"]),
      comment: json["comment"],
    );
  }
}

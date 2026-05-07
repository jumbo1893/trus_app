import 'package:trus_app/models/api/helper/redirect/redirect_api_model.dart';
import 'package:trus_app/models/api/helper/warning_type.dart';

class TextWithRedirect {
  final String? title;
  final String? text;
  final WarningType? warningType;
  final RedirectApiModel? redirect;

  TextWithRedirect({
    required this.title,
    required this.text,
    required this.warningType,
    required this.redirect,
  });

  factory TextWithRedirect.fromJson(Map<String, dynamic> json) {
    return TextWithRedirect(
      title: json["title"],
      text: json["text"],
      warningType: WarningTypeExtension.fromJson(json["warningType"]),
      redirect: json["redirect"] != null
          ? RedirectApiModel.fromJson(json["redirect"])
          : null,
    );
  }
}
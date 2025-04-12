
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

class TitleAndText implements ModelToString {
  String title;
  String text;

  TitleAndText({
    required this.title,
    required this.text,
  });



  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "text": text,
    };
  }

  factory TitleAndText.fromJson(Map<String, dynamic> json) {
    return TitleAndText(
      title: json["title"] ?? "",
      text: json["text"] ?? "",
    );
  }

  @override
  int getId() {
    return 0;
  }

  @override
  String listViewTitle() {
    return title;
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
    return text;
  }

}

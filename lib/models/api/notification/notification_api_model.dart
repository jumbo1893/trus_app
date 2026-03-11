import 'package:trus_app/config.dart';

import '../../../common/utils/calendar.dart';
import '../interfaces/json_and_http_converter.dart';
import '../interfaces/model_to_string.dart';

class NotificationApiModel implements JsonAndHttpConverter, ModelToString {
  final int id;
  final String userName;
  final DateTime date;
  final String title;
  final String text;

  NotificationApiModel({
    required this.id,
    required this.userName,
    required this.date,
    required this.title,
    required this.text,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userName": userName,
      "date": formatDateForJson(date),
      "title": title,
      "text": text,
    };
  }

  @override
  factory NotificationApiModel.fromJson(Map<String, dynamic> json) {
    return NotificationApiModel(
      id: json["id"] ?? 0,
      userName: json["userName"] ?? '',
      date: DateTime.parse(json['date']),
      title: json['title'] ?? '',
      text: json["text"] ?? '',
    );
  }

  @override
  String httpRequestClass() {
    return notificationApi;
  }

  @override
  int getId() {
    return id;
  }

  @override
  String listViewTitle() {
    // TODO: implement listViewTitle
    throw UnimplementedError();
  }

  @override
  String toStringForAdd() {
    // TODO: implement toStringForAdd
    throw UnimplementedError();
  }

  @override
  String toStringForConfirmationDelete() {
    // TODO: implement toStringForConfirmationDelete
    throw UnimplementedError();
  }

  @override
  String toStringForEdit(String originName) {
    // TODO: implement toStringForEdit
    throw UnimplementedError();
  }

  @override
  String toStringForListView() {
    // TODO: implement toStringForListView
    throw UnimplementedError();
  }
}

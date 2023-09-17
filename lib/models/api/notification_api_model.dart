import 'package:trus_app/config.dart';

import 'interfaces/json_and_http_converter.dart';

class NotificationApiModel implements JsonAndHttpConverter {
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
      "date": date.toIso8601String(),
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
}

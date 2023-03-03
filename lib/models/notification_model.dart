class NotificationModel {
  final String id;
  final String userName;
  final DateTime date;
  final String title;
  final String text;

  NotificationModel(
      {required this.id,
        required this.userName,
      required this.date,
      required this.title,
      required this.text,
      });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userName": userName,
      "date": date.millisecondsSinceEpoch,
      "title": title,
      "text": text,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json["id"] ?? '',
      userName: json["userName"] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      title: json['title'] ?? '',
      text: json["text"] ?? '',

    );
  }

//

}

import 'package:trus_app/common/utils/calendar.dart';

import '../interfaces/json_and_http_converter.dart';

class StravaActivity implements JsonAndHttpConverter {
  final int id;
  final String? stravaActivityId;
  final String name;
  final double? distance;
  final String type;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? elapsedTime;
  final int? movingTime;
  final double? averageSpeed;
  final double? maxSpeed;
  final double? calories;
  final double? averageHeartRate;
  final double? maxHeartRate;

  StravaActivity({
    required this.id,
    this.stravaActivityId,
    required this.name,
    this.distance,
    required this.type,
    this.startTime,
    this.endTime,
    this.elapsedTime,
    this.movingTime,
    this.averageSpeed,
    this.maxSpeed,
    this.calories,
    this.averageHeartRate,
    this.maxHeartRate,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "distance": distance,
      "type": type,
      "startTime": startTime,
      "endTime": endTime,
      "elapsedTime": elapsedTime,
      "movingTime": movingTime,
      "averageSpeed": averageSpeed,
      "maxSpeed": maxSpeed,
      "calories": calories,
      "averageHeartRate": averageHeartRate,
      "maxHeartRate": maxHeartRate,
    };
  }

  @override
  factory StravaActivity.fromJson(Map<String, dynamic> json) {
    return StravaActivity(
      id: json["id"] ?? -1,
      stravaActivityId: json["stravaActivityId"] ?? "",
      name: json["name"] ?? "",
      distance: (json["distance"] as num?)?.toDouble(),
      type: json["type"] ?? "",
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      elapsedTime: json["elapsedTime"],
      movingTime: json["movingTime"],
      averageSpeed: (json["averageSpeed"] as num?)?.toDouble(),
      maxSpeed: (json["maxSpeed"] as num?)?.toDouble(),
      calories: (json["calories"] as num?)?.toDouble(),
      averageHeartRate: (json["averageHeartRate"] as num?)?.toDouble(),
      maxHeartRate: (json["maxHeartRate"] as num?)?.toDouble(),
    );
  }

  @override
  String httpRequestClass() {
    return "";
  }

  String elapsedTimeToString(int elapsedTime) {
    final int hours = elapsedTime ~/ 3600;
    final int minutes = (elapsedTime % 3600) ~/ 60;
    final int seconds = elapsedTime % 60;

    final String minutesStr = minutes.toString().padLeft(2, '0');
    final String secondsStr = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hours:$minutesStr:$secondsStr';
    } else {
      return '$minutesStr:$secondsStr';
    }
  }

  double convertSpeedToKmh(double speedInMetersPerSecond) {
    return speedInMetersPerSecond * 3.6;
  }

  @override
  String toString() {
    return 'Vzdálenost: ${distance!/1000} km, začátek: ${dateTimeToTimeString(startTime!)}, celkový čas: ${elapsedTimeToString(elapsedTime!)}, '
        'čas pohybu: ${elapsedTimeToString(movingTime!)}, průměrná rychlost: ${convertSpeedToKmh(averageSpeed!)} km/h, maximální rychlost: ${convertSpeedToKmh(maxSpeed!)} km/h, '
        'prům. srdeční tep: $averageHeartRate, max srdeční tep: $maxHeartRate';
  }
}

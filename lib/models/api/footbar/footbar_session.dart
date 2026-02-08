import 'package:trus_app/common/utils/calendar.dart';
import 'package:trus_app/common/utils/utils.dart';

class FootbarSession {
  final int id;
  final int footbarSessionId;
  final DateTime? startDate;
  final DateTime? stopDate;
  final double? playingTime;
  final String? title;
  final String? matchType;
  final String? position;
  final double? scoreStars;
  final double? distance;
  final int? passCount;
  final int? shotCount;
  final double? shotSpeed;
  final double? avgShotSpeed;
  final int? dribbleCount;
  final double? timeWithBall;
  final double? activity;
  final double? timeRunning;
  final double? runCount;
  final int? sprintCount;
  final double? avgSprintSpeed;
  final double? sprintSpeed;
  final double? sprintDistance;
  final double? stopAndGo;
  final double? acceleration;

  FootbarSession({
    required this.id,
    required this.footbarSessionId,
    this.startDate,
    this.stopDate,
    this.playingTime,
    this.title,
    this.matchType,
    this.position,
    this.scoreStars,
    this.distance,
    this.passCount,
    this.shotCount,
    this.shotSpeed,
    this.avgShotSpeed,
    this.dribbleCount,
    this.timeWithBall,
    this.activity,
    this.timeRunning,
    this.runCount,
    this.sprintCount,
    this.avgSprintSpeed,
    this.sprintSpeed,
    this.sprintDistance,
    this.stopAndGo,
    this.acceleration,
  });

  @override
  factory FootbarSession.fromJson(Map<String, dynamic> json) {
    return FootbarSession(
      id: json['id'],
      footbarSessionId: json['footbarSessionId'],
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      stopDate: json['stopDate'] != null ? DateTime.parse(json['stopDate']) : null,
      playingTime: (json['playingTime'] as num?)?.toDouble(),
      title: json['title'] as String?,
      matchType: json['matchType'] as String?,
      position: json['position'] as String?,
      scoreStars: (json['scoreStars'] as num?)?.toDouble(),
      distance: (json['distance'] as num?)?.toDouble(),
      passCount: json['passCount'] as int?,
      shotCount: json['shotCount'] as int?,
      shotSpeed: (json['shotSpeed'] as num?)?.toDouble(),
      avgShotSpeed: (json['avgShotSpeed'] as num?)?.toDouble(),
      dribbleCount: json['dribbleCount'] as int?,
      timeWithBall: (json['timeWithBall'] as num?)?.toDouble(),
      activity: (json['activity'] as num?)?.toDouble(),
      timeRunning: (json['timeRunning'] as num?)?.toDouble(),
      runCount: (json['runCount'] as num?)?.toDouble(),
      sprintCount: json['sprintCount'] as int?,
      avgSprintSpeed: (json['avgSprintSpeed'] as num?)?.toDouble(),
      sprintSpeed: (json['sprintSpeed'] as num?)?.toDouble(),
      sprintDistance: (json['sprintDistance'] as num?)?.toDouble(),
      stopAndGo: (json['stopAndGo'] as num?)?.toDouble(),
      acceleration: (json['acceleration'] as num?)?.toDouble(),
    );
  }

  @override
  String toString() {
    return 'FootbarSession(id: $id, footbarSessionId: $footbarSessionId, '
        'title: $title, matchType: $matchType, distance: $distance, '
        'scoreStars: $scoreStars, playingTime: $playingTime)';
  }

  String dribbleCountString() {
    return "Počet driblinků";
  }

  String timeWithBallString() {
    return "Čas s míčem";
  }

  String activityString() {
    return "Aktivní čas";
  }

  String timeRunningString() {
    return "Čas v běhu";
  }

  String runCountString() {
    return "Počet běhů";
  }

  String sprintCountString() {
    return "Počet sprintů";
  }

  String avgSprintSpeedString() {
    return "Průměrná rychlost sprintu";
  }

  String sprintSpeedString() {
    return "Max sprint";
  }

  String sprintDistanceString() {
    return "Usprintovaná vzdálenost";
  }

  String stopAndGoString() {
    return "Index intenzity";
  }

  String accelerationString() {
    return " Index zrychlení";
  }

  String avgShotSpeedString() {
    return "Průměrná rychlost střely";
  }

  String startDateString() {
    return "Začátek";
  }

  String stopDateString() {
    return "Konec";
  }

  String playingTimeString() {
    return "Hrací doba";
  }

  String titleString() {
    return "Název";
  }

  String matchTypeString() {
    return "Typ zápasu";
  }

  String positionString() {
    return "Pozice";
  }

  String scoreStarsString() {
    return "Footbar hodnocení";
  }

  String distanceString() {
    return "Vzdálenost";
  }

  String passCountString() {
    return "Počet přihrávek";
  }

  String shotCountString() {
    return "Počet střel";
  }

  String shotSpeedString() {
    return "Rychlost střely";
  }

  String? dribbleCountValueString() {
    return dribbleCount?.toString();
  }

  String? timeWithBallValueString() {
    return doubleInMinutesToMinutesSeconds(timeWithBall);
  }

  String? activityValueString() {
    return activity != null ? "${activity!.toInt()}%" : null;
  }

  String? timeRunningValueString() {
    return doubleInSecondsToMinutesSeconds(timeRunning);
  }

  String? runCountValueString() {
    return runCount?.toString();
  }

  String? sprintCountValueString() {
    return sprintCount?.toString();
  }

  String? avgSprintSpeedValueString() {
    return avgShotSpeed != null ? ("${msToKmh(avgShotSpeed!)} km/h") : null;
  }

  String? sprintSpeedValueString() {
    return sprintSpeed != null ? ("${msToKmh(sprintSpeed!)} km/h") : null;
  }

  String? sprintDistanceValueString() {
    return sprintDistance != null ? ("${sprintDistance!.toInt()} m") : null;
  }

  String? stopAndGoValueString() {
    return stopAndGo?.toStringAsFixed(1);
  }

  String? accelerationValueString() {
    return acceleration?.toStringAsFixed(1);
  }

  String? avgShotSpeedValueString() {
    return avgSprintSpeed != null ? ("${msToKmh(avgSprintSpeed!)} km/h") : null;
  }

  String? startDateValueString() {
    return startDate != null ? formatDateForFrontend(startDate!) : null;
  }

  String? stopDateValueString() {
    return stopDate != null ? formatDateForFrontend(stopDate!) : null;
  }

  String? playingTimeValueString() {
    return doubleInSecondsToMinutesSeconds(playingTime);
  }

  String? titleValueString() {
    return title;
  }

  String? matchTypeValueString() {
    return matchType;
  }

  String? positionValueString() {
    return position;
  }

  String? scoreStarsValueString() {
    return scoreStars?.toStringAsFixed(1);
  }

  String? distanceValueString() {
    return distance != null ? ("${distance!.toInt()} m") : null;
  }

  String? passCountValueString() {
    return passCount?.toString();
  }

  String? shotCountValueString() {
    return shotCount?.toString();
  }

  String? shotSpeedValueString() {
    return shotSpeed != null ? ("${msToKmh(shotSpeed!)} km/h") : null;
  }
}

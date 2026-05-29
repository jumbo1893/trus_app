import 'package:trus_app/models/api/attendance/attendance_detailed_model.dart';
import 'package:trus_app/models/api/interfaces/detailed_response_model.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

class AttendanceDetailedResponse implements DetailedResponseModel {
  final int playersCount;
  final int matchesCount;
  final List<AttendanceDetailedModel> attendanceList;

  AttendanceDetailedResponse({
    required this.playersCount,
    required this.matchesCount,
    required this.attendanceList,
  });

  factory AttendanceDetailedResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceDetailedResponse(
      playersCount: json["playersCount"] ?? 0,
      matchesCount: json["matchesCount"] ?? 0,
      attendanceList: List<AttendanceDetailedModel>.from(
        (json["attendanceList"] as List<dynamic>? ?? [])
            .map((item) => AttendanceDetailedModel.fromJson(item)),
      ),
    );
  }

  @override
  List<ModelToString> modelList() {
    return attendanceList;
  }

  @override
  String overallStats() {
    return "$playersCount unikátních účastníků v $matchesCount zápasech";
  }
}
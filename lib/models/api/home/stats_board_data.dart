import 'stats_board_row.dart';

class StatsBoardData {
  final String title;

  final List<String> headers;

  final List<StatsBoardRow> rows;

  StatsBoardData({
    required this.title,
    required this.headers,
    required this.rows,
  });

  factory StatsBoardData.fromJson(Map<String, dynamic> json) {
    return StatsBoardData(
      title: json['title'] ?? '',

      headers: List<String>.from(
        json['headers'] ?? [],
      ),

      rows: List<StatsBoardRow>.from(
        (json['rows'] as List<dynamic>? ?? [])
            .map((e) => StatsBoardRow.fromJson(e)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'headers': headers,
      'rows': rows.map((e) => e.toJson()).toList(),
    };
  }
}
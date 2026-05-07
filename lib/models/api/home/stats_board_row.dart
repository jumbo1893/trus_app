class StatsBoardRow {
  final List<String> columns;

  StatsBoardRow({
    required this.columns,
  });

  factory StatsBoardRow.fromJson(Map<String, dynamic> json) {
    return StatsBoardRow(
      columns: List<String>.from(
        json['columns'] ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'columns': columns,
    };
  }
}
import '../helper/redirect/redirect_api_model.dart';

class StatsBoardRow {
  final List<String> columns;
  final RedirectApiModel? redirect;

  StatsBoardRow({required this.columns, this.redirect,});

  factory StatsBoardRow.fromJson(Map<String, dynamic> json) {
    return StatsBoardRow(
      columns: List<String>.from(json['columns'] ?? []),
      redirect: json["redirect"] != null
          ? RedirectApiModel.fromJson(json["redirect"])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'columns': columns};
  }
}

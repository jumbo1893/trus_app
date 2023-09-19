class ErrorResponse {
  final String message;
  String? code;

  ErrorResponse({
    required this.message,
    this.code
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      message: json["message"] ?? "",
      code: json["code"] ?? "",
    );
  }

  @override
  String toString() {
    return 'ErrorResponse{message: $message, code: $code}';
  }
}

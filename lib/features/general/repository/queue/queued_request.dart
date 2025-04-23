import 'package:http/http.dart' as http;

class QueuedRequest<T> {
  final Future<http.Response> Function(http.Client) request;
  final T Function(dynamic) mapFunction;

  QueuedRequest({required this.request, required this.mapFunction});
}

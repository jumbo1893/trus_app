import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:trus_app/common/repository/exception/handler/response_validator.dart';

void main() {
  final validator = ResponseValidator();
  for (final status in [200, 201, 202, 204, 299]) {
    test(
      'accepts successful HTTP $status including empty acknowledgements',
      () {
        expect(
          () => validator.validateStatusCode(http.Response('', status)),
          returnsNormally,
        );
      },
    );
  }
  for (final status in [199, 300, 404, 500]) {
    test('does not mistake HTTP $status for a successful save', () {
      expect(
        () => validator.validateStatusCode(http.Response('', status)),
        throwsException,
      );
    });
  }
}

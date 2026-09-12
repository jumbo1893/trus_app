import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/auth/login/controller/auth_login_controller.dart';
import 'package:trus_app/services/permissions/authenticated_permissions_provider.dart';
import 'package:trus_app/services/push/notification_init_provider.dart';
import 'package:http/http.dart' as http;
import 'package:trus_app/common/repository/exception/handler/response_validator.dart';
import 'package:trus_app/common/repository/exception/server_exception.dart';
import 'package:trus_app/common/repository/exception/field_validation_exception.dart';

void main() {
  test(
    'login shares nonprompting permission initialization with Home',
    () async {
      var initializations = 0;
      final container = ProviderContainer(
        overrides: [
          userDataAuthProvider.overrideWith((ref) async => LoginRedirect.ok),
          authenticatedPermissionsProvider.overrideWith((ref) async {
            initializations++;
          }),
        ],
      );
      addTearDown(container.dispose);
      container.read(notificationsInitProvider);
      await container.read(userDataAuthProvider.future);
      await Future<void>.delayed(Duration.zero);
      await container.read(authenticatedPermissionsProvider.future);
      expect(initializations, 1);
    },
  );
  test('HTTP400 without fields preserves server error message', () {
    expect(
      () => ResponseValidator().validateStatusCode(
        http.Response('{"message":"Invalid user id: onboarding"}', 400),
      ),
      throwsA(
        isA<ServerException>().having(
          (e) => e.cause,
          'message',
          'Invalid user id: onboarding',
        ),
      ),
    );
  });
  test('HTTP400 with fields still returns field validation', () {
    expect(
      () => ResponseValidator().validateStatusCode(
        http.Response('{"message":"Invalid field","fields":[]}', 400),
      ),
      throwsA(isA<FieldValidationException>()),
    );
  });
  test('non-JSON HTTP400 remains a handled server error', () {
    expect(
      () => ResponseValidator().validateStatusCode(
        http.Response('<html>Bad request</html>', 400),
      ),
      throwsA(isA<ServerException>()),
    );
  });
}

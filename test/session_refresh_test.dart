import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:trus_app/common/repository/header/cookies/header_provider.dart';
import 'package:trus_app/common/repository/header/cookies/custom_cookie_manager.dart';
import 'package:trus_app/common/repository/exception/model/login_expired_exception.dart';
import 'package:trus_app/features/general/repository/request_executor.dart';
import 'package:trus_app/features/main/ui/ui_feedback_notifier.dart';

class _User implements User {
  int refreshes = 0;
  final renewed = Completer<String?>();
  @override
  Future<String?> getIdToken([bool forceRefresh = false]) {
    refreshes++;
    return renewed.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Auth implements FirebaseAuth {
  @override
  final User? currentUser;
  _Auth(this.currentUser);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Headers implements HeaderProvider {
  @override
  final cookieJar = CustomCookieManager();
  @override
  Future<Map<String, String>> getHeaders() async => {};
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Executor extends RequestExecutor {
  final http.Client client;
  _Executor(Ref ref, FirebaseAuth auth, this.client)
    : super(ref, auth: auth, headerProvider: _Headers());
  @override
  http.Client getClient() => client;
}

void main() {
  test(
    'concurrent expired requests renew once without opening any sheet',
    () async {
      final user = _User();
      var requests = 0;
      final client = MockClient((_) async {
        requests++;
        return user.renewed.isCompleted
            ? http.Response('{"ok":true}', 200)
            : http.Response(
                '{"code":"not_logged_in","message":"expired"}',
                401,
              );
      });
      final provider = Provider((ref) => _Executor(ref, _Auth(user), client));
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final executor = container.read(provider);
      Future<bool> request() => executor.executeGetRequest(
        Uri.parse('https://example.test/data'),
        (data) => data['ok'] as bool,
        null,
      );
      final first = request();
      final second = request();
      await Future<void>.delayed(Duration.zero);
      expect(user.refreshes, 1);
      expect(container.read(uiFeedbackProvider).effects, isEmpty);
      user.renewed.complete('new-token');
      expect(await Future.wait([first, second]), [true, true]);
      expect(requests, 4);
      expect(container.read(uiFeedbackProvider).effects, isEmpty);
    },
  );

  test('persistent unauthorized response stops after one retry', () async {
    final user = _User()..renewed.complete('new-token');
    var requests = 0;
    final client = MockClient((_) async {
      requests++;
      return http.Response('{"code":"not_logged_in","message":"expired"}', 401);
    });
    final provider = Provider((ref) => _Executor(ref, _Auth(user), client));
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await expectLater(
      container
          .read(provider)
          .executeGetRequest(
            Uri.parse('https://example.test/data'),
            (data) => data,
            null,
          ),
      throwsA(isA<LoginExpiredException>()),
    );
    expect(requests, 2);
    expect(user.refreshes, 1);
    expect(container.read(uiFeedbackProvider).effects, isEmpty);
  });
}

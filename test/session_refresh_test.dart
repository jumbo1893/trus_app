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
import 'package:trus_app/features/season_recap/season_recap_data.dart';
import 'package:trus_app/features/general/notifier/global_variables_notifier.dart';
import 'package:trus_app/models/api/auth/app_team_api_model.dart';

class _Team implements AppTeamApiModel {
  @override
  int get id => 5;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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
    'real recap providers refresh history after saving without a dependency cycle',
    () async {
      bool saved = false;
      final client = MockClient((request) async {
        if (request.method == 'POST') {
          saved = true;
          return http.Response('{"opened":true}', 200);
        }
        return http.Response(
          '[{"id":9,"seasonName":"Podzim","from":"2026-06-02","to":"2026-12-01","opened":$saved}]',
          200,
        );
      });
      final container = ProviderContainer(
        overrides: [
          requestExecutorProvider.overrideWith(
            (ref) => _Executor(ref, _Auth(null), client),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.read(globalVariablesProvider.notifier).setAppTeam(_Team());
      final subscription = container.listen(seasonRecapsProvider, (_, __) {});
      addTearDown(subscription.close);
      expect(
        (await container.read(seasonRecapsProvider.future)).single.opened,
        isFalse,
      );
      await container.read(seasonRecapApiProvider).opened(9);
      expect(saved, isTrue);
      expect(
        (await container.read(seasonRecapsProvider.future)).single.opened,
        isTrue,
      );
    },
  );
  for (final response in [
    http.Response('', 200),
    http.Response('{"opened":true}', 200),
    http.Response('', 204),
  ]) {
    test(
      'recap opened accepts ${response.statusCode} with body ${response.body}',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        bool invalidated = false;
        final client = MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, endsWith('/season-recap/9/opened'));
          return response;
        });
        final provider = Provider((ref) => _Executor(ref, _Auth(null), client));
        final api = SeasonRecapApi(
          container.read(provider),
          onOpened: () => invalidated = true,
        );
        await api.opened(9);
        expect(invalidated, isTrue);
      },
    );
  }
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

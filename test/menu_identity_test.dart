import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/auth/repository/auth_repository.dart';
import 'package:trus_app/features/main/controller/main_notifier.dart';
import 'package:trus_app/features/player/repository/player_repository.dart';
import 'package:trus_app/services/ws/player_update_service.dart';

class Auth extends Fake implements AuthRepository {
  String? name = 'První uživatel';
  @override
  String? getCurrentUserName() => name;
}

class Players extends Fake implements PlayerRepository {}

class Updates extends Fake implements PlayerUpdatesService {
  @override
  void disconnect() {}
}

void main() {
  test(
    'same menu notifier resolves logout and second account without stale name',
    () async {
      final auth = Auth();
      final container = ProviderContainer(
        overrides: [
          mainNotifierProvider.overrideWith(
            (ref) => MainNotifier(
              ref: ref,
              repository: Players(),
              authRepository: auth,
              playerUpdatesService: Updates(),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(mainNotifierProvider.notifier);
      expect(
        container.read(mainNotifierProvider).userName,
        contains('První uživatel'),
      );
      auth.name = null;
      notifier.onUpperMenuTapped();
      expect(container.read(mainNotifierProvider).userName, '');
      auth.name = 'Druhý uživatel';
      notifier.onUpperMenuTapped();
      expect(
        container.read(mainNotifierProvider).userName,
        contains('Druhý uživatel'),
      );
      expect(
        container.read(mainNotifierProvider).userName,
        isNot(contains('První')),
      );
      await Future<void>.delayed(Duration.zero);
    },
  );
}

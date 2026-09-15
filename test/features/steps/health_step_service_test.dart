import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:trus_app/features/steps/repository/health_step_service.dart';

class FakeHealth extends Health {
  final List<Object> responses;
  int calls = 0;
  FakeHealth(this.responses);
  @override
  Future<void> configure() async {}
  @override
  Future<int?> getTotalStepsInInterval(
    DateTime startTime,
    DateTime endTime, {
    bool includeManualEntry = true,
  }) async {
    final response = responses[calls++];
    if (response is int) return response;
    throw response;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final locked = PlatformException(
    code: 'STEPS_ERROR',
    message: 'Error getting step count: Protected health data is inaccessible',
  );

  test(
    'locked iOS data produces no zero days and succeeds on next read',
    () async {
      final health = FakeHealth([locked, 1234]);
      final service = HealthStepService(health: health, isIOS: true);
      expect(await service.readLastDays(days: 30), isEmpty);
      expect(health.calls, 1);
      expect((await service.readLastDays(days: 1)).single.stepCount, 1234);
    },
  );

  test(
    'successful days are retained when device locks during history read',
    () async {
      final service = HealthStepService(
        health: FakeHealth([321, locked]),
        isIOS: true,
      );
      final days = await service.readLastDays(days: 3);
      expect(days, hasLength(1));
      expect(days.single.stepCount, 321);
    },
  );

  test('unrelated errors still propagate', () async {
    final error = PlatformException(
      code: 'STEPS_ERROR',
      message: 'Unexpected query error',
    );
    final service = HealthStepService(health: FakeHealth([error]), isIOS: true);
    await expectLater(service.readLastDays(days: 1), throwsA(same(error)));
  });

  test('exception filter is restricted to the known iOS error', () {
    expect(isProtectedHealthDataUnavailable(locked, isIOS: true), isTrue);
    expect(isProtectedHealthDataUnavailable(locked, isIOS: false), isFalse);
    expect(
      isProtectedHealthDataUnavailable(
        PlatformException(code: 'OTHER', message: locked.message),
        isIOS: true,
      ),
      isFalse,
    );
  });
}

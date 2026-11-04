import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trus_app/services/app_open_tracker.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('records one start and each return from background', () async {
    final sent = <Map<String, dynamic>>[];
    final tracker = AppOpenTracker(
      (event) async => sent.add(event),
      currentUid: () => 'user-1',
      deviceId: () async => 'device-1',
    );

    await tracker.recordStart();
    await tracker.recordStart();
    await tracker.onResumed();
    tracker.onBackgrounded();
    await tracker.onResumed();

    expect(sent.map((event) => event['openType']), ['START', 'RESUME']);
    expect(
      sent.every((event) => event['clientDeviceId'] == 'device-1'),
      isTrue,
    );
    expect(sent[0]['eventId'], isNot(sent[1]['eventId']));
    expect(sent[0]['clientOpenedAt'], isNotNull);
  });

  test('keeps a failed opening and sends it on the next resume', () async {
    final sent = <Map<String, dynamic>>[];
    var fail = true;
    final tracker = AppOpenTracker(
      (event) async {
        if (fail) throw StateError('offline');
        sent.add(event);
      },
      currentUid: () => 'user-1',
      deviceId: () async => 'device-1',
    );

    await tracker.recordStart();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('pendingAppOpens'), hasLength(1));

    fail = false;
    tracker.onBackgrounded();
    await tracker.onResumed();

    expect(sent.map((event) => event['openType']), ['START', 'RESUME']);
    expect(prefs.getStringList('pendingAppOpens'), isEmpty);
  });

  test('does not attribute queued opening to another account', () async {
    final sent = <Map<String, dynamic>>[];
    var uid = 'user-1';
    var offline = true;
    final tracker = AppOpenTracker(
      (event) async {
        if (offline) throw StateError('offline');
        sent.add(event);
      },
      currentUid: () => uid,
      deviceId: () async => 'device-1',
    );

    await tracker.recordStart();
    uid = 'user-2';
    offline = false;
    tracker.onBackgrounded();
    await tracker.onResumed();

    expect(sent.map((event) => event['openType']), ['START']);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('pendingAppOpens'), hasLength(1));
  });

  test('records a new start after signing out and back in', () async {
    final sent = <Map<String, dynamic>>[];
    final tracker = AppOpenTracker(
      (event) async => sent.add(event),
      currentUid: () => 'user-1',
      deviceId: () async => 'device-1',
    );

    await tracker.recordStart();
    tracker.onSignedOut();
    await tracker.recordStart();

    expect(sent.map((event) => event['openType']), ['START', 'START']);
  });
}

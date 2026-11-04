import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/features/general/repository/request_executor.dart';
import 'package:trus_app/features/helper/shared_prefs_helper.dart';

final appOpenTrackerProvider = Provider<AppOpenTracker>((ref) {
  return AppOpenTracker((event) async {
    await ref
        .read(requestExecutorProvider)
        .executePostRequest<bool>(
          Uri.parse('$serverUrl/app-open'),
          (_) => true,
          jsonEncode(event),
          queueOnFailure: false,
        );
  });
});

class AppOpenTracker {
  AppOpenTracker(
    this._sendRequest, {
    String? Function()? currentUid,
    Future<String> Function()? deviceId,
  }) : _currentUid = currentUid ?? _firebaseUid,
       _deviceId = deviceId ?? SharedPrefsHelper().getOrCreateClientDeviceId;

  final Future<void> Function(Map<String, dynamic>) _sendRequest;
  final String? Function() _currentUid;
  final Future<String> Function() _deviceId;
  String? _startedUid;
  bool _backgrounded = false;
  Future<void> _pendingWork = Future.value();
  static const _pendingKey = 'pendingAppOpens';

  Future<void> recordStart() {
    final uid = _currentUid();
    if (uid == null || _startedUid == uid) return Future.value();
    _startedUid = uid;
    return _queueOpen('START');
  }

  void onBackgrounded() {
    _backgrounded = true;
  }

  void onSignedOut() {
    _startedUid = null;
  }

  Future<void> onResumed() {
    if (!_backgrounded) return Future.value();
    _backgrounded = false;
    final uid = _currentUid();
    if (_startedUid != uid) {
      return recordStart();
    } else if (uid != null) {
      return _queueOpen('RESUME');
    }
    return Future.value();
  }

  Future<void> _queueOpen(String openType) {
    final uid = _currentUid();
    if (uid == null) return Future.value();
    final eventId = _newEventId();
    final clientOpenedAt = DateTime.now().toUtc().toIso8601String();
    _pendingWork = _pendingWork
        .then((_) async {
          final prefs = await SharedPreferences.getInstance();
          final pending = prefs.getStringList(_pendingKey) ?? <String>[];
          final deviceId = await _deviceId();
          pending.add(
            jsonEncode({
              'uid': uid,
              'eventId': eventId,
              'clientDeviceId': deviceId,
              'openType': openType,
              'clientOpenedAt': clientOpenedAt,
            }),
          );
          await prefs.setStringList(_pendingKey, pending);
          await _flush(prefs);
        })
        .catchError((Object error) {
          debugPrint('App open could not be queued: $error');
        });
    return _pendingWork;
  }

  Future<void> _flush(SharedPreferences prefs) async {
    final pending = prefs.getStringList(_pendingKey) ?? <String>[];
    final remaining = <String>[];
    for (var index = 0; index < pending.length; index++) {
      final raw = pending[index];
      final event = jsonDecode(raw) as Map<String, dynamic>;
      if (event['uid'] != _currentUid()) {
        remaining.add(raw);
        continue;
      }
      try {
        await _sendRequest({
          'eventId': event['eventId'],
          'clientDeviceId': event['clientDeviceId'],
          'openType': event['openType'],
          'clientOpenedAt': event['clientOpenedAt'],
        });
      } catch (error) {
        debugPrint('App open will be retried: $error');
        remaining.addAll(pending.skip(index));
        break;
      }
    }
    await prefs.setStringList(_pendingKey, remaining);
  }

  static String? _firebaseUid() {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  String _newEventId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}

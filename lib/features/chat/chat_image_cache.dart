import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Persistent image cache. Keys contain the account, team, room and message ID.
class ChatImageCache {
  ChatImageCache({Future<Directory> Function()? directory})
    : _directory = directory ?? getApplicationSupportDirectory;

  final Future<Directory> Function() _directory;
  final LinkedHashMap<String, Future<Uint8List>> _recent = LinkedHashMap();

  Future<Uint8List> load({
    required String accountId,
    required int teamId,
    required String room,
    required int messageId,
    required Future<Uint8List> Function() fetch,
  }) {
    if (teamId <= 0 ||
        messageId <= 0 ||
        !const {'all', 'players'}.contains(room)) {
      throw ArgumentError('Invalid chat image key');
    }
    final account = Uri.encodeComponent(accountId);
    final key = '$account/$teamId/$room/$messageId';
    final hit = _recent.remove(key);
    if (hit != null) {
      _recent[key] = hit;
      return hit;
    }
    final future = _load(key, fetch);
    _recent[key] = future;
    if (_recent.length > 32) _recent.remove(_recent.keys.first);
    future.then<void>((_) {}, onError: (_) => _recent.remove(key));
    return future;
  }

  Future<Uint8List> _load(
    String key,
    Future<Uint8List> Function() fetch,
  ) async {
    Directory root;
    try {
      root = await _directory();
    } catch (_) {
      // The Android plugin may be unavailable until the app is fully rebuilt.
      // Keep the image available in the in-memory cache in that case.
      return fetch();
    }
    final file = File(
      '${root.path}${Platform.pathSeparator}chat-images${Platform.pathSeparator}$key.jpg',
    );
    try {
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        if (bytes.isNotEmpty) return bytes;
      }
    } on FileSystemException {
      // A damaged or inaccessible cache entry is fetched again below.
    }
    final bytes = await fetch();
    if (bytes.isEmpty) throw const FormatException('Empty chat image');
    try {
      await file.parent.create(recursive: true);
      final temporary = File('${file.path}.tmp');
      await temporary.writeAsBytes(bytes, flush: true);
      if (await file.exists()) await file.delete();
      await temporary.rename(file.path);
    } on FileSystemException {
      // Saving the cache must not make a downloaded or sent image fail.
    }
    return bytes;
  }
}

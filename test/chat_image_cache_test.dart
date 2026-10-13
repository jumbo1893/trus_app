import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/chat/chat_image_cache.dart';

void main() {
  test('chat image is reused from disk after cache is recreated', () async {
    final directory = await Directory.systemTemp.createTemp('chat-image-test-');
    addTearDown(() => directory.delete(recursive: true));
    var downloads = 0;

    Future<Uint8List> load(ChatImageCache cache) => cache.load(
      accountId: 'account',
      teamId: 7,
      room: 'players',
      messageId: 42,
      fetch: () async {
        downloads++;
        return Uint8List.fromList([1, 2, 3]);
      },
    );

    expect(await load(ChatImageCache(directory: () async => directory)), [
      1,
      2,
      3,
    ]);
    expect(await load(ChatImageCache(directory: () async => directory)), [
      1,
      2,
      3,
    ]);
    expect(downloads, 1);
  });

  test('image stays available when platform directory channel fails', () async {
    final cache = ChatImageCache(
      directory: () async => throw StateError('channel-error'),
    );
    var downloads = 0;
    Future<Uint8List> load() => cache.load(
      accountId: 'account',
      teamId: 7,
      room: 'players',
      messageId: 42,
      fetch: () async {
        downloads++;
        return Uint8List.fromList([1, 2, 3]);
      },
    );

    expect(await load(), [1, 2, 3]);
    expect(await load(), [1, 2, 3]);
    expect(downloads, 1);
  });
}

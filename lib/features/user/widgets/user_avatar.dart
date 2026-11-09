import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:trus_app/common/repository/header/cookies/header_provider.dart';
import 'package:trus_app/config.dart';

final userAvatarProvider = FutureProvider.family<Uint8List?, int>((
  ref,
  userId,
) async {
  final response = await http.get(
    Uri.parse('$serverUrl/user/$userId/avatar'),
    headers: await HeaderProvider(ref).getHeaders(),
  );
  return response.statusCode == 200 ? response.bodyBytes : null;
});

class UserAvatar extends ConsumerWidget {
  final int userId;
  final double radius;
  final Widget? fallback;

  const UserAvatar({
    super.key,
    required this.userId,
    this.radius = 20,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bytes = ref.watch(userAvatarProvider(userId)).valueOrNull;
    return CircleAvatar(
      radius: radius,
      backgroundImage: bytes == null ? null : MemoryImage(bytes),
      child: bytes == null
          ? (fallback ?? const Icon(Icons.person_outline))
          : null,
    );
  }
}

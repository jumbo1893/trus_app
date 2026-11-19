import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/football/repository/planned_match_api_service.dart';

final plannedMatchPhotoProvider = FutureProvider.family<Uint8List, int>(
  (ref, id) => ref.read(plannedMatchApiProvider).photo(id),
);

class PlannedMatchPhoto extends ConsumerWidget {
  const PlannedMatchPhoto({
    super.key,
    required this.id,
    this.height = 140,
    this.width,
  });

  final int id;
  final double height;
  final double? width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photo = ref.watch(plannedMatchPhotoProvider(id));
    return photo.when(
      data: (bytes) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          bytes,
          height: height,
          width: width,
          fit: BoxFit.cover,
        ),
      ),
      loading: () => SizedBox(
        height: height,
        width: width,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

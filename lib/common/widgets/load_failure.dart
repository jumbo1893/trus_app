import 'package:flutter/material.dart';

class LoadFailure extends StatelessWidget {
  final VoidCallback? onRetry;
  final String message;
  const LoadFailure({
    super.key,
    this.onRetry,
    this.message =
        'Data se nepodařilo načíst. Zkontroluj připojení a zkus to znovu.',
  });
  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 36),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null)
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Zkusit znovu'),
            ),
        ],
      ),
    ),
  );
}

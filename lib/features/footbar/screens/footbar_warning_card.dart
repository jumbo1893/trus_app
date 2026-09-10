import 'package:flutter/material.dart';

class FootbarWarningCard extends StatelessWidget {
  final String message;
  final VoidCallback onOpen;

  const FootbarWarningCard({
    super.key,
    required this.message,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.errorContainer,
    child: ListTile(
      leading: Icon(
        Icons.warning_amber_rounded,
        color: Theme.of(context).colorScheme.onErrorContainer,
      ),
      title: const Text('Zkontroluj propojení Footbaru'),
      subtitle: Text(message),
      trailing: const Icon(Icons.chevron_right),
      textColor: Theme.of(context).colorScheme.onErrorContainer,
      onTap: onOpen,
    ),
  );
}

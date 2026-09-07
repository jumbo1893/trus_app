import 'package:flutter/material.dart';

class SectionLink extends StatelessWidget {
  final IconData icon;
  final Widget title;
  final Widget? subtitle;
  final VoidCallback onTap;
  const SectionLink({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: title,
      subtitle: subtitle,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}

import 'package:flutter/material.dart';
import '../../models/api/match/match_api_model.dart';
import '../utils/calendar.dart';

class MatchContextHeader extends StatelessWidget {
  final MatchApiModel? match;
  final bool hasChanges;
  final VoidCallback? onChange;
  const MatchContextHeader({
    super.key,
    required this.match,
    this.hasChanges = false,
    this.onChange,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surfaceContainerLow,
    child: ListTile(
      leading: const Icon(Icons.event_outlined),
      title: Text(
        match?.name ?? 'Vyber zápas',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        [
          if (match != null) dateTimeToString(match!.date),
          if (hasChanges) 'Neuložené změny',
        ].join(' · '),
      ),
      trailing: onChange == null
          ? null
          : TextButton(onPressed: onChange, child: const Text('Změnit')),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/football/repository/planned_match_api_service.dart';
import 'package:trus_app/models/api/match/planned_match.dart';

/// Lets an editor move a planned match to another state
/// (start now, played, cancelled, restore).
class PlannedMatchStatusButton extends ConsumerStatefulWidget {
  final PlannedMatch match;
  final ValueChanged<PlannedMatch> onChanged;

  /// Shows only an overflow icon instead of a labelled button.
  final bool compact;

  const PlannedMatchStatusButton({
    super.key,
    required this.match,
    required this.onChanged,
    this.compact = false,
  });

  @override
  ConsumerState<PlannedMatchStatusButton> createState() =>
      _PlannedMatchStatusButtonState();
}

class _PlannedMatchStatusButtonState
    extends ConsumerState<PlannedMatchStatusButton> {
  bool _saving = false;

  List<(String, String, IconData)> get _options =>
      switch (widget.match.status) {
        'SCHEDULED' => [
          ('IN_PROGRESS', 'Zahájit teď', Icons.play_circle_outline),
          ('COMPLETED', 'Odehráno', Icons.check_circle_outline),
          ('CANCELLED', 'Zrušit', Icons.cancel_outlined),
        ],
        'CANCELLED' => [('SCHEDULED', 'Obnovit', Icons.restore)],
        _ => const [],
      };

  Future<void> _change(String status, String label) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$label?'),
        content: Text(switch (status) {
          'IN_PROGRESS' => 'Zápas začne teď a spustí se čas.',
          'COMPLETED' => 'Zápas se označí jako odehraný a potvrdíš sestavu.',
          'CANCELLED' => 'Událost se označí jako zrušená.',
          _ => 'Událost bude znovu naplánovaná.',
        }),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Zpět'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(label),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _saving = true);
    try {
      final result = await ref
          .read(plannedMatchApiProvider)
          .changeStatus(widget.match.id, status);
      if (mounted) widget.onChanged(result);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stav se nepodařilo změnit.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = _options;
    if (options.isEmpty) return const SizedBox.shrink();
    return PopupMenuButton<(String, String, IconData)>(
      enabled: !_saving,
      tooltip: 'Změnit stav',
      onSelected: (option) => _change(option.$1, option.$2),
      itemBuilder: (_) => [
        for (final option in options)
          PopupMenuItem(
            value: option,
            child: ListTile(
              leading: Icon(option.$3),
              title: Text(option.$2),
              contentPadding: EdgeInsets.zero,
            ),
          ),
      ],
      icon: widget.compact ? const Icon(Icons.more_vert) : null,
      child: widget.compact
          ? null
          : IgnorePointer(
              child: OutlinedButton.icon(
                onPressed: _saving ? null : () {},
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Stav zápasu'),
              ),
            ),
    );
  }
}

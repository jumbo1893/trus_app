import 'package:flutter/material.dart';

class FineMatchActionBar extends StatelessWidget {
  final int selectedCount;
  final bool compact;
  final VoidCallback onSelectAll;
  final VoidCallback onSelectPlaying;
  final VoidCallback onSelectNotPlaying;
  final VoidCallback onClearSelection;
  final VoidCallback onConfirm;

  const FineMatchActionBar({
    super.key,
    required this.selectedCount,
    this.compact = false,
    required this.onSelectAll,
    required this.onSelectPlaying,
    required this.onSelectNotPlaying,
    required this.onClearSelection,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final verticalPadding = compact ? 8.0 : 10.0;
    final spacing = compact ? 6.0 : 8.0;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(12, verticalPadding, 12, verticalPadding),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              offset: Offset(0, -4),
              color: Colors.black12,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.checklist_rounded,
                  size: 18,
                  color: Colors.black54,
                ),
                const SizedBox(width: 8),
                Text(
                  'Vybráno: $selectedCount',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing),
            Row(
              children: [
                Expanded(
                  child: _ActionChipButton(
                    label: 'Všichni',
                    icon: Icons.group,
                    onTap: onSelectAll,
                  ),
                ),
                SizedBox(width: spacing),
                Expanded(
                  child: _ActionChipButton(
                    label: 'Hrající',
                    icon: Icons.man,
                    onTap: onSelectPlaying,
                  ),
                ),
                SizedBox(width: spacing),
                Expanded(
                  child: _ActionChipButton(
                    label: 'Nehrající',
                    icon: Icons.accessible_forward,
                    onTap: onSelectNotPlaying,
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: selectedCount > 0 ? onClearSelection : null,
                    icon: const Icon(Icons.clear),
                    label: const Text('Zrušit výběr'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size.fromHeight(compact ? 44 : 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: spacing),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: selectedCount > 0 ? onConfirm : null,
                    icon: const Icon(Icons.check),
                    label: const Text('Potvrdit'),
                    style: FilledButton.styleFrom(
                      minimumSize: Size.fromHeight(compact ? 44 : 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChipButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionChipButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withAlpha(8),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.orange),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
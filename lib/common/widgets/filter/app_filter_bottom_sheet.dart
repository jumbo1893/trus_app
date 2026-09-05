import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';

typedef AppFilterBuilder<T> =
    Widget Function(BuildContext context, T value, ValueChanged<T> onChanged);

class AppFilterBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onReset;
  final VoidCallback onApply;

  const AppFilterBottomSheet({
    super.key,
    required this.title,
    required this.child,
    required this.onReset,
    required this.onApply,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required T initialValue,
    required T resetValue,
    required AppFilterBuilder<T> builder,
  }) {
    T draft = initialValue;
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) => AppFilterBottomSheet(
          title: title,
          onReset: () => setModalState(() => draft = resetValue),
          onApply: () => Navigator.of(sheetContext).pop(draft),
          child: builder(
            context,
            draft,
            (next) => setModalState(() => draft = next),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return FractionallySizedBox(
      heightFactor: 0.88,
      child: Container(
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.textMuted.withAlpha(60),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Zavřít',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: child,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onReset,
                        child: const Text('Vymazat'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: onApply,
                        child: const Text('Použít filtry'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/steps/controller/step_controller.dart';
import 'package:trus_app/models/api/step/step_models.dart';
import 'package:trus_app/theme/app_colors.dart';

class StepHistorySheet extends StatefulWidget {
  final StepController controller;
  final int? userId;
  final String initialUserName;

  const StepHistorySheet({
    super.key,
    required this.controller,
    required this.userId,
    required this.initialUserName,
  });

  static Future<void> show(
    BuildContext context, {
    required StepController controller,
    int? userId,
    String initialUserName = 'Moje kroky',
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.appColors.cardBackground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (_) => StepHistorySheet(
      controller: controller,
      userId: userId,
      initialUserName: initialUserName,
    ),
  );

  @override
  State<StepHistorySheet> createState() => _StepHistorySheetState();
}

class _StepHistorySheetState extends State<StepHistorySheet> {
  late Future<StepHistoryData> _history;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _history = widget.controller.loadHistory(userId: widget.userId);
  }

  void _retry() {
    setState(_load);
  }

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    heightFactor: 0.88,
    child: Column(
      children: [
        const _SheetHandle(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 2, 8, 12),
          child: Row(
            children: [
              Icon(
                Icons.history_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Historie kroků',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${widget.initialUserName} • posledních 30 dní',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Zavřít',
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          color: context.appColors.textSecondary.withValues(alpha: 0.15),
        ),
        Expanded(
          child: FutureBuilder<StepHistoryData>(
            future: _history,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: Loader());
              }
              if (snapshot.hasError) {
                return _HistoryError(
                  error: '${snapshot.error}',
                  onRetry: _retry,
                );
              }
              final history = snapshot.data!;
              return _HistoryContent(history: history);
            },
          ),
        ),
      ],
    ),
  );
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 42,
      height: 5,
      margin: const EdgeInsets.only(top: 10, bottom: 8),
      decoration: BoxDecoration(
        color: context.appColors.textSecondary.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(999),
      ),
    ),
  );
}

class _HistoryContent extends StatelessWidget {
  final StepHistoryData history;

  const _HistoryContent({required this.history});

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.decimalPattern('cs_CZ');
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        Text(
          history.userName,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryValue(
                    label: 'Celkem',
                    value: '${numberFormat.format(history.totalSteps)} kroků',
                  ),
                ),
                Container(
                  width: 1,
                  height: 42,
                  color: context.appColors.textSecondary.withValues(
                    alpha: 0.18,
                  ),
                ),
                Expanded(
                  child: _SummaryValue(
                    label: 'Průměr',
                    value: '${numberFormat.format(history.averageSteps)} / den',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var index = 0; index < history.days.length; index++) ...[
                _HistoryDayRow(
                  day: history.days[index],
                  numberFormat: numberFormat,
                ),
                if (index < history.days.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryValue extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(label, style: TextStyle(color: context.appColors.textSecondary)),
      const SizedBox(height: 4),
      Text(
        value,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ],
  );
}

class _HistoryDayRow extends StatelessWidget {
  final StepHistoryDay day;
  final NumberFormat numberFormat;

  const _HistoryDayRow({required this.day, required this.numberFormat});

  @override
  Widget build(BuildContext context) {
    final steps = day.stepCount;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.12),
        child: Text('${day.date.day}.'),
      ),
      title: Text(_formatHistoryDate(day.date)),
      trailing: Text(
        steps == null ? 'Bez dat' : '${numberFormat.format(steps)} kroků',
        style: TextStyle(
          fontWeight: steps == null ? FontWeight.w400 : FontWeight.w700,
          color: steps == null ? context.appColors.textSecondary : null,
        ),
      ),
    );
  }
}

class _HistoryError extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _HistoryError({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 44),
          const SizedBox(height: 12),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Zkusit znovu')),
        ],
      ),
    ),
  );
}

String _formatHistoryDate(DateTime date) {
  final today = DateTime.now();
  final isToday =
      date.year == today.year &&
      date.month == today.month &&
      date.day == today.day;
  final formatted = '${date.day}. ${date.month}. ${date.year}';
  return isToday ? 'Dnes • $formatted' : formatted;
}

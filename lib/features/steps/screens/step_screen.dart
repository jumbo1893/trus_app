import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/common/widgets/screen/custom_consumer_stateful_widget.dart';
import 'package:trus_app/features/steps/controller/step_controller.dart';
import 'package:trus_app/features/steps/screens/step_history_sheet.dart';
import 'package:trus_app/features/steps/state/step_state.dart';
import 'package:trus_app/models/api/step/step_models.dart';
import 'package:trus_app/theme/app_colors.dart';

class StepScreen extends CustomConsumerStatefulWidget {
  static const String id = 'step-screen';
  const StepScreen({super.key}) : super(title: 'Kroky', name: id);

  @override
  ConsumerState<StepScreen> createState() => _StepScreenState();
}

class _StepScreenState extends ConsumerState<StepScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stepControllerProvider);
    final controller = ref.read(stepControllerProvider.notifier);
    return Scaffold(
      backgroundColor: context.appColors.backgroundPrimary,
      body: SafeArea(
        child: state.consent.when(
          loading: () => const Loader(),
          error: (error, _) =>
              _ErrorView(message: '$error', onRetry: controller.load),
          data: (enabled) => enabled
              ? _LeaderboardView(state: state, controller: controller)
              : _ConsentView(onGrant: controller.grantConsent),
        ),
      ),
    );
  }
}

class _ConsentView extends StatelessWidget {
  final VoidCallback onGrant;
  const _ConsentView({required this.onGrant});

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Icon(
            Icons.directions_walk_rounded,
            size: 76,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 22),
          Text(
            'Týmová výzva v krocích',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            'Pro zobrazení statistik musíte udělit souhlas se čtením počtu kroků. '
            'Do týmu se sdílí pouze denní součet, nikoliv trasa ani další zdravotní údaje.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.appColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: onGrant,
            icon: const Icon(Icons.favorite_outline),
            label: const Text('Udělit souhlas'),
          ),
        ],
      ),
    ),
  );
}

class _LeaderboardView extends StatelessWidget {
  final StepsState state;
  final StepController controller;
  const _LeaderboardView({required this.state, required this.controller});

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: controller.syncAndLoad,
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Card(
          child: SwitchListTile.adaptive(
            value: true,
            onChanged: (enabled) {
              if (!enabled) controller.revokeConsent();
            },
            secondary: const Icon(Icons.directions_walk_rounded),
            title: const Text('Sdílet moje kroky s týmem'),
            subtitle: Text(
              state.syncing
                  ? 'Právě synchronizuji posledních 30 dní…'
                  : 'Aktualizace proběhne při otevření této sekce.',
            ),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () =>
              StepHistorySheet.show(context, controller: controller),
          icon: const Icon(Icons.history_rounded),
          label: const Text('Moje historie kroků'),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<StepPeriod>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: StepPeriod.today, label: Text('Dnes')),
              ButtonSegment(
                value: StepPeriod.betweenMatches,
                label: Text('Do zápasu'),
              ),
              ButtonSegment(
                value: StepPeriod.sinceLastMatch,
                label: Text('Od zápasu'),
              ),
              ButtonSegment(value: StepPeriod.allTime, label: Text('Celkem')),
            ],
            selected: {state.period},
            onSelectionChanged: (values) =>
                controller.selectPeriod(values.first),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Pořadí týmu',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        _SortControls(
          period: state.period,
          sort: state.currentSort,
          onFieldChanged: controller.selectSortField,
          onDirectionChanged: controller.toggleSortDirection,
        ),
        const SizedBox(height: 10),
        state.leaderboard.when(
          loading: () =>
              const Padding(padding: EdgeInsets.all(32), child: Loader()),
          error: (error, _) => _ErrorView(
            message: '$error',
            onRetry: controller.loadLeaderboard,
          ),
          data: (leaderboard) => _LeaderboardTable(
            data: leaderboard,
            period: state.period,
            sort: state.currentSort,
            onEntryTap: (entry) => StepHistorySheet.show(
              context,
              controller: controller,
              userId: entry.userId,
              initialUserName: entry.userName,
            ),
          ),
        ),
      ],
    ),
  );
}

class _SortControls extends StatelessWidget {
  final StepPeriod period;
  final StepSortConfig sort;
  final ValueChanged<StepSortField> onFieldChanged;
  final VoidCallback onDirectionChanged;

  const _SortControls({
    required this.period,
    required this.sort,
    required this.onFieldChanged,
    required this.onDirectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final fields = period == StepPeriod.allTime
        ? const [
            StepSortField.averageStepsPerDay,
            StepSortField.steps,
            StepSortField.days,
            StepSortField.name,
          ]
        : const [StepSortField.steps, StepSortField.name];
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 4),
        child: Row(
          children: [
            const Icon(Icons.sort_rounded),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<StepSortField>(
                  value: sort.field,
                  isExpanded: true,
                  items: [
                    for (final field in fields)
                      DropdownMenuItem(
                        value: field,
                        child: Text(_sortFieldLabel(field)),
                      ),
                  ],
                  onChanged: (field) {
                    if (field != null) onFieldChanged(field);
                  },
                ),
              ),
            ),
            IconButton(
              onPressed: onDirectionChanged,
              tooltip: sort.descending ? 'Řadit vzestupně' : 'Řadit sestupně',
              icon: Icon(
                sort.descending
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardTable extends StatelessWidget {
  final StepLeaderboardData data;
  final StepPeriod period;
  final StepSortConfig sort;
  final ValueChanged<StepLeaderboardEntry> onEntryTap;

  const _LeaderboardTable({
    required this.data,
    required this.period,
    required this.sort,
    required this.onEntryTap,
  });

  @override
  Widget build(BuildContext context) {
    final entries = sort.sort(data.entries);
    final isMatchPeriod =
        period == StepPeriod.betweenMatches ||
        period == StepPeriod.sinceLastMatch;
    if (entries.isEmpty && !isMatchPeriod) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 42),
        child: Center(
          child: Text('Zatím nikdo nesdílí kroky pro toto období.'),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (period == StepPeriod.betweenMatches) ...[
            _BetweenMatchesHeader(
              previousMatch: data.previousMatch,
              lastMatch: data.lastMatch,
            ),
            const Divider(height: 1),
          ] else if (period == StepPeriod.sinceLastMatch) ...[
            _SinceLastMatchHeader(lastMatch: data.lastMatch),
            const Divider(height: 1),
          ],
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: Text(
                'Zatím nikdo nesdílí kroky pro toto období.',
                textAlign: TextAlign.center,
              ),
            )
          else
            for (var index = 0; index < entries.length; index++) ...[
              _LeaderboardRow(
                rank: index + 1,
                entry: entries[index],
                showAllTimeStats: period == StepPeriod.allTime,
                highlightRank:
                    sort.descending && sort.field != StepSortField.name,
                onTap: () => onEntryTap(entries[index]),
              ),
              if (index < entries.length - 1) const Divider(height: 1),
            ],
        ],
      ),
    );
  }
}

class _SinceLastMatchHeader extends StatelessWidget {
  final StepMatch? lastMatch;

  const _SinceLastMatchHeader({required this.lastMatch});

  @override
  Widget build(BuildContext context) {
    final match = lastMatch;
    return ListTile(
      leading: const Icon(Icons.sports_soccer_rounded),
      title: Text(
        match == null
            ? 'Bez odehraného zápasu'
            : 'Od zápasu s ${match.opponentName}',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        match == null
            ? 'Pro toto období se zobrazují dnešní kroky.'
            : 'Poslední zápas: ${_formatDate(match.date)}',
      ),
    );
  }
}

class _BetweenMatchesHeader extends StatelessWidget {
  final StepMatch? previousMatch;
  final StepMatch? lastMatch;

  const _BetweenMatchesHeader({
    required this.previousMatch,
    required this.lastMatch,
  });

  @override
  Widget build(BuildContext context) {
    final previous = previousMatch;
    final last = lastMatch;
    if (previous == null || last == null) {
      return const ListTile(
        leading: Icon(Icons.sports_soccer_rounded),
        title: Text(
          'Chybí dva odehrané zápasy',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          'Období „Do zápasu“ bude dostupné po druhém odehraném zápase.',
        ),
      );
    }
    return ListTile(
      leading: const Icon(Icons.sports_soccer_rounded),
      title: Text(
        '${previous.opponentName} → ${last.opponentName}',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        '${_formatDate(previous.date)} – ${_formatDate(last.date)}',
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final StepLeaderboardEntry entry;
  final bool showAllTimeStats;
  final bool highlightRank;
  final VoidCallback onTap;

  const _LeaderboardRow({
    required this.rank,
    required this.entry,
    required this.showAllTimeStats,
    required this.highlightRank,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = !highlightRank
        ? context.appColors.textSecondary
        : rank == 1
        ? Colors.amber.shade700
        : rank == 2
        ? Colors.blueGrey
        : rank == 3
        ? Colors.brown.shade400
        : context.appColors.textSecondary;
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.14),
        foregroundColor: color,
        child: Text(
          '$rank',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      title: Text(
        entry.userName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: showAllTimeStats
          ? Text(
              '${_formatDayCount(entry.dayCount)} • '
              'průměr ${NumberFormat.decimalPattern('cs_CZ').format(entry.averageStepsPerDay.round())} kroků/den',
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${NumberFormat.decimalPattern('cs_CZ').format(entry.stepCount)} kroků',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) => '${date.day}. ${date.month}. ${date.year}';

String _formatDayCount(int count) {
  if (count == 1) return '1 den';
  if (count >= 2 && count <= 4) return '$count dny';
  return '$count dní';
}

String _sortFieldLabel(StepSortField field) => switch (field) {
  StepSortField.name => 'Jméno',
  StepSortField.steps => 'Počet kroků',
  StepSortField.days => 'Počet dní',
  StepSortField.averageStepsPerDay => 'Průměr kroků za den',
};

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Zkusit znovu')),
        ],
      ),
    ),
  );
}

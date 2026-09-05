import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/filter/app_filter_bottom_sheet.dart';
import 'package:trus_app/common/widgets/filter/app_filter_multi_selection_field.dart';
import 'package:trus_app/config.dart';
import '../filter/statistics_filter.dart';
import '../filter/statistics_filter_options.dart';
import '../stat_args.dart';

Future<StatisticsFilter?> showStatisticsFilterSheet(
  BuildContext context, {
  required StatsArgs args,
  required StatisticsFilter filter,
}) => AppFilterBottomSheet.show<StatisticsFilter>(
  context,
  title: 'Filtrovat statistiky',
  initialValue: filter,
  resetValue: const StatisticsFilter(),
  builder: (context, draft, onChanged) => Consumer(
    builder: (context, ref, _) => ref
        .watch(statisticsFilterOptionsProvider(args))
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Column(
            children: [
              const Text('Volby filtrů se nepodařilo načíst.'),
              TextButton(
                onPressed: () =>
                    ref.invalidate(statisticsFilterOptionsProvider(args)),
                child: const Text('Zkusit znovu'),
              ),
            ],
          ),
          data: (options) => StatisticsFilterFields(
            args: args,
            filter: draft,
            options: options,
            onChanged: onChanged,
          ),
        ),
  ),
);

class StatisticsFilterFields extends StatelessWidget {
  final StatsArgs args;
  final StatisticsFilter filter;
  final StatisticsFilterOptions options;
  final ValueChanged<StatisticsFilter> onChanged;
  const StatisticsFilterFields({
    super.key,
    required this.args,
    required this.filter,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      AppFilterMultiSelectionField<int>(
        label: 'Sezona',
        hint: 'Všechny sezony',
        searchHint: 'Hledat sezonu',
        values: filter.seasonIds,
        items: options.seasons.map((s) => s.id).whereType<int>().toList(),
        itemLabel: (id) => options.seasons.firstWhere((s) => s.id == id).name,
        onChanged: (ids) => onChanged(filter.copyWith(seasonIds: ids)),
      ),
      const SizedBox(height: 20),
      if (args.matchOrPlayer)
        AppFilterMultiSelectionField<int>(
          label: 'Hráči a fanoušci',
          hint: 'Všichni hráči a fanoušci',
          searchHint: 'Hledat hráče nebo fanouška',
          values: filter.playerIds,
          items: options.players.map((p) => p.id).whereType<int>().toList(),
          itemLabel: (id) {
            final player = options.players.firstWhere((p) => p.id == id);
            return '${player.name} · ${player.fan ? 'fanoušek' : 'hráč'}';
          },
          onChanged: (ids) => onChanged(filter.copyWith(playerIds: ids)),
        )
      else
        AppFilterMultiSelectionField<String>(
          label: 'Soupeři',
          hint: 'Všichni soupeři (napříč sezonami)',
          searchHint: 'Hledat soupeře',
          values: filter.opponentNames,
          items: options.opponents,
          itemLabel: (name) => name,
          onChanged: (names) =>
              onChanged(filter.copyWith(opponentNames: names)),
        ),
      if (args.api == receivedFineApi) ...[
        const SizedBox(height: 20),
        AppFilterMultiSelectionField<int>(
          label: 'Pokuty',
          hint: 'Všechny pokuty',
          searchHint: 'Hledat pokutu',
          values: filter.fineIds,
          items: options.fines.map((f) => f.id).whereType<int>().toList(),
          itemLabel: (id) {
            final fine = options.fines.firstWhere((f) => f.id == id);
            return '${fine.name} · ${fine.amount} Kč${fine.inactive ? ' (historická)' : ''}';
          },
          onChanged: (ids) => onChanged(filter.copyWith(fineIds: ids)),
        ),
      ],
      const SizedBox(height: 20),
      Material(
        color: Colors.transparent,
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Řadit sestupně'),
          value: filter.descending,
          onChanged: (value) => onChanged(filter.copyWith(descending: value)),
        ),
      ),
    ],
  );
}

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
  builder: (context, draft, onChanged) =>
      _LazyStatisticsFields(args: args, filter: draft, onChanged: onChanged),
);

class _LazyStatisticsFields extends ConsumerWidget {
  final StatsArgs args;
  final StatisticsFilter filter;
  final ValueChanged<StatisticsFilter> onChanged;
  const _LazyStatisticsFields({
    required this.args,
    required this.filter,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasons = ref.watch(statisticsSeasonsProvider);
    final playerLabels = ref.watch(statisticsPlayerLabelsProvider);
    final fineLabels = ref.watch(statisticsFineLabelsProvider);
    final provider = statisticsContextOptionsProvider(
      StatsArgs(
        args.api,
        args.matchOrPlayer,
        seasonIds: filter.seasonIds,
        fineIds: filter.fineIds,
      ),
    );
    var groups = <String, Set<String>>{};
    final playerDescriptions = <int, String>{};
    final fineDescriptions = <int, String>{};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Týmové statistiky · jedna, více nebo všechny sezony'),
        const SizedBox(height: 12),
        AppFilterMultiSelectionField<int>(
          label: 'Sezona',
          hint: 'Všechny sezony',
          allLabel: 'Všechny sezony',
          searchHint: 'Hledat sezonu',
          values: filter.seasonIds,
          items:
              seasons.valueOrNull?.map((s) => s.id).whereType<int>().toList() ??
              [],
          loadItems: () async {
            if (ref.read(statisticsSeasonsProvider).hasError)
              ref.invalidate(statisticsSeasonsProvider);
            return (await ref.read(
              statisticsSeasonsProvider.future,
            )).map((s) => s.id).whereType<int>().toList();
          },
          itemLabel: (id) =>
              ref
                  .read(statisticsSeasonsProvider)
                  .valueOrNull
                  ?.where((s) => s.id == id)
                  .firstOrNull
                  ?.name ??
              'Sezona $id',
          onChanged: (ids) => onChanged(
            filter.copyWith(seasonIds: ids, playerIds: {}, opponentNames: {}),
          ),
        ),
        const SizedBox(height: 12),
        if (args.matchOrPlayer)
          AppFilterMultiSelectionField<int>(
            label: 'Hráči a fanoušci',
            hint: 'Všichni hráči a fanoušci',
            searchHint: 'Hledat hráče nebo fanouška',
            values: filter.playerIds,
            items: const [],
            loadItems: () async {
              if (ref.read(provider).hasError) ref.invalidate(provider);
              final players = (await ref.read(provider.future)).players;
              playerDescriptions.addAll({
                for (final p in players)
                  if (p.id != null)
                    p.id!: '${p.name} · ${p.fan ? 'fanoušek' : 'hráč'}',
              });
              return players.map((p) => p.id).whereType<int>().toList();
            },
            itemLabel: (id) =>
                playerDescriptions[id] ??
                ref.read(statisticsPlayerLabelsProvider)[id] ??
                playerLabels[id] ??
                'Hráč $id',
            onChanged: (ids) => onChanged(filter.copyWith(playerIds: ids)),
          )
        else
          AppFilterMultiSelectionField<String>(
            label: 'Soupeři',
            hint: 'Všichni soupeři',
            searchHint: 'Hledat soupeře',
            values: filter.opponentNames
                .map(StatisticsFilterOptions.opponentKey)
                .toSet(),
            items: const [],
            loadItems: () async {
              if (ref.read(provider).hasError) ref.invalidate(provider);
              groups = (await ref.read(provider.future)).opponentGroups;
              return groups.keys.toList()..sort();
            },
            itemLabel: (key) => StatisticsFilterOptions.opponentLabel(
              groups[key] ??
                  filter.opponentNames
                      .where(
                        (n) => StatisticsFilterOptions.opponentKey(n) == key,
                      )
                      .toSet()
                      .union({key}),
            ),
            onChanged: (names) => onChanged(
              filter.copyWith(
                opponentNames: {
                  for (final key in names) ...groups[key] ?? {key},
                },
              ),
            ),
          ),
        if (args.api == receivedFineApi) ...[
          const SizedBox(height: 12),
          AppFilterMultiSelectionField<int>(
            label: 'Pokuty',
            hint: 'Všechny pokuty',
            searchHint: 'Hledat pokutu',
            values: filter.fineIds,
            items: const [],
            loadItems: () async {
              if (ref.read(statisticsFineOptionsProvider).hasError)
                ref.invalidate(statisticsFineOptionsProvider);
              final fines = await ref.read(
                statisticsFineOptionsProvider.future,
              );
              fineDescriptions.addAll({
                for (final f in fines)
                  if (f.id != null)
                    f.id!:
                        '${f.name} · ${f.amount} Kč${f.inactive ? ' (historická)' : ''}',
              });
              return fines.map((f) => f.id).whereType<int>().toList();
            },
            itemLabel: (id) =>
                fineDescriptions[id] ??
                ref.read(statisticsFineLabelsProvider)[id] ??
                fineLabels[id] ??
                'Pokuta $id',
            onChanged: (ids) => onChanged(
              filter.copyWith(fineIds: ids, playerIds: {}, opponentNames: {}),
            ),
          ),
        ],
        Material(
          color: Colors.transparent,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Řadit sestupně'),
            value: filter.descending,
            onChanged: (v) => onChanged(filter.copyWith(descending: v)),
          ),
        ),
      ],
    );
  }
}

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
  Widget build(BuildContext context) {
    final opponents = options.opponentGroups;
    return Column(
      children: [
        AppFilterMultiSelectionField<int>(
          label: 'Sezona',
          hint: 'Všechny sezony',
          allLabel: 'Všechny sezony',
          searchHint: 'Hledat sezonu',
          values: filter.seasonIds,
          items: options.seasons.map((s) => s.id).whereType<int>().toList(),
          itemLabel: (id) => options.seasons.firstWhere((s) => s.id == id).name,
          onChanged: (ids) => onChanged(
            filter.copyWith(seasonIds: ids, playerIds: {}, opponentNames: {}),
          ),
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
            hint: 'Všichni soupeři',
            searchHint: 'Hledat soupeře',
            values: filter.opponentNames
                .map(StatisticsFilterOptions.opponentKey)
                .toSet(),
            items: opponents.keys.toList()..sort(),
            itemLabel: (key) =>
                StatisticsFilterOptions.opponentLabel(opponents[key] ?? {key}),
            onChanged: (names) => onChanged(
              filter.copyWith(
                opponentNames: {
                  for (final key in names) ...opponents[key] ?? {key},
                },
              ),
            ),
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
            onChanged: (ids) => onChanged(
              filter.copyWith(fineIds: ids, playerIds: {}, opponentNames: {}),
            ),
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
}

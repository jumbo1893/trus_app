import '../../../config.dart';
import '../../../models/api/season_api_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/filter/app_filter_bottom_sheet.dart';
import '../../../common/widgets/filter/app_search_filter_bar.dart';
import '../../../models/api/interfaces/dropdown_item.dart';

class StatisticsDropdownFilter {
  final String label;
  final AsyncValue<List<DropdownItem>> items;
  final DropdownItem? selected;
  final ValueChanged<DropdownItem> onChanged;
  const StatisticsDropdownFilter({
    required this.label,
    required this.items,
    required this.selected,
    required this.onChanged,
  });
}

/// Uses the same search bar and apply/cancel filter sheet as team statistics.
class StatisticsDropdownFilterBar extends ConsumerWidget {
  final List<StatisticsDropdownFilter> Function(WidgetRef) fields;
  final String query, searchHint;
  final ValueChanged<String> onQueryChanged;
  const StatisticsDropdownFilterBar({
    super.key,
    required this.fields,
    required this.query,
    required this.searchHint,
    required this.onQueryChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = fields(ref);
    DropdownItem? resetFor(StatisticsDropdownFilter field) {
      final items = field.items.asData?.value;
      return items
              ?.where(
                (item) => item is SeasonApiModel && item.id == allSeasonId,
              )
              .firstOrNull ??
          items?.firstOrNull;
    }

    bool visible(StatisticsDropdownFilter field) =>
        field.selected != null &&
        !(field.selected is SeasonApiModel &&
            (field.selected as SeasonApiModel).id == allSeasonId);
    return AppSearchFilterBar(
      query: query,
      searchHint: searchHint,
      onQueryChanged: onQueryChanged,
      activeFilterCount: current
          .where((f) => visible(f) && f.selected != resetFor(f))
          .length,
      activeFilters: [
        for (final field in current.where(visible))
          InputChip(
            label: Text(field.selected!.dropdownItem()),
            onDeleted:
                field.selected != resetFor(field) && resetFor(field) != null
                ? () => field.onChanged(resetFor(field)!)
                : null,
            deleteButtonTooltipMessage: 'Zrušit: ${field.label}',
          ),
      ],
      onClear: () {
        onQueryChanged('');
        for (final field in current) {
          final options = field.items.asData?.value;
          if (options != null && options.isNotEmpty) {
            field.onChanged(resetFor(field)!);
          }
        }
      },
      onFilterPressed: () async {
        FocusManager.instance.primaryFocus?.unfocus();
        final result = await AppFilterBottomSheet.show<List<DropdownItem?>>(
          context,
          title: 'Filtrovat statistiky',
          initialValue: current.map((f) => f.selected).toList(),
          resetValue: current.map(resetFor).toList(),
          builder: (context, draft, change) => Consumer(
            builder: (context, sheetRef, _) {
              final live = fields(sheetRef);
              return Column(
                children: [
                  for (var i = 0; i < live.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: live[i].items.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => Text(
                          '${live[i].label}: volby se nepodařilo načíst.',
                        ),
                        data: (items) => DropdownButtonFormField<DropdownItem>(
                          key: ValueKey('${live[i].label}-${draft[i]}'),
                          initialValue: items.any((item) => item == draft[i])
                              ? draft[i]
                              : null,
                          isExpanded: true,
                          decoration: InputDecoration(labelText: live[i].label),
                          items: [
                            for (final item in items)
                              DropdownMenuItem(
                                value: item,
                                child: Text(
                                  item.dropdownItem(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: (value) {
                            final next = [...draft];
                            next[i] = value;
                            change(next);
                          },
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
        if (!context.mounted || result == null) return;
        final latest = fields(ref);
        for (var i = 0; i < latest.length; i++) {
          final match = latest[i].items.asData?.value
              .where((item) => item == result[i])
              .firstOrNull;
          if (match != null && latest[i].selected != match) {
            latest[i].onChanged(match);
          }
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:trus_app/common/utils/search_text.dart';
import 'package:trus_app/theme/app_colors.dart';

class AppFilterMultiSelectionField<T> extends StatelessWidget {
  final String label;
  final String hint;
  final String searchHint;
  final Set<T> values;
  final List<T> items;
  final String Function(T value) itemLabel;
  final ValueChanged<Set<T>> onChanged;

  const AppFilterMultiSelectionField({
    super.key,
    required this.label,
    required this.hint,
    required this.searchHint,
    required this.values,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  Future<void> _openSelection(BuildContext context) async {
    if (items.isEmpty) return;

    FocusManager.instance.primaryFocus?.unfocus();
    final selection = await showModalBottomSheet<Set<T>>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterMultiSelectionSheet<T>(
        title: label,
        searchHint: searchHint,
        selected: values,
        items: items,
        itemLabel: itemLabel,
      ),
    );
    if (selection != null && context.mounted) {
      onChanged(Set.unmodifiable(selection));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        Material(
          color: colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _openSelection(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectionLabel(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: values.isEmpty
                            ? colors.textMuted
                            : colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (values.isNotEmpty)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Zrušit výběr',
                      onPressed: () => onChanged(<T>{}),
                      icon: Icon(
                        Icons.close_rounded,
                        color: colors.textSecondary,
                      ),
                    )
                  else
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colors.textSecondary,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _selectionLabel() {
    if (values.isEmpty) return hint;
    if (values.length == 1) return itemLabel(values.first);
    return 'Vybráno: ${values.length}';
  }
}

class _FilterMultiSelectionSheet<T> extends StatefulWidget {
  final String title;
  final String searchHint;
  final Set<T> selected;
  final List<T> items;
  final String Function(T value) itemLabel;

  const _FilterMultiSelectionSheet({
    required this.title,
    required this.searchHint,
    required this.selected,
    required this.items,
    required this.itemLabel,
  });

  @override
  State<_FilterMultiSelectionSheet<T>> createState() =>
      _FilterMultiSelectionSheetState<T>();
}

class _FilterMultiSelectionSheetState<T>
    extends State<_FilterMultiSelectionSheet<T>> {
  String query = '';
  late Set<T> selected;

  @override
  void initState() {
    super.initState();
    selected = {...widget.selected};
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final normalizedQuery = normalizeSearchText(query);
    final visibleItems = widget.items
        .where(
          (item) => normalizeSearchText(
            widget.itemLabel(item),
          ).contains(normalizedQuery),
        )
        .toList();

    return FractionallySizedBox(
      heightFactor: 0.78,
      child: Material(
        color: colors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        clipBehavior: Clip.antiAlias,
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
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: TextField(
                  autofocus: false,
                  onChanged: (value) => setState(() => query = value),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded),
                    hintText: widget.searchHint,
                    filled: true,
                    fillColor: colors.backgroundSecondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: visibleItems.isEmpty
                    ? Center(
                        child: Text(
                          'Žádné položky neodpovídají hledání',
                          style: TextStyle(color: colors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        itemCount: visibleItems.length,
                        itemBuilder: (context, index) {
                          final item = visibleItems[index];
                          final isSelected = selected.contains(item);
                          return CheckboxListTile(
                            value: isSelected,
                            selected: isSelected,
                            selectedTileColor: colors.accent.withAlpha(18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            title: Text(widget.itemLabel(item)),
                            controlAffinity: ListTileControlAffinity.trailing,
                            onChanged: (_) => setState(() {
                              if (isSelected) {
                                selected.remove(item);
                              } else {
                                selected.add(item);
                              }
                            }),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(selected.clear),
                        child: const Text('Vymazat'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(selected),
                        child: const Text('Použít výběr'),
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

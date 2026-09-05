import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:trus_app/theme/app_widget_values.dart';

class AppSearchFilterBar extends StatefulWidget {
  final String query;
  final String searchHint;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onFilterPressed;
  final VoidCallback onClear;
  final int activeFilterCount;

  const AppSearchFilterBar({
    super.key,
    required this.query,
    required this.searchHint,
    required this.onQueryChanged,
    required this.onFilterPressed,
    required this.onClear,
    required this.activeFilterCount,
  });

  @override
  State<AppSearchFilterBar> createState() => _AppSearchFilterBarState();
}

class _AppSearchFilterBarState extends State<AppSearchFilterBar> {
  late final TextEditingController _controller;
  late String _localQuery;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
    _localQuery = widget.query;
  }

  @override
  void didUpdateWidget(covariant AppSearchFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.query) {
      _localQuery = widget.query;
      _controller.value = TextEditingValue(
        text: widget.query,
        selection: TextSelection.collapsed(offset: widget.query.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasFilters =
        _localQuery.trim().isNotEmpty || widget.activeFilterCount > 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppWidgetValues.borderRadiusMd,
        boxShadow: AppWidgetValues.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            padding: const EdgeInsets.only(left: 14),
            decoration: BoxDecoration(
              color: colors.backgroundSecondary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: colors.textSecondary,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: (value) {
                      setState(() => _localQuery = value);
                      widget.onQueryChanged(value);
                    },
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: widget.searchHint,
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ),
                if (_localQuery.isNotEmpty)
                  IconButton(
                    tooltip: 'Vymazat hledání',
                    onPressed: () {
                      _controller.clear();
                      widget.onQueryChanged('');
                      setState(() => _localQuery = '');
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      color: colors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onFilterPressed,
                  icon: const Icon(Icons.tune_rounded, size: 19),
                  label: Text(
                    widget.activeFilterCount == 0
                        ? 'Filtry'
                        : 'Filtry (${widget.activeFilterCount})',
                  ),
                ),
              ),
              if (hasFilters) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: widget.onClear,
                  child: const Text('Zrušit filtry'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

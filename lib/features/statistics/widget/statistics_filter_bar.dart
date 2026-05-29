import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../statistics/controller/stats_notifier.dart';
import '../../statistics/stat_args.dart';
import '../../statistics/state/stats_state.dart';

class StatisticsFilterBar extends ConsumerStatefulWidget {
  final Widget seasonDropdown;
  final StatsArgs statsArgs;

  const StatisticsFilterBar({
    super.key,
    required this.seasonDropdown,
    required this.statsArgs,
  });

  @override
  ConsumerState<StatisticsFilterBar> createState() => _StatisticsFilterBarState();
}

class _StatisticsFilterBarState extends ConsumerState<StatisticsFilterBar> {
  final TextEditingController _searchController = TextEditingController();
  bool orderDescending = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch() {
    ref.read(statsNotifierProvider(widget.statsArgs).notifier).search(
      _searchController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<StatsState>(statsNotifierProvider(widget.statsArgs), (_, next) {
      final newFilter = next.filter ?? '';
      if (_searchController.text != newFilter) {
        _searchController.text = newFilter;
      }
    });

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 6),
            color: context.appColors.shadow.withAlpha(31),
          ),
        ],
      ),
      child: Column(
        children: [
          widget.seasonDropdown,
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: context.appColors.shadow.withAlpha(8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: context.appColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Hledat hráče',
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _submitSearch(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: context.appColors.shadow.withAlpha(8),
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    setState(() {
                      orderDescending = !orderDescending;
                    });
                    ref
                        .read(statsNotifierProvider(widget.statsArgs).notifier)
                        .toggleOrder();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    child: Icon(
                      orderDescending
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color: context.appColors.legacyAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
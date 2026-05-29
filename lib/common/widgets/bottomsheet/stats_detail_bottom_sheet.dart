import 'package:flutter/material.dart';
import 'package:trus_app/models/api/beer/beer_detailed_model.dart';
import 'package:trus_app/models/api/goal/goal_detailed_model.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';
import 'package:trus_app/models/api/receivedfine/received_fine_detailed_model.dart';
import 'package:trus_app/theme/app_colors.dart';
import 'package:trus_app/theme/app_widget_values.dart';

class StatsDetailBottomSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<ModelToString> items;

  const StatsDetailBottomSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.items,
  });

  static Future<void> show(
      BuildContext context, {
        required String title,
        required String subtitle,
        required List<ModelToString> items,
      }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatsDetailBottomSheet(
        title: title,
        subtitle: subtitle,
        items: items,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomSpacing = MediaQuery.viewPaddingOf(context).bottom + 8;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final availableHeight = screenHeight - bottomSpacing;

    // Přibližná výška pevné části:
    // handle + mezery + header + odsazení seznamu.
    const fixedContentHeight = 160.0;

    // Jeden řádek obsahuje název i spodní metrické labely.
    const rowHeight = 86.0;

    final requiredContentHeight =
        fixedContentHeight + (items.length * rowHeight);

    final preferredInitialSize = switch (items.length) {
      0 => 0.38,
      <= 2 => requiredContentHeight / availableHeight,
      <= 5 => 0.58,
      <= 9 => 0.70,
      _ => 0.80,
    };

    final initialSize = preferredInitialSize
        .clamp(0.38, 0.94)
        .toDouble();

    return Padding(
      padding: EdgeInsets.fromLTRB(8, 0, 8, bottomSpacing),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: initialSize,
        minChildSize: 0.34,
        maxChildSize: 0.94,
        builder: (context, scrollController) {
          return _StatsSheetContent(
            title: title,
            subtitle: subtitle,
            items: items,
            scrollController: scrollController,
          );
        },
      ),
    );
  }
}

class _StatsSheetContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<ModelToString> items;
  final ScrollController scrollController;

  const _StatsSheetContent({
    required this.title,
    required this.subtitle,
    required this.items,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final type = _StatsDisplayType.fromItems(items);

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
          bottom: Radius.circular(24),
        ),
        boxShadow: AppWidgetValues.cardShadow,
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          _SheetHandle(
            color: colors.textMuted.withAlpha(60),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _StatsHeader(
              title: title,
              subtitle: subtitle,
              type: type,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: items.isEmpty
                ? const _EmptyStatsContent()
                : ListView.separated(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              itemCount: items.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 56,
                color: colors.textMuted.withAlpha(30),
              ),
              itemBuilder: (_, index) => _StatsDetailRow(
                item: items[index],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final _StatsDisplayType type;

  const _StatsHeader({
    required this.title,
    required this.subtitle,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: colors.accentSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: colors.accent.withAlpha(28),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              type.icon,
              color: colors.accent,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.label,
                  style: TextStyle(
                    color: colors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.35,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    height: 1.25,
                  ),
                ),
                if (subtitle.trim().isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsDetailRow extends StatelessWidget {
  final ModelToString item;

  const _StatsDetailRow({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final type = _StatsDisplayType.fromItem(item);
    final metrics = _metricsForItem(item);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RowIcon(type: type),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.listViewTitle(),
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    height: 1.32,
                  ),
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: metrics
                      .map(
                        (metric) => _MetricChip(metric: metric),
                  )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_MetricData> _metricsForItem(ModelToString item) {
    if (item is BeerDetailedModel) {
      return [
        _MetricData(
          icon: Icons.sports_bar_rounded,
          text: '${item.beerNumber} ${_beerLabel(item.beerNumber)}',
          isZero: item.beerNumber == 0,
        ),
        _MetricData(
          icon: Icons.local_bar_rounded,
          text: '${item.liquorNumber} ${_liquorLabel(item.liquorNumber)}',
          isZero: item.liquorNumber == 0,
        ),
      ];
    }

    if (item is GoalDetailedModel) {
      return [
        _MetricData(
          icon: Icons.sports_soccer_rounded,
          text: '${item.goalNumber} ${_goalLabel(item.goalNumber)}',
          isZero: item.goalNumber == 0,
        ),
        _MetricData(
          icon: Icons.assistant_outlined,
          text: '${item.assistNumber} ${_assistLabel(item.assistNumber)}',
          isZero: item.assistNumber == 0,
        ),
      ];
    }

    if (item is ReceivedFineDetailedModel) {
      return [
        _MetricData(
          icon: Icons.receipt_long_rounded,
          text: '${item.fineNumber} ${_fineLabel(item.fineNumber)}',
          isZero: item.fineNumber == 0,
        ),
        _MetricData(
          icon: Icons.payments_outlined,
          text: '${item.fineAmount} Kč',
          isZero: item.fineAmount == 0,
        ),
      ];
    }

    return [
      _MetricData(
        icon: Icons.info_outline_rounded,
        text: item.toStringForListView(),
      ),
    ];
  }

  String _beerLabel(int count) {
    if (count == 1) return 'pivo';
    if (count >= 2 && count <= 4) return 'piva';
    return 'piv';
  }

  String _liquorLabel(int count) {
    if (count == 1) return 'panák';
    if (count >= 2 && count <= 4) return 'panáky';
    return 'panáků';
  }

  String _goalLabel(int count) {
    if (count == 1) return 'gól';
    if (count >= 2 && count <= 4) return 'góly';
    return 'gólů';
  }

  String _assistLabel(int count) {
    if (count == 1) return 'asistence';
    if (count >= 2 && count <= 4) return 'asistence';
    return 'asistencí';
  }

  String _fineLabel(int count) {
    if (count == 1) return 'pokuta';
    if (count >= 2 && count <= 4) return 'pokuty';
    return 'pokut';
  }
}

class _RowIcon extends StatelessWidget {
  final _StatsDisplayType type;

  const _RowIcon({
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        type.icon,
        color: colors.accent,
        size: 21,
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final _MetricData metric;

  const _MetricChip({
    required this.metric,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final foregroundColor =
    metric.isZero ? colors.textTertiary : colors.textSecondary;

    final backgroundColor = metric.isZero
        ? colors.backgroundSecondary.withAlpha(110)
        : colors.backgroundSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            metric.icon,
            color: foregroundColor,
            size: 14,
          ),
          const SizedBox(width: 5),
          Text(
            metric.text,
            style: TextStyle(
              color: foregroundColor,
              fontSize: 12.5,
              fontWeight: metric.isZero ? FontWeight.w400 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStatsContent extends StatelessWidget {
  const _EmptyStatsContent();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              color: colors.textMuted,
              size: 34,
            ),
            const SizedBox(height: 10),
            Text(
              'Nejsou k dispozici žádná data.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  final Color color;

  const _SheetHandle({
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _MetricData {
  final IconData icon;
  final String text;
  final bool isZero;

  const _MetricData({
    required this.icon,
    required this.text,
    this.isZero = false,
  });
}

enum _StatsDisplayType {
  beer(
    icon: Icons.sports_bar_rounded,
    label: 'PIVA A PANÁKY',
  ),
  goal(
    icon: Icons.sports_soccer_rounded,
    label: 'GÓLY A ASISTENCE',
  ),
  fine(
    icon: Icons.receipt_long_rounded,
    label: 'POKUTY',
  ),
  generic(
    icon: Icons.bar_chart_rounded,
    label: 'STATISTIKY',
  );

  final IconData icon;
  final String label;

  const _StatsDisplayType({
    required this.icon,
    required this.label,
  });

  factory _StatsDisplayType.fromItems(List<ModelToString> items) {
    if (items.isEmpty) {
      return _StatsDisplayType.generic;
    }

    return _StatsDisplayType.fromItem(items.first);
  }

  factory _StatsDisplayType.fromItem(ModelToString item) {
    if (item is BeerDetailedModel) {
      return _StatsDisplayType.beer;
    }

    if (item is GoalDetailedModel) {
      return _StatsDisplayType.goal;
    }

    if (item is ReceivedFineDetailedModel) {
      return _StatsDisplayType.fine;
    }

    return _StatsDisplayType.generic;
  }
}
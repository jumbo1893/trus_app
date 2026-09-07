import 'package:flutter/material.dart';
import '../../../models/api/helper/redirect/redirect_api_model.dart';
import '../../../models/api/home/stats_board_data.dart';
import '../../../theme/app_colors.dart';
import '../widget/home_section_card.dart';

class RotatingStatsWidget extends StatefulWidget {
  final List<StatsBoardData> statsBoards;
  final void Function(RedirectApiModel redirect) onRedirect;
  const RotatingStatsWidget({
    super.key,
    required this.statsBoards,
    required this.onRedirect,
  });
  @override
  State<RotatingStatsWidget> createState() => _RotatingStatsWidgetState();
}

class _RotatingStatsWidgetState extends State<RotatingStatsWidget> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    if (widget.statsBoards.isEmpty) return const SizedBox.shrink();
    final selected = _index.clamp(0, widget.statsBoards.length - 1);
    return HomeSectionCard(
      child: Column(
        children: [
          if (widget.statsBoards.length > 1) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < widget.statsBoards.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(widget.statsBoards[i].title),
                        selected: selected == i,
                        onSelected: (_) => setState(() => _index = i),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          _StatsTableView(
            data: widget.statsBoards[selected],
            onRedirect: widget.onRedirect,
          ),
        ],
      ),
    );
  }
}

class _StatsTableView extends StatelessWidget {
  final StatsBoardData data;
  final void Function(RedirectApiModel redirect) onRedirect;

  const _StatsTableView({required this.data, required this.onRedirect});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final titleStyle = TextStyle(
      color: appColors.textPrimary,
      fontSize: 18,
      fontWeight: FontWeight.w700,
    );

    final headerStyle = TextStyle(
      color: appColors.textPrimary,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );

    final cellStyle = TextStyle(
      color: appColors.textPrimary,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            data.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            style: titleStyle,
          ),
        ),
        const SizedBox(height: 12),
        _TableRow(values: data.headers, isHeader: true, textStyle: headerStyle),
        const SizedBox(height: 6),
        ...List.generate(data.rows.length, (index) {
          final row = data.rows[index];

          return Padding(
            padding: EdgeInsets.only(
              bottom: index == data.rows.length - 1 ? 0 : 6,
            ),
            child: InkWell(
              onTap: () =>
                  row.redirect != null ? onRedirect(row.redirect!) : {},
              child: _TableRow(values: row.columns, textStyle: cellStyle),
            ),
          );
        }),
      ],
    );
  }
}

class _TableRow extends StatelessWidget {
  final List<String> values;
  final bool isHeader;
  final TextStyle textStyle;

  const _TableRow({
    required this.values,
    required this.textStyle,
    this.isHeader = false,
  });

  String _valueAt(int index) {
    if (index >= values.length) return '';
    return values[index];
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final rowColor = isHeader
        ? appColors.shadow.withAlpha(20)
        : appColors.shadow.withAlpha(10);

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isHeader ? 8 : 10,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: rowColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              _valueAt(0),
              style: textStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              _valueAt(1),
              style: textStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              _valueAt(2),
              style: textStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

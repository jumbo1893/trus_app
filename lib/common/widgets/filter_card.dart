import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';

import '../../theme/app_widget_values.dart';

class FilterCard extends StatelessWidget {
  final Widget child;

  const FilterCard({super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        borderRadius: AppWidgetValues.borderRadiusMd,
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 6),
            color: context.appColors.shadow.withAlpha(31),
          ),
        ],
      ),
      child: child,
    );
  }
}
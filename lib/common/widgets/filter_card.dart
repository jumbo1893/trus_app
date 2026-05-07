import 'package:flutter/material.dart';

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
        color: Colors.white,
        borderRadius: AppWidgetValues.borderRadiusMd,
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            offset: Offset(0, 6),
            color: Colors.black12,
          ),
        ],
      ),
      child: child,
    );
  }
}
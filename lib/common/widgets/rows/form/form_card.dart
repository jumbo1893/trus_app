import 'package:flutter/material.dart';

import 'package:trus_app/theme/app_widget_values.dart';

class FormCard extends StatelessWidget {
  final List<Widget> children;

  const FormCard({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: AppWidgetValues.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i != children.length - 1)
                const SizedBox(height: AppWidgetValues.sectionSpacing),
            ],
          ],
        ),
      ),
    );
  }
}

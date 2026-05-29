import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';

class MultiSelectPreview extends StatelessWidget {
  final BuildContext context;
  final List models;
  final VoidCallback onTap;
  const MultiSelectPreview({super.key, required this.context, required this.models, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: context.appColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                models.isEmpty
                    ? "Vyber..."
                    : "${models.length} vybraných",
              ),
            ),
            const Icon(Icons.add, size: 18),
          ],
        ),
      ),
    );
  }
}
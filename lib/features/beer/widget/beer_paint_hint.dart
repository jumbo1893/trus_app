import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';

class BeerPaintHint extends StatelessWidget {
  const BeerPaintHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground.withAlpha(220),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(
              Icons.info_outline,
              size: 18,
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Svisle = piva, vodorovně = panáky',
              style: TextStyle(
                fontSize: 13,
                height: 1.25,
                color: context.appColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
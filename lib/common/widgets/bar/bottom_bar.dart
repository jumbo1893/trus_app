import 'package:flutter/material.dart';
import 'package:trus_app/theme/app_colors.dart';

class BottomBar extends StatelessWidget {
  final VoidCallback onConfirm;
  final bool enabled;
  final String text;

  const BottomBar({
    super.key,
    required this.onConfirm,
    required this.enabled,
    this.text = "Uložit změny"
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: context.appColors.cardBackground,
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              offset: const Offset(0, -4),
              color: context.appColors.shadow.withAlpha(31),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: enabled
                ? () {
              FocusManager.instance.primaryFocus?.unfocus();
              onConfirm();
            }
                : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
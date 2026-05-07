import 'package:flutter/material.dart';

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
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              offset: Offset(0, -4),
              color: Colors.black12,
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
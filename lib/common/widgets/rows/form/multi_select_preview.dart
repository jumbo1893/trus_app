import 'package:flutter/material.dart';

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
          color: Colors.grey.shade100,
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
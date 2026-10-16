import 'package:flutter/material.dart';

class FineCorrectionButton extends StatelessWidget {
  const FineCorrectionButton({
    super.key,
    required this.correcting,
    required this.onTap,
  });

  final bool correcting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: correcting
            ? 'Přepnout na přidávání pokut'
            : 'Přepnout na opravu pokut',
        child: InkWell(
          key: const ValueKey('fine-mode-toggle'),
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            width: 58,
            height: 50,
            decoration: BoxDecoration(
              color: correcting
                  ? const Color(0xFFFFB529)
                  : const Color(0xFFE74778),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(correcting ? Icons.add : Icons.remove, size: 18),
                Text(
                  correcting ? 'Přidávat' : 'Opravit',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

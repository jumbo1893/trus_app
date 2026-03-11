import 'package:flutter/material.dart';

import '../../../colors.dart';

class BirthdayText extends StatelessWidget implements PreferredSizeWidget {
  const BirthdayText({
    super.key,
    required this.padding,
    required this.nextBirthdayText,
  });

  final double padding;
  final String? nextBirthdayText;

  @override
  Size get preferredSize => const Size.fromHeight(kMinInteractiveDimension);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Pokud není text, nerenderuj nic
    if (nextBirthdayText == null || nextBirthdayText!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(3.0),
      width: size.width - padding * 2,
      child: Center(
        child: Row(
          children: [
            const Icon(
              Icons.cake,
              color: orangeColor,
              size: 40,
            ),
            Flexible(
              child: Text(
                nextBirthdayText!,
                textAlign: TextAlign.center,
                key: const ValueKey('birthday_text'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
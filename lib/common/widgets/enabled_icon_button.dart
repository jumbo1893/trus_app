import 'package:flutter/material.dart';

import '../../../colors.dart';

class EnabledIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool enabled;
  final Icon icon;
  final String text;
  final bool hasRightBorder;
  const EnabledIconButton({
    Key? key,
    required this.onPressed,
    required this.enabled,
    required this.icon,
    required this.text,
    this.hasRightBorder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          right: hasRightBorder
              ? const BorderSide(color: Colors.black54)
              : BorderSide.none,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => enabled ? onPressed() : {}, icon: icon, color: enabled ? orangeColor : Colors.black38,),
          Padding(
            padding: const EdgeInsets.only(left: 2, right: 2, bottom: 2),
            child: FittedBox(fit: BoxFit.scaleDown, child: Text(text, style: TextStyle(color: enabled ? blackColor : Colors.black38, fontSize: 10),)),
          )
        ],
      ),
    );
  }
}

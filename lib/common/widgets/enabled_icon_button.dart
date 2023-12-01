import 'package:flutter/material.dart';

import '../../../colors.dart';

class EnabledIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool enabled;
  final Icon icon;
  final String text;
  const EnabledIconButton({
    Key? key,
    required this.onPressed,
    required this.enabled,
    required this.icon,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration:
      const BoxDecoration(border: Border(
          right: BorderSide(color: Colors.black54)),),
      child: Column(
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

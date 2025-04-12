import 'package:flutter/material.dart';
import 'package:trus_app/common/widgets/loader.dart';
import 'package:trus_app/features/mixin/view_controller_mixin.dart';

import '../../colors.dart';

class BirthdayText extends StatefulWidget implements PreferredSizeWidget {
  const BirthdayText({
    super.key,
    required this.viewControllerMixin,
    required this.padding,
    required this.hashKey,
  });

  final ViewControllerMixin viewControllerMixin;
  final double padding;
  final String hashKey;

  @override
  Size get preferredSize => const Size.fromHeight(kMinInteractiveDimension);

  @override
  State<BirthdayText> createState() => _BirthdayTextState();
}

class _BirthdayTextState extends State<BirthdayText> {


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double width = size.width - widget.padding * 2;
    const double insidePadding = 3.0;
    return StreamBuilder<String>(
        stream: widget.viewControllerMixin.viewValue(widget.hashKey),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          String nextBirthday = snapshot.data!;
          return Container(
            padding: const EdgeInsets.all(3.0),
            width: size.width - widget.padding * 2,
            child: Center(
                child: Row(
                  children: [
                    const Icon(
                      Icons.cake,
                      color: orangeColor,
                      size: 40,
                    ),
                    Flexible(
                      child: Text(nextBirthday,
                          textAlign: TextAlign.center,
                          key: const ValueKey('birthday_text')),
                    ),
                  ],
                )),
          );
        });
  }
}

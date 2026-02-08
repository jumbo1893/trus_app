import 'package:flutter/material.dart';
import 'package:trus_app/common/widgets/custom_button.dart';
import 'package:trus_app/features/mixin/boolean_controller_mixin.dart';

import '../loader.dart';

class StreamVisibilityButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final BooleanControllerMixin booleanControllerMixin;
  final String hashKey;

  const StreamVisibilityButton({
    required Key key,
    required this.text,
    required this.onPressed,
    required this.booleanControllerMixin,
    required this.hashKey,
  }) : super(key: key);

  @override
  State<StreamVisibilityButton> createState() => _StreamVisibilityButton();
}

class _StreamVisibilityButton extends State<StreamVisibilityButton> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: widget.booleanControllerMixin.boolean(widget.hashKey),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          bool visible = snapshot.data!;
          if(visible) {
            return CustomButton(
                text: widget.text, onPressed: () => widget.onPressed()
            );
          }
          return Container();
        });
  }
}

import 'package:flutter/material.dart';

/// Keep selection overlays coordinated even in sheets without a Scaffold.
/// On iOS, end editing on a user page drag so native autocorrection marks
/// cannot remain floating at their previous screen coordinates.
class TextInputScrollBoundary extends StatelessWidget {
  final Widget child;
  const TextInputScrollBoundary({super.key, required this.child});

  @override
  Widget build(BuildContext context) => ScrollNotificationObserver(
    child: NotificationListener<ScrollStartNotification>(
      onNotification: (notification) {
        if (Theme.of(context).platform != TargetPlatform.iOS ||
            notification.dragDetails == null) {
          return false;
        }
        // A multiline field may scroll its own text while editing. Do not
        // dismiss it, or interfere with caret/selection drags and IME scrolling.
        if (notification.context
                ?.findAncestorWidgetOfExactType<EditableText>() !=
            null) {
          return false;
        }
        final focus = FocusManager.instance.primaryFocus;
        if (focus?.context?.findAncestorStateOfType<EditableTextState>() !=
            null) {
          focus!.unfocus();
        }
        return false;
      },
      child: child,
    ),
  );
}

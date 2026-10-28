import 'package:flutter/material.dart';

/// Animated reaction menu positioned next to the pressed message.
class ChatReactionPicker extends StatefulWidget {
  final Rect anchor;
  final ValueChanged<String> onSelected;
  final VoidCallback onDismiss;
  final VoidCallback? onReply, onCopy, onAskBot;

  const ChatReactionPicker({
    super.key,
    required this.anchor,
    required this.onSelected,
    required this.onDismiss,
    this.onReply,
    this.onCopy,
    this.onAskBot,
  });

  @override
  State<ChatReactionPicker> createState() => _ChatReactionPickerState();
}

class _ChatReactionPickerState extends State<ChatReactionPicker>
    with SingleTickerProviderStateMixin {
  static const _quick = ['❤️', '😂', '😮', '😢', '😡'];
  static const _all = [
    '❤️',
    '😂',
    '😮',
    '😢',
    '😡',
    '👍',
    '😆',
    '🥳',
    '😍',
    '🔥',
    '👏',
    '🙏',
  ];

  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 190),
    reverseDuration: const Duration(milliseconds: 140),
  )..forward();
  bool _expanded = false;
  bool _closing = false;
  String? _pressedEmoji;

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  Future<void> _close([String? selected]) async {
    if (_closing) return;
    _closing = true;
    if (selected != null) {
      setState(() => _pressedEmoji = selected);
      await Future<void>.delayed(const Duration(milliseconds: 110));
    }
    if (!mounted) return;
    await _animation.reverse();
    if (!mounted) return;
    if (selected != null) widget.onSelected(selected);
    widget.onDismiss();
  }

  Future<void> _action(VoidCallback callback) async {
    await _close();
    callback();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final width = (size.width - 24).clamp(0.0, 350.0);
    final menuHeight = _expanded ? 126.0 : 58.0;
    final hasActions =
        widget.onReply != null ||
        widget.onCopy != null ||
        widget.onAskBot != null;
    const actionHeight = 84.0;
    final actionTop = size.height - padding.bottom - 12 - actionHeight;
    final menuBottom = hasActions
        ? actionTop - 12
        : size.height - padding.bottom - 8;
    final above = widget.anchor.top - menuHeight - 8;
    final below = widget.anchor.bottom + 8;
    final top = above >= padding.top + 8 && above + menuHeight <= menuBottom
        ? above
        : below + menuHeight <= menuBottom
        ? below
        : (menuBottom - menuHeight).clamp(padding.top + 8, menuBottom);
    final left = (widget.anchor.center.dx - width / 2).clamp(
      12.0,
      size.width - width - 12,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            key: const ValueKey('reaction_picker_dismiss'),
            behavior: HitTestBehavior.opaque,
            onTap: _close,
            child: ColoredBox(color: Colors.black.withValues(alpha: .28)),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          left: left,
          top: top,
          width: width,
          child: FadeTransition(
            opacity: _animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: .72, end: 1).animate(
                CurvedAnimation(parent: _animation, curve: Curves.easeOutBack),
              ),
              alignment: Alignment.bottomCenter,
              child: Material(
                key: const ValueKey('chat_reaction_menu'),
                elevation: 12,
                borderRadius: BorderRadius.circular(32),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: _expanded
                        ? Wrap(
                            key: const ValueKey('reaction_picker_expanded'),
                            alignment: WrapAlignment.center,
                            spacing: 2,
                            runSpacing: 2,
                            children: [
                              for (final emoji in _all) _choice(emoji),
                            ],
                          )
                        : Row(
                            key: const ValueKey('reaction_picker_quick'),
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              for (final emoji in _quick) _choice(emoji),
                              IconButton(
                                key: const ValueKey('reaction_picker_more'),
                                tooltip: 'Další reakce',
                                onPressed: () =>
                                    setState(() => _expanded = true),
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (hasActions)
          Positioned(
            left: 12,
            right: 12,
            bottom: padding.bottom + 12,
            child: Material(
              key: const ValueKey('chat_message_actions'),
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.surface,
              child: SizedBox(
                height: actionHeight,
                child: Row(
                  children: [
                    if (widget.onReply != null)
                      Expanded(
                        child: _actionButton(
                          Icons.reply,
                          'Odpovědět',
                          widget.onReply!,
                        ),
                      ),
                    if (widget.onCopy != null)
                      Expanded(
                        child: _actionButton(
                          Icons.copy,
                          'Kopírovat',
                          widget.onCopy!,
                        ),
                      ),
                    if (widget.onAskBot != null)
                      Expanded(
                        child: _actionButton(
                          Icons.smart_toy_outlined,
                          'TrusBot',
                          widget.onAskBot!,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onPressed) =>
      InkWell(
        onTap: () => _action(onPressed),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(height: 4),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      );

  Widget _choice(String emoji) => AnimatedScale(
    scale: _pressedEmoji == emoji ? 1.3 : 1,
    duration: const Duration(milliseconds: 110),
    curve: Curves.easeOutBack,
    child: IconButton(
      key: ValueKey('reaction_choice_$emoji'),
      tooltip: emoji,
      visualDensity: VisualDensity.compact,
      onPressed: () => _close(emoji),
      icon: Text(emoji, style: const TextStyle(fontSize: 25)),
    ),
  );
}

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as image_lib;
import 'package:trus_app/common/widgets/screen/custom_consumer_stateful_widget.dart';
import 'package:trus_app/features/ai/widgets/trusbot_markdown_text.dart';
import 'package:trus_app/services/push/push_permission_prompt.dart';
import 'package:trus_app/features/main/controller/screen_notifier.dart';
import 'package:trus_app/features/notification/push/screen/enabled_notifications_screen.dart';
import 'chat_controller.dart';
import 'chat_repository.dart';
import 'chat_reaction_picker.dart';

class ChatScreen extends CustomConsumerStatefulWidget {
  static const id = 'chat-screen';
  const ChatScreen({super.key}) : super(title: 'Chat', name: id);
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _text = TextEditingController();
  final _messagesScroll = ScrollController();
  bool _sending = false;
  bool _loadingOlder = false;
  final Set<String> _pushUpdating = {};
  int? _selectedMessageId;
  String? _selectedMessageRoom;
  OverlayEntry? _reactionOverlay;

  void _removeReactionOverlay() {
    final entry = _reactionOverlay;
    _reactionOverlay = null;
    entry?.remove();
    entry?.dispose();
  }

  void _toggleMessage(String kind, int id) {
    setState(() {
      if (_selectedMessageRoom == kind && _selectedMessageId == id) {
        _selectedMessageId = null;
        _selectedMessageRoom = null;
      } else {
        _selectedMessageId = id;
        _selectedMessageRoom = kind;
      }
    });
  }

  Future<void> _toggleRoomPush(ChatRoom room) async {
    if (_pushUpdating.contains(room.kind)) return;
    setState(() => _pushUpdating.add(room.kind));
    try {
      if (!room.pushEnabled &&
          !await PushPermissionPrompt.ensureAllowed(context)) {
        return;
      }
      final enabled = await ref
          .read(chatControllerProvider.notifier)
          .setPushEnabled(room.kind, !room.pushEnabled);
      if (mounted && !room.pushEnabled && !enabled) {
        final open = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Zapni celková oznámení'),
            content: const Text(
              'Oznámení chatu vyžadují zapnutá celková oznámení v aplikaci.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Zavřít'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Otevřít nastavení'),
              ),
            ],
          ),
        );
        if (open == true && mounted) {
          await ref
              .read(screenNotifierProvider.notifier)
              .changeByFragmentId(EnabledNotificationsScreen.id);
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nastavení oznámení se nepodařilo změnit: $error'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _pushUpdating.remove(room.kind));
    }
  }

  Widget _pushButton(ChatRoom room) => ChatPushBell(
    room: room,
    updating: _pushUpdating.contains(room.kind),
    onPressed: () => _toggleRoomPush(room),
  );

  void _openReactionPicker(
    String kind,
    ChatMessage message,
    Rect globalAnchor,
  ) {
    _removeReactionOverlay();
    final overlay = Overlay.of(context);
    final box = overlay.context.findRenderObject()! as RenderBox;
    final anchor = Rect.fromPoints(
      box.globalToLocal(globalAnchor.topLeft),
      box.globalToLocal(globalAnchor.bottomRight),
    );
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => ChatReactionPicker(
        anchor: anchor,
        onSelected: (emoji) => _applyReaction(kind, message, emoji),
        onDismiss: () {
          if (_reactionOverlay == entry) _removeReactionOverlay();
        },
      ),
    );
    _reactionOverlay = entry;
    overlay.insert(entry);
  }

  Future<void> _applyReaction(
    String kind,
    ChatMessage message,
    String selected,
  ) async {
    final chat = ref.read(chatControllerProvider);
    final myId = chat.myId;
    final currentMessage =
        chat.detail?.messages
            .where((item) => item.id == message.id)
            .firstOrNull ??
        message;
    final current = currentMessage.reactions
        .where((reaction) => reaction.userId == myId)
        .firstOrNull;
    try {
      await ref
          .read(chatControllerProvider.notifier)
          .react(
            kind,
            message.id,
            current?.emoji == selected ? null : selected,
          );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reakci se nepodařilo uložit: $error')),
        );
      }
    }
  }

  void _showReactions(List<ChatReaction> reactions) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('Reakce')),
            for (final reaction in reactions)
              ListTile(
                leading: Text(
                  reaction.emoji,
                  style: const TextStyle(fontSize: 26),
                ),
                title: Text(reaction.name),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _messagesScroll.addListener(() {
      if (_messagesScroll.hasClients) {
        if (_reactionOverlay != null) _removeReactionOverlay();
        ref
            .read(chatControllerProvider.notifier)
            .setViewingLatest(_messagesScroll.position.pixels <= 48);
      }
    });
  }

  @override
  void dispose() {
    _removeReactionOverlay();
    _text.dispose();
    _messagesScroll.dispose();
    super.dispose();
  }

  Future<void> _send(String kind, {Uint8List? image}) async {
    if (_sending || (_text.text.trim().isEmpty && image == null)) return;
    setState(() => _sending = true);
    try {
      final repo = ref.read(chatRepositoryProvider);
      image == null
          ? await repo.send(kind, _text.text.trim())
          : await repo.sendImage(kind, image, _text.text.trim());
      _text.clear();
      await ref.read(chatControllerProvider.notifier).load(kind);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Zprávu se nepodařilo odeslat: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _pickImage(String kind) async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (file == null) return;
    final decoded = image_lib.decodeImage(await file.readAsBytes());
    if (decoded == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tento formát obrázku není podporován')),
        );
      }
      return;
    }
    await _send(
      kind,
      image: Uint8List.fromList(image_lib.encodeJpg(decoded, quality: 80)),
    );
  }

  void _emoji() {
    const emojis = [
      '😀',
      '😂',
      '😍',
      '🥳',
      '😎',
      '😢',
      '😡',
      '👍',
      '❤️',
      '⚽',
      '🍻',
      '🔥',
      '👏',
      '🙏',
      '😉',
      '😅',
      '👀',
      '🎉',
    ];
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            children: emojis
                .map(
                  (emoji) => IconButton(
                    onPressed: () {
                      _text.text += emoji;
                      _text.selection = TextSelection.collapsed(
                        offset: _text.text.length,
                      );
                      Navigator.pop(context);
                    },
                    icon: Text(emoji, style: const TextStyle(fontSize: 26)),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatControllerProvider);
    final kind = chat.activeRoom;
    if (kind == null || kind.isEmpty) {
      return RefreshIndicator(
        onRefresh: ref.read(chatControllerProvider.notifier).refresh,
        child: ListView(
          children: [
            if (chat.error != null)
              ListTile(
                title: const Text('Chat se nepodařilo načíst'),
                subtitle: Text(chat.error!),
                trailing: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: ref.read(chatControllerProvider.notifier).refresh,
                ),
              ),
            for (final room in chat.rooms)
              ListTile(
                leading: Icon(
                  room.kind == 'players' ? Icons.groups : Icons.forum_outlined,
                ),
                title: Text(room.title),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (room.unread > 0)
                      Badge(
                        label: Text(room.unread >= 9 ? '9+' : '${room.unread}'),
                      ),
                    _pushButton(room),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () =>
                    ref.read(chatControllerProvider.notifier).load(room.kind),
              ),
          ],
        ),
      );
    }
    final detail = chat.detail;
    final currentRoom = chat.rooms
        .where((room) => room.kind == kind)
        .firstOrNull;
    return Column(
      children: [
        ListTile(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: ref.read(chatControllerProvider.notifier).closeRoom,
          ),
          title: Text(
            chat.rooms
                    .where((room) => room.kind == kind)
                    .map((room) => room.title)
                    .firstOrNull ??
                'Chat',
          ),
          trailing: currentRoom == null ? null : _pushButton(currentRoom),
        ),
        Expanded(
          child: detail == null
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _messagesScroll,
                  key: ValueKey('chat-messages-$kind'),
                  reverse: true,
                  itemCount:
                      detail.messages.length +
                      (detail.messages.length >= 50 ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == detail.messages.length) {
                      return TextButton(
                        onPressed: _loadingOlder
                            ? null
                            : () async {
                                setState(() => _loadingOlder = true);
                                try {
                                  await ref
                                      .read(chatControllerProvider.notifier)
                                      .older();
                                } finally {
                                  if (mounted) {
                                    setState(() => _loadingOlder = false);
                                  }
                                }
                              },
                        child: const Text('Načíst starší zprávy'),
                      );
                    }
                    final message = detail.messages[index];
                    final own = message.authorId == chat.myId;
                    final seen = seenOnOwnMessage(detail, index, chat.myId);
                    final selected =
                        _selectedMessageRoom == kind &&
                        _selectedMessageId == message.id;
                    return Column(
                      children: [
                        if (beginsConversationAfterPause(detail, index))
                          ChatDateSeparator(message: message),
                        ChatMessageTile(
                          message: message,
                          room: kind,
                          own: own,
                          selected: selected,
                          seen: seen,
                          onTap: () => _toggleMessage(kind, message.id),
                          onLongPress: (anchor) =>
                              _openReactionPicker(kind, message, anchor),
                          onReactionsTap: () =>
                              _showReactions(message.reactions),
                        ),
                      ],
                    );
                  },
                ),
        ),
        SafeArea(
          top: false,
          child: Row(
            children: [
              IconButton(
                tooltip: 'Smajlíky',
                icon: const Icon(Icons.emoji_emotions_outlined),
                onPressed: _emoji,
              ),
              IconButton(
                tooltip: 'Přidat obrázek',
                icon: const Icon(Icons.image_outlined),
                onPressed: _sending ? null : () => _pickImage(kind),
              ),
              Expanded(
                child: TextField(
                  controller: _text,
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(hintText: 'Napsat zprávu…'),
                ),
              ),
              IconButton(
                tooltip: 'Odeslat',
                icon: const Icon(Icons.send),
                onPressed: _sending ? null : () => _send(kind),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ChatPushBell extends StatelessWidget {
  final ChatRoom room;
  final bool updating;
  final VoidCallback onPressed;

  const ChatPushBell({
    super.key,
    required this.room,
    required this.updating,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => IconButton(
    key: ValueKey('chat-push-${room.kind}'),
    tooltip: room.pushEnabled
        ? 'Ztlumit oznámení chatu ${room.title}'
        : 'Zapnout oznámení chatu ${room.title}',
    onPressed: updating ? null : onPressed,
    icon: Icon(
      room.pushEnabled
          ? Icons.notifications_outlined
          : Icons.notifications_off_outlined,
    ),
  );
}

class ChatMessageTile extends StatelessWidget {
  final ChatMessage message;
  final String room;
  final bool own, selected;
  final List<ChatReceipt> seen;
  final VoidCallback onTap, onReactionsTap;
  final ValueChanged<Rect> onLongPress;
  final Widget Function(String room, int id)? imageBuilder;

  const ChatMessageTile({
    super.key,
    required this.message,
    required this.room,
    required this.own,
    required this.selected,
    required this.seen,
    required this.onTap,
    required this.onLongPress,
    required this.onReactionsTap,
    this.imageBuilder,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (selected)
        Padding(
          key: ValueKey('chat-time-${message.id}'),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Text(
              '${MaterialLocalizations.of(context).formatMediumDate(message.createdAt)} '
              '${TimeOfDay.fromDateTime(message.createdAt).format(context)}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ),
      Align(
        alignment: own ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * .82,
          ),
          child: Column(
            crossAxisAlignment: own
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 7),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (message.bot) ...[
                      Icon(
                        Icons.smart_toy_outlined,
                        key: const ValueKey('chat-bot-icon'),
                        size: 15,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      message.author,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
              if (message.text != null)
                Builder(
                  builder: (bubbleContext) => GestureDetector(
                    key: ValueKey('chat-bubble-${message.id}'),
                    onTap: onTap,
                    onLongPressStart: (_) {
                      final box =
                          bubbleContext.findRenderObject()! as RenderBox;
                      final origin = box.localToGlobal(Offset.zero);
                      onLongPress(origin & box.size);
                    },
                    child: Card(
                      color: own
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: message.bot
                            ? TrusBotMarkdownText(
                                data: message.displayText!,
                                color: Theme.of(context).colorScheme.onSurface,
                                selectable: false,
                              )
                            : Text(message.text!),
                      ),
                    ),
                  ),
                ),
              if (message.image)
                Builder(
                  builder: (imageContext) => GestureDetector(
                    key: ValueKey('chat-image-${message.id}'),
                    onTap: onTap,
                    onLongPressStart: (_) {
                      final box = imageContext.findRenderObject()! as RenderBox;
                      final origin = box.localToGlobal(Offset.zero);
                      onLongPress(origin & box.size);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 3,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:
                            imageBuilder?.call(room, message.id) ??
                            _ChatImage(kind: room, id: message.id),
                      ),
                    ),
                  ),
                ),
              if (message.reactions.isNotEmpty)
                InkWell(
                  key: ValueKey('chat-reactions-${message.id}'),
                  borderRadius: BorderRadius.circular(18),
                  onTap: onReactionsTap,
                  child: Container(
                    margin: const EdgeInsets.only(right: 7, left: 7),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      '${message.reactions.map((reaction) => reaction.emoji).toSet().join()} '
                      '${message.reactions.length}',
                    ),
                  ),
                ),
              if (seen.isNotEmpty) _SeenAvatars(receipts: seen),
            ],
          ),
        ),
      ),
    ],
  );
}

bool beginsConversationAfterPause(ChatDetail detail, int index) {
  if (index < 0 || index >= detail.messages.length) return false;
  if (index == detail.messages.length - 1) return true;
  final current = detail.messages[index].createdAt;
  final previous = detail.messages[index + 1].createdAt;
  return current.difference(previous) >= const Duration(hours: 1);
}

class ChatDateSeparator extends StatelessWidget {
  final ChatMessage message;
  const ChatDateSeparator({super.key, required this.message});

  @override
  Widget build(BuildContext context) => Padding(
    key: ValueKey('chat-date-${message.id}'),
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Center(
      child: Text(
        '${MaterialLocalizations.of(context).formatMediumDate(message.createdAt)} '
        '${TimeOfDay.fromDateTime(message.createdAt).format(context)}',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelMedium,
      ),
    ),
  );
}

List<ChatReceipt> seenOnOwnMessage(ChatDetail detail, int index, int? myId) {
  if (myId == null || detail.messages[index].authorId != myId) return const [];
  final messageId = detail.messages[index].id;
  int? nextOwnMessageId;
  for (var i = index - 1; i >= 0; i--) {
    if (detail.messages[i].authorId == myId) {
      nextOwnMessageId = detail.messages[i].id;
      break;
    }
  }
  return detail.receipts.where((receipt) {
    final lastSeen = receipt.lastMessageId;
    return receipt.userId != myId &&
        lastSeen != null &&
        lastSeen >= messageId &&
        (nextOwnMessageId == null || lastSeen < nextOwnMessageId);
  }).toList();
}

class _SeenAvatars extends StatelessWidget {
  final List<ChatReceipt> receipts;
  const _SeenAvatars({required this.receipts});

  String _initials(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    String first(String word) =>
        String.fromCharCode(word.runes.first).toUpperCase();
    return first(words.first) + (words.length > 1 ? first(words.last) : '');
  }

  @override
  Widget build(BuildContext context) {
    final visible = receipts.take(4).toList();
    final overflow = receipts.length - visible.length;
    return Padding(
      padding: const EdgeInsets.only(right: 7, bottom: 5),
      child: Tooltip(
        message: receipts.map((receipt) => receipt.name).join(', '),
        child: InkWell(
          key: const ValueKey('chat_seen_avatars'),
          borderRadius: BorderRadius.circular(20),
          onTap: () => showModalBottomSheet<void>(
            context: context,
            builder: (context) => SafeArea(
              child: ListView(
                shrinkWrap: true,
                children: [
                  const ListTile(title: Text('Zobrazeno')),
                  for (final receipt in receipts)
                    ListTile(
                      leading: CircleAvatar(
                        child: Text(_initials(receipt.name)),
                      ),
                      title: Text(receipt.name),
                    ),
                ],
              ),
            ),
          ),
          child: SizedBox(
            height: 28,
            width: (visible.length + (overflow > 0 ? 1 : 0)) * 21.0 + 7,
            child: Stack(
              children: [
                for (var i = 0; i < visible.length; i++)
                  Positioned(
                    left: i * 21.0,
                    child: CircleAvatar(
                      radius: 13,
                      child: Text(
                        _initials(visible[i].name),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                if (overflow > 0)
                  Positioned(
                    left: visible.length * 21.0,
                    child: CircleAvatar(
                      radius: 13,
                      child: Text(
                        '+$overflow',
                        style: const TextStyle(fontSize: 9),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatImage extends ConsumerStatefulWidget {
  final String kind;
  final int id;
  const _ChatImage({required this.kind, required this.id});
  @override
  ConsumerState<_ChatImage> createState() => _ChatImageState();
}

class _ChatImageState extends ConsumerState<_ChatImage> {
  late Future<Uint8List> _image;
  @override
  void initState() {
    super.initState();
    _image = ref.read(chatRepositoryProvider).image(widget.kind, widget.id);
  }

  @override
  void didUpdateWidget(covariant _ChatImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.kind != widget.kind || oldWidget.id != widget.id) {
      _image = ref.read(chatRepositoryProvider).image(widget.kind, widget.id);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List>(
    future: _image,
    builder: (context, snapshot) => snapshot.hasData
        ? Image.memory(snapshot.data!, width: 260, fit: BoxFit.contain)
        : snapshot.hasError
        ? const Icon(Icons.broken_image_outlined)
        : const SizedBox(
            width: 120,
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          ),
  );
}

import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/features/auth/repository/auth_repository.dart';
import 'package:trus_app/features/general/notifier/global_variables_notifier.dart';
import 'chat_repository.dart';

final chatControllerProvider = StateNotifierProvider<ChatController, ChatState>(
  (ref) {
    final controller = ChatController(ref);
    ref.listen(
      globalVariablesProvider.select(
        (value) => (value.appTeam?.id, value.player?.id),
      ),
      (previous, next) {
        if (previous?.$1 != next.$1) {
          controller.switchTeam(next.$1);
        } else {
          controller.refresh();
        }
      },
    );
    Future.microtask(
      () =>
          controller.switchTeam(ref.read(globalVariablesProvider).appTeam?.id),
    );
    return controller;
  },
);

class ChatTypingEvent {
  final String activityId;
  final int authorId;
  final String author;
  final bool typing;

  ChatTypingEvent.fromJson(Map<String, dynamic> json)
    : activityId = json['activityId'] as String,
      authorId = (json['authorId'] as num).toInt(),
      author = json['author'] as String,
      typing = json['typing'] as bool;
}

class ChatState {
  final List<ChatRoom> rooms;
  final String? activeRoom;
  final ChatDetail? detail;
  final int? myId;
  final String? error;
  final Map<String, ChatTypingEvent> typing;
  final List<ChatOnlineUser> online;
  const ChatState({
    this.rooms = const [],
    this.activeRoom,
    this.detail,
    this.myId,
    this.error,
    this.typing = const {},
    this.online = const [],
  });
  int get unread => rooms.fold(0, (sum, room) => sum + room.unread);
  ChatState copyWith({
    List<ChatRoom>? rooms,
    String? activeRoom,
    ChatDetail? detail,
    int? myId,
    String? error,
    Map<String, ChatTypingEvent>? typing,
    List<ChatOnlineUser>? online,
    bool clearDetail = false,
  }) => ChatState(
    rooms: rooms ?? this.rooms,
    activeRoom: activeRoom ?? this.activeRoom,
    detail: clearDetail ? null : detail ?? this.detail,
    myId: myId ?? this.myId,
    error: error,
    typing: typing ?? this.typing,
    online: online ?? this.online,
  );
}

class ChatController extends StateNotifier<ChatState> {
  final Ref ref;
  StompClient? _socket;
  StreamSubscription<User?>? _authSubscription;
  String? _socketToken;
  int? _teamId;
  bool _screenVisible = false;
  bool _viewingLatest = true;
  bool _historyWindow = false;
  bool get historyWindow => _historyWindow;
  final Map<String, int> _lastReadRequest = {};
  final Map<String, Timer> _typingExpiry = {};
  final String _presenceSessionId = DateTime.now().microsecondsSinceEpoch
      .toString();
  Timer? _presenceTimer;
  bool _appActive = true;
  final String _localActivityId = DateTime.now().microsecondsSinceEpoch
      .toString();
  String? _localTypingRoom;
  Timer? _typingIdle;
  DateTime? _lastTypingPublished;
  Future<void> _typingRequests = Future<void>.value();
  int _loadRevision = 0;
  ChatController(this.ref) : super(const ChatState()) {
    _authSubscription = FirebaseAuth.instance.idTokenChanges().listen((
      user,
    ) async {
      if (!mounted) return;
      if (user == null) {
        await switchTeam(null);
        return;
      }
      final token = await user.getIdToken();
      if (!mounted ||
          token == null ||
          _socketToken == null ||
          token == _socketToken ||
          _teamId == null) {
        return;
      }
      final team = _teamId;
      _teamId = null;
      await switchTeam(team);
    });
  }

  Future<void> switchTeam(int? teamId) async {
    if (_teamId == teamId) return;
    _stopPresence();
    stopLocalTyping();
    _loadRevision++;
    _socket?.deactivate();
    _socket = null;
    _socketToken = null;
    _teamId = teamId;
    _lastReadRequest.clear();
    for (final timer in _typingExpiry.values) {
      timer.cancel();
    }
    _typingExpiry.clear();
    state = const ChatState();
    if (teamId == null) return;
    if (_appActive) _startPresence();
    await refresh();
    if (!mounted || _teamId != teamId) return;
    try {
      final user = await ref.read(authRepositoryProvider).getCurrentUserData();
      if (!mounted || _teamId != teamId) return;
      state = state.copyWith(myId: user.id);
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null || !mounted || _teamId != teamId) return;
      _socketToken = token;
      _socket = StompClient(
        config: StompConfig(
          url: 'wss://$runningUrl/ws',
          stompConnectHeaders: {'Authorization': 'Bearer $token'},
          onConnect: (_) {
            for (final room in state.rooms) {
              _socket?.subscribe(
                destination: '/topic/chat/$teamId/${room.kind}',
                callback: (frame) {
                  if (frame.body == null || !mounted || _teamId != teamId) {
                    return;
                  }
                  final json = jsonDecode(frame.body!) as Map<String, dynamic>;
                  final message = ChatMessage.fromJson(json);
                  if (state.activeRoom == room.kind && state.detail != null) {
                    final items = state.detail!.messages;
                    if (!items.any((item) => item.id == message.id)) {
                      state = state.copyWith(
                        detail: ChatDetail([
                          message,
                          ...items,
                        ], state.detail!.receipts),
                      );
                    }
                    _markLatestIfVisible();
                  }
                  refresh();
                },
              );
              _socket?.subscribe(
                destination: '/topic/chat/$teamId/${room.kind}/read',
                callback: (frame) {
                  if (!mounted ||
                      state.activeRoom != room.kind ||
                      state.detail == null ||
                      frame.body == null) {
                    return;
                  }
                  final receipt = ChatReceipt.fromJson(
                    jsonDecode(frame.body!) as Map<String, dynamic>,
                  );
                  state = state.copyWith(
                    detail: ChatDetail(state.detail!.messages, [
                      ...state.detail!.receipts.where(
                        (r) => r.userId != receipt.userId,
                      ),
                      receipt,
                    ]),
                  );
                },
              );
              _socket?.subscribe(
                destination: '/topic/chat/$teamId/${room.kind}/typing',
                callback: (frame) {
                  if (frame.body == null || !mounted || _teamId != teamId) {
                    return;
                  }
                  final event = ChatTypingEvent.fromJson(
                    jsonDecode(frame.body!) as Map<String, dynamic>,
                  );
                  _updateTyping(room.kind, event);
                },
              );
              _socket?.subscribe(
                destination: '/topic/chat/$teamId/${room.kind}/reactions',
                callback: (frame) {
                  if (!mounted ||
                      _teamId != teamId ||
                      state.activeRoom != room.kind ||
                      frame.body == null) {
                    return;
                  }
                  _applyReactionUpdate(
                    ChatReactionUpdate.fromJson(
                      jsonDecode(frame.body!) as Map<String, dynamic>,
                    ),
                  );
                },
              );
            }
          },
        ),
      )..activate();
    } catch (e) {
      if (mounted) state = state.copyWith(error: '$e');
    }
  }

  void _updateTyping(String kind, ChatTypingEvent event) {
    final key = '$kind/${event.activityId}';
    _typingExpiry.remove(key)?.cancel();
    final typing = {...state.typing};
    if (event.typing) {
      typing[key] = event;
      _typingExpiry[key] = Timer(
        Duration(seconds: event.authorId == 0 ? 90 : 8),
        () {
          _typingExpiry.remove(key);
          if (!mounted) return;
          state = state.copyWith(typing: {...state.typing}..remove(key));
        },
      );
    } else {
      typing.remove(key);
    }
    state = state.copyWith(typing: typing);
  }

  Future<void> refresh() async {
    final team = _teamId;
    if (team == null) return;
    try {
      final rooms = await ref.read(chatRepositoryProvider).rooms();
      if (!mounted || _teamId != team) return;
      final previousKinds = state.rooms.map((room) => room.kind).toSet();
      final nextKinds = rooms.map((room) => room.kind).toSet();
      state = state.copyWith(rooms: rooms);
      if (_socket != null &&
          (previousKinds.length != nextKinds.length ||
              !previousKinds.containsAll(nextKinds))) {
        _teamId = null;
        await switchTeam(team);
      }
    } catch (e) {
      if (mounted) state = state.copyWith(error: '$e');
    }
  }

  Future<bool> setPushEnabled(String kind, bool enabled) async {
    final team = _teamId;
    final effective = await ref
        .read(chatRepositoryProvider)
        .setPushEnabled(kind, enabled);
    if (mounted && _teamId == team) {
      state = state.copyWith(
        rooms: [
          for (final room in state.rooms)
            if (room.kind == kind)
              ChatRoom.withPushEnabled(room, effective)
            else
              room,
        ],
      );
      await refresh();
    }
    return effective;
  }

  Future<void> load(String kind) async {
    if (_localTypingRoom != kind) stopLocalTyping();
    final team = _teamId;
    final revision = ++_loadRevision;
    _viewingLatest = true;
    _historyWindow = false;
    state = state.copyWith(activeRoom: kind, clearDetail: true);
    try {
      final detail = await ref.read(chatRepositoryProvider).detail(kind);
      if (!mounted || _teamId != team || _loadRevision != revision) return;
      state = state.copyWith(detail: detail);
      _refreshOnline();
      _markLatestIfVisible();
    } catch (e) {
      if (mounted && _teamId == team && _loadRevision == revision) {
        state = state.copyWith(error: '$e');
      }
    }
  }

  void addSentMessage(String kind, ChatMessage message) {
    if (state.activeRoom != kind || state.detail == null) return;
    final detail = state.detail!;
    if (detail.messages.any((item) => item.id == message.id)) return;
    state = state.copyWith(
      detail: ChatDetail([message, ...detail.messages], detail.receipts),
    );
    _markLatestIfVisible();
  }

  Future<bool> jumpTo(String kind, int id) async {
    if (state.activeRoom != kind) return false;
    final revision = ++_loadRevision;
    final team = _teamId;
    try {
      final page = await ref.read(chatRepositoryProvider).around(kind, id);
      if (!mounted ||
          _teamId != team ||
          _loadRevision != revision ||
          state.activeRoom != kind) {
        return false;
      }
      _viewingLatest = false;
      _historyWindow = true;
      state = state.copyWith(detail: page);
      return page.messages.any((message) => message.id == id);
    } catch (error) {
      if (mounted && _teamId == team && state.activeRoom == kind) {
        state = state.copyWith(error: '$error');
      }
      return false;
    }
  }

  Future<void> older() async {
    final kind = state.activeRoom;
    final current = state.detail;
    if (kind == null || current == null || current.messages.isEmpty) return;
    final page = await ref
        .read(chatRepositoryProvider)
        .detail(kind, before: current.messages.last.id);
    if (mounted && state.activeRoom == kind) {
      state = state.copyWith(
        detail: ChatDetail([
          ...current.messages,
          ...page.messages,
        ], current.receipts),
      );
    }
  }

  Future<void> react(String kind, int id, String? emoji) async {
    final team = _teamId;
    final update = await ref
        .read(chatRepositoryProvider)
        .setReaction(kind, id, emoji);
    if (mounted && _teamId == team && state.activeRoom == kind) {
      _applyReactionUpdate(update);
    }
  }

  void _applyReactionUpdate(ChatReactionUpdate update) {
    final detail = state.detail;
    if (detail == null ||
        !detail.messages.any((message) => message.id == update.messageId)) {
      return;
    }
    state = state.copyWith(
      detail: ChatDetail([
        for (final message in detail.messages)
          if (message.id == update.messageId)
            ChatMessage.withReactions(message, update.reactions)
          else
            message,
      ], detail.receipts),
    );
  }

  void setScreenVisible(bool visible) {
    final wasVisible = _screenVisible;
    _screenVisible = visible;
    if (!visible) {
      stopLocalTyping();
      return;
    }
    final kind = state.activeRoom;
    if (!wasVisible && _viewingLatest && kind != null && kind.isNotEmpty) {
      load(kind);
      return;
    }
    _markLatestIfVisible();
  }

  void setViewingLatest(bool visible) {
    _viewingLatest = visible && !_historyWindow;
    if (visible) _markLatestIfVisible();
  }

  void _markLatestIfVisible() {
    if (!_screenVisible || !_viewingLatest || !mounted) return;
    final kind = state.activeRoom;
    final detail = state.detail;
    if (kind == null ||
        kind.isEmpty ||
        detail == null ||
        detail.messages.isEmpty) {
      return;
    }
    final id = detail.messages.first.id;
    if ((_lastReadRequest[kind] ?? 0) >= id) return;
    _lastReadRequest[kind] = id;
    markRead(kind, id);
  }

  Future<void> markRead(String kind, int id) async {
    if (!_screenVisible || !_viewingLatest || state.activeRoom != kind) return;
    try {
      await ref.read(chatRepositoryProvider).markRead(kind, id);
      await refresh();
    } catch (_) {
      if (_lastReadRequest[kind] == id) _lastReadRequest.remove(kind);
    }
  }

  void closeRoom() {
    stopLocalTyping();
    _loadRevision++;
    _historyWindow = false;
    state = state.copyWith(activeRoom: '', clearDetail: true, online: const []);
    refresh();
  }

  void setAppActive(bool active) {
    if (_appActive == active) return;
    _appActive = active;
    if (active) {
      _startPresence();
    } else {
      _stopPresence();
    }
  }

  void _startPresence() {
    if (_teamId == null || !_appActive) return;
    _presenceTimer?.cancel();
    _heartbeatPresence();
    _presenceTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _heartbeatPresence();
    });
  }

  Future<void> _heartbeatPresence() async {
    if (!mounted || !_appActive || _teamId == null) return;
    try {
      await ref
          .read(chatRepositoryProvider)
          .setPresence(_presenceSessionId, true);
      await _refreshOnline();
    } catch (_) {
      // The next heartbeat retries; old presence expires on the server.
    }
  }

  Future<void> _refreshOnline() async {
    final kind = state.activeRoom;
    final team = _teamId;
    if (!_appActive || kind == null || kind.isEmpty || team == null) return;
    try {
      final online = await ref.read(chatRepositoryProvider).online(kind);
      if (mounted && _teamId == team && state.activeRoom == kind) {
        state = state.copyWith(online: online);
      }
    } catch (_) {
      // Keep the last known list until the next poll.
    }
  }

  void _stopPresence() {
    _presenceTimer?.cancel();
    _presenceTimer = null;
    if (_teamId == null) return;
    final repo = ref.read(chatRepositoryProvider);
    repo.setPresence(_presenceSessionId, false).catchError((_) => false);
  }

  void composerTextChanged(String kind, String text) {
    if (!_screenVisible || state.activeRoom != kind || text.trim().isEmpty) {
      stopLocalTyping();
      return;
    }
    if (_localTypingRoom != kind) {
      stopLocalTyping();
      _localTypingRoom = kind;
      _lastTypingPublished = null;
    }
    final now = DateTime.now();
    if (_lastTypingPublished == null ||
        now.difference(_lastTypingPublished!) >= const Duration(seconds: 2)) {
      _lastTypingPublished = now;
      _publishLocalTyping(kind, true);
    }
    _typingIdle?.cancel();
    _typingIdle = Timer(const Duration(seconds: 4), stopLocalTyping);
  }

  void stopLocalTyping() {
    _typingIdle?.cancel();
    _typingIdle = null;
    final kind = _localTypingRoom;
    _localTypingRoom = null;
    _lastTypingPublished = null;
    if (kind != null && mounted) _publishLocalTyping(kind, false);
  }

  void _publishLocalTyping(String kind, bool typing) {
    final repo = ref.read(chatRepositoryProvider);
    _typingRequests = _typingRequests.then((_) async {
      try {
        await repo.setTyping(kind, _localActivityId, typing);
      } catch (_) {
        // Typing is temporary; a failed request must not block later updates.
      }
    });
  }

  @override
  void dispose() {
    _presenceTimer?.cancel();
    _typingIdle?.cancel();
    _socket?.deactivate();
    _authSubscription?.cancel();
    for (final timer in _typingExpiry.values) {
      timer.cancel();
    }
    super.dispose();
  }
}

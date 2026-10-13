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

class ChatState {
  final List<ChatRoom> rooms;
  final String? activeRoom;
  final ChatDetail? detail;
  final int? myId;
  final String? error;
  const ChatState({
    this.rooms = const [],
    this.activeRoom,
    this.detail,
    this.myId,
    this.error,
  });
  int get unread => rooms.fold(0, (sum, room) => sum + room.unread);
  ChatState copyWith({
    List<ChatRoom>? rooms,
    String? activeRoom,
    ChatDetail? detail,
    int? myId,
    String? error,
    bool clearDetail = false,
  }) => ChatState(
    rooms: rooms ?? this.rooms,
    activeRoom: activeRoom ?? this.activeRoom,
    detail: clearDetail ? null : detail ?? this.detail,
    myId: myId ?? this.myId,
    error: error,
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
  final Map<String, int> _lastReadRequest = {};
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
    _socket?.deactivate();
    _socket = null;
    _socketToken = null;
    _teamId = teamId;
    _lastReadRequest.clear();
    state = const ChatState();
    if (teamId == null) return;
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
    final team = _teamId;
    _viewingLatest = true;
    state = state.copyWith(activeRoom: kind, clearDetail: true);
    try {
      final detail = await ref.read(chatRepositoryProvider).detail(kind);
      if (!mounted || _teamId != team || state.activeRoom != kind) return;
      state = state.copyWith(detail: detail);
      _markLatestIfVisible();
    } catch (e) {
      if (mounted) state = state.copyWith(error: '$e');
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
    if (!visible) return;
    final kind = state.activeRoom;
    if (!wasVisible && _viewingLatest && kind != null && kind.isNotEmpty) {
      load(kind);
      return;
    }
    _markLatestIfVisible();
  }

  void setViewingLatest(bool visible) {
    _viewingLatest = visible;
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
    state = state.copyWith(activeRoom: '', clearDetail: true);
    refresh();
  }

  @override
  void dispose() {
    _socket?.deactivate();
    _authSubscription?.cancel();
    super.dispose();
  }
}

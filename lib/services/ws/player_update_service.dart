import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:trus_app/models/api/player/stats/player_stats.dart';

import '../../config.dart';

class PlayerUpdatesService {
  StompClient? _client;

  void connect({
    required int playerId,
    required void Function(PlayerStats stats) onUpdate,
  }) {
    _client = StompClient(
      config: StompConfig(
        url: 'wss://$runningUrl/ws',
        onConnect: (StompFrame frame) {
          _client!.subscribe(
            destination: '/topic/player/stats$playerId',
            callback: (StompFrame frame) {
              if (frame.body != null) {
                try {
                  final jsonMap = jsonDecode(frame.body!);
                  final stats = PlayerStats.fromJson(jsonMap);
                  onUpdate(stats);
                } catch (e) {
                  print("JSON parse error: $e");
                }
              }
            },
          );
        },
        onWebSocketError: (error) {
          print("WebSocket error: $error");
        },
        onStompError: (frame) {
          print("STOMP protocol error: ${frame.body}");
        },
        onDisconnect: (_) {
          print("WS disconnected");
        },
      ),
    );
    _client!.activate();
  }

  void disconnect() {
    _client?.deactivate();
  }
}

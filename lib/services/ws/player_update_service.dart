import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:trus_app/models/api/player/stats/player_stats.dart';

import '../../config.dart';

class PlayerUpdatesService {
  StompClient? _client;

  void connect({
    required int playerId,
    required int appTeamId,
    required void Function(PlayerStats stats) onUpdate,
    void Function()? onConnected,
    void Function()? onDisconnected,
  }) {
    _client = StompClient(
      config: StompConfig(
        url: 'wss://$runningUrl/ws',
        onConnect: (StompFrame frame) {
          _client!.subscribe(
            destination: playerStatsDestination(
              playerId: playerId,
              appTeamId: appTeamId,
            ),
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
          onConnected?.call();
        },
        onWebSocketError: (error) {
          print("WebSocket error: $error");
          onDisconnected?.call();
        },
        onStompError: (frame) {
          print("STOMP protocol error: ${frame.body}");
          onDisconnected?.call();
        },
        onDisconnect: (_) {
          print("WS disconnected");
          onDisconnected?.call();
        },
      ),
    );
    _client!.activate();
  }

  void disconnect() {
    _client?.deactivate();
    _client = null;
  }
}

String playerStatsDestination({
  required int playerId,
  required int appTeamId,
}) => '/topic/team/$appTeamId/player/stats/$playerId';

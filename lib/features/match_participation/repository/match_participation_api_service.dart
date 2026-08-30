import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/features/general/repository/crud_api_service.dart';
import 'package:trus_app/models/api/participation/match_participation_detail.dart';
import 'package:trus_app/models/api/participation/match_participation_status.dart';
import 'package:trus_app/models/api/participation/match_participation_reaction.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

final matchParticipationApiServiceProvider = Provider(
  (ref) => MatchParticipationApiService(ref),
);

class MatchParticipationApiService extends CrudApiService {
  MatchParticipationApiService(super.ref);

  Future<MatchParticipationDetail> getDetail(int footballMatchId) {
    return executeGetRequest(
      Uri.parse('$serverUrl/$matchParticipationApi/$footballMatchId'),
      (json) => MatchParticipationDetail.fromJson(json),
      null,
    );
  }

  Future<MatchParticipationDetail> respond({
    required int footballMatchId,
    required MatchParticipationStatus status,
    int? playerId,
    String? comment,
  }) {
    return executePostRequest(
      Uri.parse('$serverUrl/$matchParticipationApi/respond'),
      (json) => MatchParticipationDetail.fromJson(json),
      jsonEncode({
        'footballMatchId': footballMatchId,
        'playerId': playerId,
        'status': status.toJson(),
        'comment': comment,
      }),
    );
  }

  Future<MatchParticipationDetail> createPlayerAndRespond({
    required int footballMatchId,
    required MatchParticipationStatus status,
    required PlayerApiModel player,
    String? comment,
  }) {
    return executePostRequest(
      Uri.parse('$serverUrl/$matchParticipationApi/respond-with-new-player'),
      (json) => MatchParticipationDetail.fromJson(json),
      jsonEncode({
        'footballMatchId': footballMatchId,
        'status': status.toJson(),
        'comment': comment,
        'player': player.toJson(),
      }),
    );
  }

  Future<MatchParticipationDetail> addComment({
    required int footballMatchId,
    required String text,
    int? parentCommentId,
  }) {
    return executePostRequest(
      Uri.parse('$serverUrl/$matchParticipationApi/comment'),
      (json) => MatchParticipationDetail.fromJson(json),
      jsonEncode({
        'footballMatchId': footballMatchId,
        'text': text,
        'parentCommentId': parentCommentId,
      }),
    );
  }

  Future<MatchParticipationDetail> reactToComment({
    required int commentId,
    required MatchParticipationReaction reaction,
  }) {
    return executePostRequest(
      Uri.parse(
        '$serverUrl/$matchParticipationApi/comment/$commentId/reaction',
      ),
      (json) => MatchParticipationDetail.fromJson(json),
      jsonEncode({'reaction': reaction.toJson()}),
    );
  }

  Future<MatchParticipationDetail> deleteComment(int commentId) {
    return executeDeleteRequest(
      Uri.parse('$serverUrl/$matchParticipationApi/comment/$commentId'),
      (json) => MatchParticipationDetail.fromJson(json),
      null,
    );
  }
}

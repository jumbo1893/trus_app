import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/match_participation/repository/match_participation_api_service.dart';
import 'package:trus_app/models/api/participation/match_participation_detail.dart';
import 'package:trus_app/models/api/participation/match_participation_status.dart';
import 'package:trus_app/models/api/participation/match_participation_reaction.dart';
import 'package:trus_app/models/api/player/player_api_model.dart';

final matchParticipationRepositoryProvider = Provider(
  (ref) => MatchParticipationRepository(
    ref.read(matchParticipationApiServiceProvider),
  ),
);

class MatchParticipationRepository {
  final MatchParticipationApiService api;

  MatchParticipationRepository(this.api);

  Future<MatchParticipationDetail> fetchDetail(int footballMatchId) {
    return api.getDetail(footballMatchId);
  }

  Future<MatchParticipationDetail> respond({
    required int footballMatchId,
    required MatchParticipationStatus status,
    int? playerId,
    String? comment,
    bool? playing,
  }) {
    return api.respond(
      footballMatchId: footballMatchId,
      status: status,
      playerId: playerId,
      playing: playing,
      comment: comment,
    );
  }

  Future<MatchParticipationDetail> createPlayerAndRespond({
    required int footballMatchId,
    required MatchParticipationStatus status,
    required PlayerApiModel player,
    String? comment,
    bool? playing,
  }) {
    return api.createPlayerAndRespond(
      footballMatchId: footballMatchId,
      status: status,
      player: player,
      playing: playing,
      comment: comment,
    );
  }

  Future<MatchParticipationDetail> addComment({
    required int footballMatchId,
    required String text,
    int? parentCommentId,
  }) {
    return api.addComment(
      footballMatchId: footballMatchId,
      text: text,
      parentCommentId: parentCommentId,
    );
  }

  Future<MatchParticipationDetail> reactToComment({
    required int commentId,
    required MatchParticipationReaction reaction,
  }) {
    return api.reactToComment(commentId: commentId, reaction: reaction);
  }

  Future<MatchParticipationDetail> deleteComment(int commentId) {
    return api.deleteComment(commentId);
  }

  Future<MatchParticipationDetail> deleteResponse(int matchId, int playerId) =>
      api.deleteResponse(matchId, playerId);
}

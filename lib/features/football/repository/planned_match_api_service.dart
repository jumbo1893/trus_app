import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:trus_app/common/repository/header/cookies/header_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/features/general/repository/request_executor.dart';
import 'package:trus_app/models/api/match/planned_match.dart';
import 'package:trus_app/models/api/match/planned_match_participation.dart';
import 'package:trus_app/models/api/participation/match_participation_status.dart';

final plannedMatchApiProvider = Provider<PlannedMatchApiService>(
  (ref) => PlannedMatchApiService(ref),
);

class PlannedMatchApiService extends RequestExecutor {
  PlannedMatchApiService(super.ref);

  Future<Uint8List> photo(int id) async {
    final client = getClient();
    try {
      final response = await client.get(
        Uri.parse('$serverUrl/planned-match/$id/photo'),
        headers: await HeaderProvider(ref).getHeaders(),
      );
      if (response.statusCode != 200) {
        throw Exception('Fotku se nepodařilo načíst.');
      }
      return response.bodyBytes;
    } finally {
      client.close();
    }
  }

  Future<void> uploadPhoto(int id, Uint8List bytes) async {
    final client = getClient();
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$serverUrl/planned-match/$id/photo'),
      );
      request.headers.addAll(
        await HeaderProvider(ref).getHeaders()
          ..remove('Content-Type'),
      );
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: 'planned-match.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );
      final response = await client.send(request);
      if (response.statusCode != 200) {
        throw Exception('Fotku se nepodařilo uložit.');
      }
    } finally {
      client.close();
    }
  }

  Future<void> deletePhoto(int id) async {
    final client = getClient();
    try {
      final response = await client.delete(
        Uri.parse('$serverUrl/planned-match/$id/photo'),
        headers: await HeaderProvider(ref).getHeaders(),
      );
      if (response.statusCode != 200) {
        throw Exception('Fotku se nepodařilo smazat.');
      }
    } finally {
      client.close();
    }
  }

  Future<PlannedMatchParticipation> participation(int id) => executeGetRequest(
    Uri.parse('$serverUrl/planned-match/$id/participation'),
    (dynamic json) =>
        PlannedMatchParticipation.fromJson(json as Map<String, dynamic>),
    null,
  );

  Future<PlannedMatchParticipation> respond(
    int id,
    MatchParticipationStatus status, {
    bool? playing,
  }) => executePostRequest(
    Uri.parse('$serverUrl/planned-match/$id/participation'),
    (dynamic json) =>
        PlannedMatchParticipation.fromJson(json as Map<String, dynamic>),
    jsonEncode({'status': status.toJson(), 'playing': playing}),
  );

  Future<List<PlannedMatch>> list() => executeGetRequest(
    Uri.parse('$serverUrl/planned-match'),
    (dynamic json) => (json as List<dynamic>)
        .map((item) => PlannedMatch.fromJson(item as Map<String, dynamic>))
        .toList(),
    null,
  );

  Future<PlannedMatch> get(int id) => executeGetRequest(
    Uri.parse('$serverUrl/planned-match/$id'),
    (dynamic json) => PlannedMatch.fromJson(json as Map<String, dynamic>),
    null,
  );

  Future<PlannedMatch> getByFootballMatch(int footballMatchId) =>
      executeGetRequest(
        Uri.parse('$serverUrl/planned-match/by-football/$footballMatchId'),
        (dynamic json) => PlannedMatch.fromJson(json as Map<String, dynamic>),
        null,
      );

  Future<PlannedMatch> create({
    required DateTime date,
    required String type,
    String? opponent,
    bool? home,
    String? description,
    int? seasonId,
  }) => executePostRequest(
    Uri.parse('$serverUrl/planned-match'),
    (dynamic json) => PlannedMatch.fromJson(json as Map<String, dynamic>),
    jsonEncode({
      'date': date.toUtc().toIso8601String(),
      'type': type,
      'opponent': opponent,
      'home': home,
      'description': description,
      'seasonId': seasonId,
    }),
  );

  Future<PlannedMatch> update(
    PlannedMatch match, {
    required DateTime date,
    required String type,
    String? opponent,
    bool? home,
    String? description,
    int? seasonId,
    required String status,
  }) => executePutRequest(
    Uri.parse('$serverUrl/planned-match/${match.id}'),
    (dynamic json) => PlannedMatch.fromJson(json as Map<String, dynamic>),
    jsonEncode({
      'date': date.toUtc().toIso8601String(),
      'type': type,
      'opponent': opponent,
      'home': home,
      'description': description,
      'seasonId': seasonId,
      'status': status,
    }),
  );

  Future<PlannedMatch> complete(int id) => changeStatus(id, 'COMPLETED');

  Future<List<PlannedMatch>> resettable() => executeGetRequest(
    Uri.parse('$serverUrl/planned-match/resettable'),
    (dynamic json) => (json as List<dynamic>)
        .map((item) => PlannedMatch.fromJson(item as Map<String, dynamic>))
        .toList(),
    null,
  );

  Future<PlannedMatch> reset(int id) => executePostRequest(
    Uri.parse('$serverUrl/planned-match/$id/reset'),
    (dynamic json) => PlannedMatch.fromJson(json as Map<String, dynamic>),
    '{}',
  );

  Future<PlannedMatch> changeStatus(int id, String status) =>
      executePostRequest(
        Uri.parse('$serverUrl/planned-match/$id/status'),
        (dynamic json) => PlannedMatch.fromJson(json as Map<String, dynamic>),
        jsonEncode({'status': status}),
      );
}

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/features/general/repository/request_executor.dart';
import 'package:trus_app/models/api/ai/ai_models.dart';

final aiApiServiceProvider = Provider((ref) => AiApiService(ref));

class AiApiService extends RequestExecutor {
  AiApiService(super.ref);

  Future<AiUsage> getUsage() => executeGetRequest(
    Uri.parse('$serverUrl/$aiApi/usage'),
    (json) => AiUsage.fromJson((json as Map).cast<String, dynamic>()),
    null,
  );

  Future<List<AiQuestion>> getHistory({int limit = 50}) => executeGetRequest(
    Uri.parse('$serverUrl/$aiApi/questions'),
    (json) => (json as List<dynamic>)
        .map(
          (item) => AiQuestion.fromJson((item as Map).cast<String, dynamic>()),
        )
        .toList(),
    {'limit': '$limit'},
  );

  Future<AiQuestion> ask(String question) => executePostRequest(
    Uri.parse('$serverUrl/$aiApi/questions'),
    (json) => AiQuestion.fromJson((json as Map).cast<String, dynamic>()),
    jsonEncode({'question': question}),
  );
}

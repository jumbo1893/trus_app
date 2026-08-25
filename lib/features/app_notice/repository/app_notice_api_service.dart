import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/features/general/repository/crud_api_service.dart';
import 'package:trus_app/models/api/app_notice/app_notice.dart';

final appNoticeApiServiceProvider = Provider<AppNoticeApiService>(
  (ref) => AppNoticeApiService(ref),
);

class AppNoticeApiService extends CrudApiService {
  AppNoticeApiService(super.ref);

  Future<AppNotice?> getCurrent() {
    return executeGetRequest(
      Uri.parse('$serverUrl/$appNoticeApi/current'),
      (json) => CurrentAppNotice.fromJson(json).notice,
      null,
    );
  }

  Future<void> markShown(int noticeId) {
    return executePostRequest(
      Uri.parse('$serverUrl/$appNoticeApi/$noticeId/shown'),
      (_) {},
      jsonEncode(null),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/app_notice/repository/app_notice_api_service.dart';
import 'package:trus_app/models/api/app_notice/app_notice.dart';

final appNoticeRepositoryProvider = Provider<AppNoticeRepository>(
  (ref) => AppNoticeRepository(ref.read(appNoticeApiServiceProvider)),
);

class AppNoticeRepository {
  final AppNoticeApiService api;

  AppNoticeRepository(this.api);

  Future<AppNotice?> fetchCurrent() => api.getCurrent();

  Future<void> markShown(int noticeId) => api.markShown(noticeId);
}

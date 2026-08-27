import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/features/general/repository/request_executor.dart';
import 'package:trus_app/models/api/membership/membership.dart';

final membershipApiServiceProvider = Provider(
  (ref) => MembershipApiService(ref),
);

final membershipProvider = FutureProvider.autoDispose<Membership>(
  (ref) => ref.read(membershipApiServiceProvider).getMembership(),
);

class MembershipApiService extends RequestExecutor {
  MembershipApiService(super.ref);

  Future<Membership> getMembership() => executeGetRequest(
    Uri.parse('$serverUrl/membership'),
    (json) => Membership.fromJson((json as Map).cast<String, dynamic>()),
    null,
  );
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/team_administration/repository/team_administration_repository.dart';
import 'package:trus_app/models/api/auth/team_administration_api_model.dart';

final teamAdministrationProvider =
    FutureProvider.autoDispose<TeamAdministrationApiModel>((ref) {
      return ref
          .watch(teamAdministrationRepositoryProvider)
          .getAdministration();
    });

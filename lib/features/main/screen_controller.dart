import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:trus_app/features/pkfl/repository/pkfl_repository.dart';
import 'package:trus_app/features/season/repository/season_api_service.dart';
import 'package:trus_app/models/api/player_api_model.dart';
import 'package:trus_app/models/api/season_api_model.dart';

import '../../../common/static_text.dart';
import '../../../common/utils/field_validator.dart';
import '../../../models/api/match/match_api_model.dart';
import '../../../models/api/match/match_setup.dart';
import '../../../models/api/pkfl/pkfl_match_api_model.dart';
import '../../../models/pkfl/pkfl_match.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/colors.dart';
import 'package:trus_app/features/auth/screens/login_screen.dart';
import 'package:trus_app/features/fine/match/screens/fine_match_screen.dart';
import 'package:trus_app/features/fine/match/screens/fine_player_screen.dart';
import 'package:trus_app/features/fine/screens/fine_screen.dart';
import 'package:trus_app/features/goal/screen/goal_screen.dart';
import 'package:trus_app/features/match/screens/add_match_screen.dart';
import 'package:trus_app/features/match/screens/edit_match_screen.dart';
import 'package:trus_app/features/match/screens/match_screen.dart';
import 'package:trus_app/features/pkfl/screens/main_pkfl_statistics_screen.dart';
import 'package:trus_app/features/pkfl/screens/pkfl_match_screens.dart';
import 'package:trus_app/features/player/screens/add_player_screen.dart';
import 'package:trus_app/features/player/screens/edit_player_screen.dart';
import 'package:trus_app/features/player/screens/player_screen.dart';
import 'package:trus_app/features/season/screens/edit_season_screen.dart';
import 'package:trus_app/features/season/screens/season_screen.dart';
import 'package:trus_app/models/api/fine_api_model.dart';
import 'package:trus_app/models/api/match/match_api_model.dart';
import 'package:trus_app/models/pkfl/pkfl_match.dart';
import '../../common/utils/utils.dart';
import '../../common/widgets/confirmation_dialog.dart';
import '../../models/api/pkfl/pkfl_match_api_model.dart';
import '../../models/api/player_api_model.dart';
import '../../models/api/season_api_model.dart';
import '../auth/controller/auth_controller.dart';
import '../auth/screens/user_screen.dart';
import '../beer/screens/beer_simple_screen.dart';
import '../fine/match/screens/multiple_fine_players_screen.dart';
import '../fine/screens/add_fine_screen.dart';
import '../fine/screens/edit_fine_screen.dart';
import '../general/error/api_executor.dart';
import '../home/screens/home_screen.dart';
import '../info/screens/info_screen.dart';
import '../notification/screen/notification_screen.dart';
import '../pkfl/screens/pkfl_table_screens.dart';
import '../season/screens/add_season_screen.dart';
import '../statistics/screens/goal/main_goal_statistics_screen.dart';
import '../statistics/screens/main_statistics_screen.dart';
import 'bottom_sheet_navigation_manager.dart';
import 'appbar_title_manager.dart';

final screenControllerProvider = Provider((ref) {
  return ScreenController(

      ref: ref);
});

class ScreenController {
  final ProviderRef ref;
  final screenController = StreamController<Widget>.broadcast();
  PkflMatchApiModel? pkflMatch;
  late int matchId;

  ScreenController({
    required this.ref,
  });



}

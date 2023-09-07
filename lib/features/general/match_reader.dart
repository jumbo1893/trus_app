
import 'package:trus_app/models/api/match/match_api_model.dart';

import '../../models/api/interfaces/model_to_string.dart';

abstract class MatchReader {
  MatchApiModel? getMatch();
}
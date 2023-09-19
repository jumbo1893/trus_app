
import 'package:trus_app/models/api/match/match_api_model.dart';

abstract class MatchReader {
  MatchApiModel? getMatch();
}
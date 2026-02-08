import 'package:trus_app/models/api/interfaces/model_to_string.dart';

abstract class DetailedResponseModel {
  List<ModelToString> modelList();
  String overallStats();
}

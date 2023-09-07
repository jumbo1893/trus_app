
import '../../models/api/interfaces/model_to_string.dart';

abstract class ReadOperations {
  Future<List<ModelToString>> getModels();
}
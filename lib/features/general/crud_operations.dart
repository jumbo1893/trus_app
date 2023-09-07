
import '../../models/api/interfaces/model_to_string.dart';

abstract class CrudOperations {
  Future<ModelToString?> addModel();
  Future<String?> editModel(int id);
  Future<String> deleteModel(int id);
}
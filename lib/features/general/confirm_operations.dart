
import '../../models/api/interfaces/confirm_to_string.dart';

abstract class ConfirmOperations {
  Future<ConfirmToString> addModel(int id);
}
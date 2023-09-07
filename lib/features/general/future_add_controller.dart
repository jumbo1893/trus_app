
import '../../models/api/interfaces/add_to_string.dart';
import 'add_controller.dart';

abstract class FutureAddController extends AddController  {
  Future<List<AddToString>> getModels();
}
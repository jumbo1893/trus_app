
import '../../models/api/interfaces/add_to_string.dart';
import 'add_controller.dart';

abstract class StreamAddController extends AddController  {
  Stream<List<AddToString>> streamModels();
  void initStream();
}
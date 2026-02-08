import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

abstract class IListviewState {
  AsyncValue<List<ModelToString>> getListViewItems();
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../../mixin/model_to_string_list_controller_mixin.dart';
import 'cache_controller.dart';
import 'i_endpoint_id.dart';

abstract class CacheProcessor with ModelToStringListControllerMixin {
  final Ref ref;

  CacheProcessor(this.ref);

  Future<void> setupEndpoint<T extends IEndpointId>(
      Future<T> Function() fetchFunction, String endpointId) async {
    final cache = ref.read(cacheControllerProvider);
    IEndpointId? endpointSetup = cache.getCachedEndpoint(endpointId);
    if (endpointSetup != null) {
      cache.setCachedEndpoint(endpointSetup);
      _refreshEndpointInBackground(fetchFunction);
      return;
    }
    final result = await fetchFunction();
    cache.setCachedEndpoint(result);
  }

  void _refreshEndpointInBackground<T extends IEndpointId>(
    Future<T> Function() fetchFunction,
  ) {
    Future(() async {
      try {
        final updated = await fetchFunction();
        ref.read(cacheControllerProvider).setCachedEndpoint(updated);
        loadInitValues();
      } catch (_) {}
    });
  }

  void loadInitValues() {}

  Future<void> loadModel() async {
    Future.delayed(Duration.zero, () => loadInitValues());
  }

  Future<void> setupList<T extends List<ModelToString>>(
      Future<T> Function() fetchFunction, String listId) async {
    final cache = ref.read(cacheControllerProvider);
    List<ModelToString>? list = cache.getCachedLists(listId);
    if (list != null) {
      cache.setCachedLists(list, listId);
      _refreshListInBackground(fetchFunction, listId);
      return;
    }
    final result = await fetchFunction();
    cache.setCachedLists(result, listId);
  }

  void _refreshListInBackground<T extends List<ModelToString>>(
    Future<T> Function() fetchFunction,
    String listId,
  ) {
    Future(() async {
      try {
        final updated = await fetchFunction();
        ref.read(cacheControllerProvider).setCachedLists(updated, listId);
        loadInitListValues(listId);
      } catch (_) {}
    });
  }

  Future<void> initSetupList<T extends List<ModelToString>>(
  Future<T> Function() fetchFunction, String listId) async {
    await setupList(fetchFunction, listId);
    loadInitListValues(listId);
  }

  void loadInitListValues(String listId) {
    List<ModelToString> modelToStringList = ref.read(cacheControllerProvider).getCachedLists(listId)?? [];
    initModelToStringListFields(modelToStringList, listId);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/cache/i_endpoint_id.dart';
import '../../../models/api/interfaces/model_to_string.dart';

final cacheControllerProvider = Provider((ref) {
  return CacheController(
      ref: ref);
});

class CacheController {
  final Ref ref;

  CacheController({
    required this.ref,
  });

  final Map<String, IEndpointId> _cachedEndpoints = {};
  final Map<String, List<ModelToString>> _cachedListsIds = {};


  void setCachedEndpoint(IEndpointId cachedEndpoint) {
    _cachedEndpoints[cachedEndpoint.getEndpointId()] = cachedEndpoint;
  }

  IEndpointId? getCachedEndpoint(String endpointId) {
    return _cachedEndpoints[endpointId];
  }

  void setCachedLists(List<ModelToString> cachedLists, String listId) {
    _cachedListsIds[listId] = cachedLists;
  }

  List<ModelToString>? getCachedLists(String listId) {
    return _cachedListsIds[listId];
  }
}



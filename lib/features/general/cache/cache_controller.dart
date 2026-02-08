import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/general/cache/i_endpoint_id.dart';
import 'package:trus_app/models/api/interfaces/dropdown_item.dart';

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
  final Map<String, List<DropdownItem>> _cachedDropDownListsIds = {};
  final Map<String, DropdownItem?> _cachedDropDownItem = {};


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

  void setCachedDropdownLists(List<DropdownItem> cachedLists, String listId) {
    _cachedDropDownListsIds[listId] = cachedLists;
  }

  List<DropdownItem>? getCachedDropdownLists(String listId) {
    return _cachedDropDownListsIds[listId];
  }

  void setCachedDropdownItem(DropdownItem? cachedItem, String itemId) {
    _cachedDropDownItem[itemId] = cachedItem;
  }

  DropdownItem? getCachedDropdownItem(String itemId) {
    return _cachedDropDownItem[itemId];
  }
}



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:villas_qatar/Core/network/api_endpoints.dart';
import 'package:villas_qatar/Core/network/api_handler.dart';
import 'package:villas_qatar/modules/propertylist/model/myproperty_model.dart';
import 'package:villas_qatar/modules/propertylist/model/property_filter.dart';

class PropertySearchController extends GetxController {
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  String error = '';
  int page = 1;
  final int limit = 12;
  List<Property> properties = [];
  Meta? meta;
  final PropertyFilter filter = PropertyFilter();
  final TextEditingController searchTextController = TextEditingController();
  bool isDetailsLoading = false;

  Property? selectedProperty;

  String detailsError = '';
  @override
  void onInit() {
    super.onInit();

    fetchProperties();
  }

  // ============================================================
  // FETCH PROPERTIES
  // ============================================================

  /// Incremented by every fresh (non load-more) fetch. A response only
  /// applies if it still belongs to the latest fetch, so changing a filter
  /// while a request is in flight shows the newest results instead of being
  /// ignored or overwritten by a slower, older response.
  int _requestId = 0;

  Future<void> fetchProperties({bool loadMore = false}) async {
    if (loadMore) {
      if (isLoading || isLoadingMore || !hasMore) {
        return;
      }
      isLoadingMore = true;
    } else {
      isLoading = true;
      isLoadingMore = false;
      page = 1;
      hasMore = true;
      error = '';
      properties = [];
      _requestId++;
    }

    final int requestId = _requestId;

    update();

    try {
      final Map<String, String> query = {
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (filter.search.isNotEmpty) {
        query['search'] = filter.search;
      }
      if (filter.createdById.isNotEmpty) {
        query['createdById'] = filter.createdById;
      }
      if (filter.type.isNotEmpty) {
        query['typeId'] = filter.type;
      }
      if (filter.purpose.isNotEmpty) {
        query['purpose'] = filter.purpose;
      }
      // Municipality Filter
      if (filter.locationId != null && filter.locationId!.isNotEmpty) {
        query['municipalityId'] = filter.locationId!;
      }
      if (filter.sortBy.isNotEmpty) {
        query["sortBy"] = filter.sortBy;
      }

      if (filter.sortOrder.isNotEmpty) {
        query["sortOrder"] = filter.sortOrder;
      }

      // Coordinates of a place picked from the search autocomplete
      if (filter.latitude != null) {
        query['latitude'] = filter.latitude!.toString();
      }

      if (filter.longitude != null) {
        query['longitude'] = filter.longitude!.toString();
      }
      if (filter.furnishingId.isNotEmpty) {
        query['furnishingId'] = filter.furnishingId;
      }

      // Amenities / nearby tags — the API takes comma-separated IDs.
      if (filter.amenities.isNotEmpty) {
        query['amenityId'] = filter.amenities.join(',');
      }

      final Set<String> nearbyTagIds = {
        ...filter.nearbyTags,
        if (filter.nearbyTagId.isNotEmpty) filter.nearbyTagId,
      };
      if (nearbyTagIds.isNotEmpty) {
        query['nearbyTagId'] = nearbyTagIds.join(',');
      }
      // Price
      if (filter.minPrice != null) {
        query['minPrice'] = filter.minPrice!.toString();
      }

      if (filter.maxPrice != null) {
        query['maxPrice'] = filter.maxPrice!.toString();
      }

      // Bedrooms
      if (filter.minBedrooms != null) {
        query['minBedrooms'] = filter.minBedrooms!.toString();
      }

      // Bathrooms
      if (filter.minBathrooms != null) {
        query['minBathrooms'] = filter.minBathrooms!.toString();
      }

      // Area
      if (filter.minArea != null) {
        query['minArea'] = filter.minArea!.toString();
      }

      if (filter.maxArea != null) {
        query['maxArea'] = filter.maxArea!.toString();
      }

      final String endpoint =
          '${ApiEndpoints.propertyList}?${Uri(queryParameters: query).query}';

      debugPrint('========== PROPERTY SEARCH ==========');
      debugPrint('ENDPOINT: $endpoint');

      final response = await ApiHandler.get(endpoint);

      final MyPropertyModel model = MyPropertyModel.fromJson(response);

      if (requestId != _requestId) return;

      if (loadMore) {
        properties.addAll(model.data);
      } else {
        properties = model.data;
      }

      meta = model.meta;

      hasMore = page < model.meta.totalPages;

      if (hasMore) {
        page++;
      }
    } catch (e) {
      if (requestId != _requestId) return;

      debugPrint('PROPERTY SEARCH ERROR: $e');

      // A failed "load more" keeps the results already on screen — only a
      // failed fresh search shows the error state.
      if (!loadMore) {
        error = e.toString().replaceFirst('Exception: ', '');
      }
    } finally {
      if (requestId == _requestId) {
        isLoading = false;
        isLoadingMore = false;
        update();
      }
    }
  }
  //======================================================
  // SEARCH PROPERTY
  //======================================================

  Future<void> searchProperty(String value) async {
    filter.search = value.trim();

    _setSearchText(filter.search);

    await fetchProperties();
  }

  //======================================================
  // INITIAL SEARCH
  //======================================================

  Future<void> applyInitialSearch(String? value) async {
    final query = value?.trim() ?? "";

    if (query.isEmpty) return;

    filter.search = query;

    _setSearchText(query);

    update();

    await fetchProperties();
  }

  //======================================================
  // INITIAL PURPOSE
  //======================================================

  Future<void> applyInitialPurpose(String? value) async {
    final selectedPurpose = value?.trim().toUpperCase() ?? "";

    if (selectedPurpose != "SALE" && selectedPurpose != "RENT") {
      return;
    }

    filter.purpose = selectedPurpose;

    update();

    await fetchProperties();
  }

  //======================================================
  // APPLY FILTERS
  //======================================================

  Future<void> applyFilters({
    String? search,
    String? type,
    String? purpose,
    String? locationId,
    double? latitude,
    double? longitude,
    String? furnishingId,
    List<String>? amenities,
    List<String>? nearbyTags,
    double? minPrice,
    double? maxPrice,
    int? minBedrooms,
    int? minBathrooms,
    double? minArea,
    double? maxArea,
    String? createdById,
  }) async {
    if (search != null) {
      filter.search = search.trim();

      _setSearchText(filter.search);

      // Coordinates belong to the place picked for this search text.
      filter.latitude = latitude;
      filter.longitude = longitude;
    }

    if (type != null) {
      filter.type = type;
    }

    if (purpose != null) {
      filter.purpose = purpose;
    }

    if (locationId != null) {
      filter.locationId = locationId;
    }

    if (furnishingId != null) {
      filter.furnishingId = furnishingId;
    }

    if (amenities != null) {
      filter.amenities = List.from(amenities);
    }

    if (nearbyTags != null) {
      filter.nearbyTags = List.from(nearbyTags);
    }

    if (createdById != null) {
      filter.createdById = createdById;
    }

    if (minPrice != null) filter.minPrice = minPrice;
    if (maxPrice != null) filter.maxPrice = maxPrice;

    if (minBedrooms != null) filter.minBedrooms = minBedrooms;
    if (minBathrooms != null) filter.minBathrooms = minBathrooms;

    if (minArea != null) filter.minArea = minArea;
    if (maxArea != null) filter.maxArea = maxArea;

    page = 1;
    hasMore = true;

    await fetchProperties();
  }

  //======================================================
  // APPLY FILTER SHEET
  //======================================================

  /// Commits the advanced filters edited in the Filters sheet in one fetch.
  /// Search text, buy/rent, property type and sorting are left untouched.
  Future<void> applyDraft(PropertyFilter draft) async {
    filter
      ..locationId = draft.locationId
      ..furnishingId = draft.furnishingId
      ..amenities = List.from(draft.amenities)
      ..nearbyTags = List.from(draft.nearbyTags)
      ..minPrice = draft.minPrice
      ..maxPrice = draft.maxPrice
      ..minBedrooms = draft.minBedrooms
      ..minBathrooms = draft.minBathrooms
      ..minArea = draft.minArea
      ..maxArea = draft.maxArea;

    await fetchProperties();
  }

  //======================================================
  // SORT
  //======================================================

  Future<void> setSort(String sortBy, String sortOrder) async {
    filter.sortBy = sortBy;
    filter.sortOrder = sortOrder;

    await fetchProperties();
  }

  //======================================================
  // RESET SEARCH
  //======================================================

  Future<void> resetSearch() async {
    filter.clear();

    searchTextController.clear();

    page = 1;
    hasMore = true;

    update();

    await fetchProperties();
  }

  //======================================================
  // CLEAR FILTERS
  //======================================================

  Future<void> clearFilters() async {
    filter.clear();

    searchTextController.clear();

    page = 1;
    hasMore = true;

    update();

    await fetchProperties();
  }

  //======================================================
  // REFRESH
  //======================================================

  Future<void> refreshProperties() async {
    page = 1;

    hasMore = true;

    await fetchProperties();
  }

  //======================================================
  // RESET UI ONLY
  //======================================================

  void resetFilterUi() {
    filter.clear();

    searchTextController.clear();

    update();
  }

  void _setSearchText(String value) {
    searchTextController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  Future<void> fetchPropertyDetails(String propertyId) async {
    if (propertyId.trim().isEmpty) return;

    if (isDetailsLoading) return;

    try {
      isDetailsLoading = true;

      detailsError = '';

      selectedProperty = null;

      update();

      final response = await ApiHandler.get(
        '${ApiEndpoints.propertyList}/$propertyId',
      );

      selectedProperty = Property.fromJson(response);
    } catch (e) {
      detailsError = e.toString().replaceFirst('Exception: ', '');

      debugPrint('PROPERTY DETAILS ERROR: $detailsError');
    } finally {
      isDetailsLoading = false;

      update();
    }
  }

  // ============================================================
  Future<void> clearSearch() async {
    filter.search = '';
    filter.latitude = null;
    filter.longitude = null;

    searchTextController.clear();

    // Remove any selection/cursor position
    searchTextController.selection = const TextSelection.collapsed(offset: 0);

    update();

    await fetchProperties();
  }

  // ============================================================
  // CLOSE
  // ============================================================
  void clearPropertyDetails() {
    selectedProperty = null;
    detailsError = '';
    update();
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }
}

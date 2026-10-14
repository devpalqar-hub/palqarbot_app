class PropertyFilter {
  /// The Search screen opens on Buy; tapping the active tab clears it.
  static const String defaultPurpose = 'SALE';

  String search = '';

  String type = '';
  String purpose = defaultPurpose;

  String? locationId;

  /// Coordinates of a place picked from the search autocomplete — used
  /// instead of [locationId] when the match wasn't a listed municipality.
  double? latitude;
  double? longitude;

  String furnishingId = '';

  // Single nearby tag (for API if needed)
  String nearbyTagId = '';

  // Multiple selections
  List<String> amenities = [];
  List<String> nearbyTags = [];

  double? minPrice;
  double? maxPrice;

  int? minBedrooms;
  int? minBathrooms;

  double? minArea;
  double? maxArea;
  String sortBy = "";
  String sortOrder = "";
  String createdById = '';

  void clear() {
    search = '';

    type = '';
    purpose = defaultPurpose;

    locationId = null;

    latitude = null;
    longitude = null;

    furnishingId = '';

    nearbyTagId = '';

    amenities.clear();
    nearbyTags.clear();

    minPrice = null;
    maxPrice = null;

    minBedrooms = null;
    minBathrooms = null;

    minArea = null;
    maxArea = null;
    sortBy = "";
    sortOrder = "";
    createdById = '';
  }

  /// Resets only the filters edited in the Filters sheet, leaving the search
  /// text, buy/rent, property type and sorting alone.
  void clearAdvanced() {
    locationId = null;

    furnishingId = '';

    nearbyTagId = '';

    amenities.clear();
    nearbyTags.clear();

    minPrice = null;
    maxPrice = null;

    minBedrooms = null;
    minBathrooms = null;

    minArea = null;
    maxArea = null;
  }

  /// True when anything narrows the results — search text, buy/rent,
  /// property type, sorting or any advanced filter.
  bool get hasCriteria =>
      search.isNotEmpty ||
      type.isNotEmpty ||
      // Buy is the untouched default, so only a change counts as criteria.
      purpose != defaultPurpose ||
      sortBy.isNotEmpty ||
      activeFilterCount > 0;

  /// Number of "advanced" filters currently applied (location, furnishing,
  /// amenities, nearby tags, price/area range, bedrooms, bathrooms).
  /// Used to show a count badge on the Filters button.
  int get activeFilterCount {
    int count = 0;

    if (locationId != null && locationId!.isNotEmpty) count++;
    if (furnishingId.isNotEmpty) count++;
    if (amenities.isNotEmpty) count++;
    if (nearbyTags.isNotEmpty) count++;
    if (minPrice != null || maxPrice != null) count++;
    if (minBedrooms != null) count++;
    if (minBathrooms != null) count++;
    if (minArea != null || maxArea != null) count++;

    return count;
  }

  PropertyFilter copy() {
    return PropertyFilter()
      ..search = search
      ..type = type
      ..purpose = purpose
      ..locationId = locationId
      ..latitude = latitude
      ..longitude = longitude
      ..furnishingId = furnishingId
      ..nearbyTagId = nearbyTagId
      ..amenities = List<String>.from(amenities)
      ..nearbyTags = List<String>.from(nearbyTags)
      ..minPrice = minPrice
      ..maxPrice = maxPrice
      ..minBedrooms = minBedrooms
      ..minBathrooms = minBathrooms
      ..minArea = minArea
      ..maxArea = maxArea
      ..createdById = createdById
      ..sortBy = sortBy
      ..sortOrder = sortOrder;
  }
}

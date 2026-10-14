/// Models for the `GET /api/listings/options` response.
///
/// Response shape:
/// {
///   "amenities": [...],
///   "nearbyTags": [...],
///   "furnishingOptions": [...],
///   "listingTypes": [...],
///   "municipalities": [...]
/// }

class ListingOptions {
  final List<OptionItem> amenities;
  final List<OptionItem> nearbyTags;
  final List<OptionItem> furnishingOptions;
  final List<OptionItem> listingTypes;
  final List<Municipality> municipalities;

  ListingOptions({
    required this.amenities,
    required this.nearbyTags,
    required this.furnishingOptions,
    required this.listingTypes,
    required this.municipalities,
  });

  factory ListingOptions.fromJson(Map<String, dynamic> json) {
    return ListingOptions(
      amenities: (json['amenities'] as List<dynamic>? ?? [])
          .map((e) => OptionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      nearbyTags: (json['nearbyTags'] as List<dynamic>? ?? [])
          .map((e) => OptionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      furnishingOptions: (json['furnishingOptions'] as List<dynamic>? ?? [])
          .map((e) => OptionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      listingTypes: (json['listingTypes'] as List<dynamic>? ?? [])
          .map((e) => OptionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      municipalities: (json['municipalities'] as List<dynamic>? ?? [])
          .map((e) => Municipality.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory ListingOptions.empty() => ListingOptions(
    amenities: [],
    nearbyTags: [],
    furnishingOptions: [],
    listingTypes: [],
    municipalities: [],
  );
}

/// Shared shape for amenities / nearbyTags / furnishingOptions / listingTypes.
class OptionItem {
  final String id;
  final String title;
  final String? image;
  final String? propertyCount;

  /// Live count of ACTIVE listings in this category, as returned by
  /// `GET /api/listings/options` — the website renders it as "N+ Properties"
  /// under each category card.
  final int listingCount;

  OptionItem({
    required this.id,
    required this.title,
    this.image,
    this.propertyCount,
    this.listingCount = 0,
  });

  factory OptionItem.fromJson(Map<String, dynamic> json) {
    return OptionItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      image: json['image']?.toString(),
      propertyCount: json["propertyCount"] ?? "1",
      listingCount: (json['listingCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class Municipality {
  final String id;
  final String name;
  final String? image;
  final double? latitude;
  final double? longitude;
  final bool isPopular;

  /// Number of ACTIVE listings in this municipality.
  final int listingCount;

  /// Lowest ACTIVE listing price here — drives the "From QAR x" line on the
  /// website's Popular Places cards.
  final double? cheapestListingPrice;

  Municipality({
    required this.id,
    required this.name,
    this.image,
    this.latitude,
    this.longitude,
    this.isPopular = false,
    this.listingCount = 0,
    this.cheapestListingPrice,
  });

  factory Municipality.fromJson(Map<String, dynamic> json) {
    return Municipality(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isPopular: json['isPopular'] == true,
      listingCount: (json['listingCount'] as num?)?.toInt() ?? 0,
      cheapestListingPrice: (json['cheapestListingPrice'] as num?)?.toDouble(),
    );
  }
}

class ListingOptionsModel {
  final List<ListingOptionItem> amenities;
  final List<ListingOptionItem> nearbyTags;
  final List<FurnishingOption> furnishingOptions;

  const ListingOptionsModel({
    required this.amenities,
    required this.nearbyTags,
    required this.furnishingOptions,
  });

  factory ListingOptionsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ListingOptionsModel(
      amenities: (json['amenities'] as List? ?? [])
          .map(
            (item) => ListingOptionItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),

      nearbyTags: (json['nearbyTags'] as List? ?? [])
          .map(
            (item) => ListingOptionItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),

      furnishingOptions:
          (json['furnishingOptions'] as List? ?? [])
              .map(
                (item) => FurnishingOption.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(),
    );
  }
}


// ============================================================
// AMENITY / NEARBY TAG MODEL
// ============================================================

class ListingOptionItem {
  final String id;
  final String title;
  final String? image;

  const ListingOptionItem({
    required this.id,
    required this.title,
    this.image,
  });

  factory ListingOptionItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return ListingOptionItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      image: json['image']?.toString(),
    );
  }
}


// ============================================================
// FURNISHING OPTION MODEL
// ============================================================

class FurnishingOption {
  final String id;
  final String title;

  const FurnishingOption({
    required this.id,
    required this.title,
  });

  factory FurnishingOption.fromJson(
    Map<String, dynamic> json,
  ) {
    return FurnishingOption(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }
}
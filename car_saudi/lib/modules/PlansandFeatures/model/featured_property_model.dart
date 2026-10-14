import 'package:get/get.dart';
class FeaturedPropertiesResponse {
  final String location;
  final int total;
  final List<FeaturedProperty> data;

  FeaturedPropertiesResponse({
    required this.location,
    required this.total,
    required this.data,
  });

  factory FeaturedPropertiesResponse.fromJson(Map<String, dynamic> json) {
    return FeaturedPropertiesResponse(
      location: json['location']?.toString() ?? '',
      total: _toInt(json['total']),
      data: (json['data'] as List<dynamic>? ?? [])
          .map(
            (item) => FeaturedProperty.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class FeaturedProperty {
  final String subscriptionId;
  final DateTime? endDate;
  final FeaturedListing listing;

  FeaturedProperty({
    required this.subscriptionId,
    required this.endDate,
    required this.listing,
  });

  factory FeaturedProperty.fromJson(Map<String, dynamic> json) {
    return FeaturedProperty(
      subscriptionId: json['subscriptionId']?.toString() ?? '',
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
      listing: FeaturedListing.fromJson(
        json['listing'] is Map<String, dynamic>
            ? json['listing'] as Map<String, dynamic>
            : <String, dynamic>{},
      ),
    );
  }
}

class FeaturedListing {
  final String id;
  final String slug;
  final String propertyName;
  final String description;

  final String purpose;
  final String type;

  final double? latitude;
  final double? longitude;

  final int bedrooms;
  final int bathrooms;

  final double area;

  final int livingRooms;
  final int parkingSpaces;

  final int? floorNumber;
  final int? totalFloors;
  final int? yearBuilt;

  final String furnishingStatus;

  final double price;
  final bool priceNegotiable;

  final String addressLine1;
  final String addressLine2;
  final String areaName;
  final String municipality;
  final String country;

  final String contactPhone;
  final String contactWhatsapp;
  final bool contactVerified;

  final List<String> amenities;
  final List<String> nearbyTags;

  final String otherFeatures;
  final String status;
  final bool isFeatured;

  final List<FeaturedPhoto> photos;

  FeaturedListing({
    required this.id,
    required this.slug,
    required this.propertyName,
    required this.description,
    required this.purpose,
    required this.type,
    this.latitude,
    this.longitude,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.livingRooms,
    required this.parkingSpaces,
    this.floorNumber,
    this.totalFloors,
    this.yearBuilt,
    required this.furnishingStatus,
    required this.price,
    required this.priceNegotiable,
    required this.addressLine1,
    required this.addressLine2,
    required this.areaName,
    required this.municipality,
    required this.country,
    required this.contactPhone,
    required this.contactWhatsapp,
    required this.contactVerified,
    required this.amenities,
    required this.nearbyTags,
    required this.otherFeatures,
    required this.status,
    required this.photos,
    required this.isFeatured,
  });

  factory FeaturedListing.fromJson(Map<String, dynamic> json) {
    return FeaturedListing(
      id: json['id']?.toString() ?? '',

      slug: json['slug']?.toString() ?? '',

      propertyName: json['propertyName']?.toString() ?? 'Property'.tr,

      description: json['description']?.toString() ?? '',

      purpose: json['purpose']?.toString() ?? '',

      type: json['type']?.toString() ?? '',

      latitude: _toNullableDouble(json['latitude']),

      longitude: _toNullableDouble(json['longitude']),

      bedrooms: _toInt(json['bedrooms']),

      bathrooms: _toInt(json['bathrooms']),

      area: _toDouble(json['area']),

      livingRooms: _toInt(json['livingRooms']),

      parkingSpaces: _toInt(json['parkingSpaces']),

      floorNumber: _toNullableInt(json['floorNumber']),

      totalFloors: _toNullableInt(json['totalFloors']),

      yearBuilt: _toNullableInt(json['yearBuilt']),

      furnishingStatus: json['furnishingStatus']?.toString() ?? '',

      price: _toDouble(json['price']),

      priceNegotiable: json['priceNegotiable'] == true,

      addressLine1: json['addressLine1']?.toString() ?? '',

      addressLine2: json['addressLine2']?.toString() ?? '',

      areaName: json['areaName']?.toString() ?? '',

      municipality: json['municipality']?.toString() ?? '',

      country: json['country']?.toString() ?? '',

      contactPhone: json['contactPhone']?.toString() ?? '',

      contactWhatsapp: json['contactWhatsapp']?.toString() ?? '',

      contactVerified: json['contactVerified'] == true,

      amenities: (json['amenities'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),

      nearbyTags: (json['nearbyTags'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),

      otherFeatures: json['otherFeatures']?.toString() ?? '',

      status: json['status']?.toString() ?? '',

      isFeatured: json['isFeatured'] == true,

      photos: (json['photos'] as List<dynamic>? ?? [])
          .map(
            (photo) =>
                FeaturedPhoto.fromJson(photo as Map<String, dynamic>? ?? {}),
          )
          .toList(),
    );
  }

  String get imageUrl {
    if (photos.isEmpty) return '';

    final sortedPhotos = List<FeaturedPhoto>.from(photos)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    for (final photo in sortedPhotos) {
      final url = photo.url.trim();

      if (url.startsWith('http://') || url.startsWith('https://')) {
        return url;
      }
    }

    return '';
  }

  String get formattedPrice {
    if (price == price.roundToDouble()) {
      return '${'QAR'.tr} ${price.toInt()}';
    }

    return '${'QAR'.tr} $price';
  }

  String get formattedLocation {
    final parts = <String>[
      if (addressLine1.trim().isNotEmpty) addressLine1.trim(),
      if (areaName.trim().isNotEmpty) areaName.trim(),
    ];

    return parts.join(', ');
  }
}

class FeaturedPhoto {
  final String id;
  final String url;
  final String caption;
  final int sortOrder;

  FeaturedPhoto({
    required this.id,
    required this.url,
    required this.caption,
    required this.sortOrder,
  });

  factory FeaturedPhoto.fromJson(Map<String, dynamic> json) {
    return FeaturedPhoto(
      id: json['id']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      caption: json['caption']?.toString() ?? '',
      sortOrder: _toInt(json['sortOrder']),
    );
  }
}

// ============================================================
// PARSING HELPERS
// ============================================================

int _toInt(dynamic value) {
  if (value == null) return 0;

  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value.toString()) ?? 0;
}

int? _toNullableInt(dynamic value) {
  if (value == null) return null;

  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value.toString());
}

double _toDouble(dynamic value) {
  if (value == null) return 0;

  if (value is double) {
    return value;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value.toString()) ?? 0;
}

double? _toNullableDouble(dynamic value) {
  if (value == null) return null;

  if (value is double) {
    return value;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value.toString());
}

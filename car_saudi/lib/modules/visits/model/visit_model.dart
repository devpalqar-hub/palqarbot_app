class VisitModel {
  final String id;
  final String listingId;
  final String visitorId;
  final String ownerId;

  final DateTime? scheduledAt;
  final DateTime? proposedAt;

  final String status;
  final String notes;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final VisitListing? listing;

  /// Available in /as-owner
  final VisitUser? visitor;

  /// Available in /as-visitor
  final VisitUser? owner;

  VisitModel({
    required this.id,
    required this.listingId,
    required this.visitorId,
    required this.ownerId,
    this.scheduledAt,
    this.proposedAt,
    required this.status,
    required this.notes,
    this.createdAt,
    this.updatedAt,
    this.listing,
    this.visitor,
    this.owner,
  });

  factory VisitModel.fromJson(Map<String, dynamic> json) {
    return VisitModel(
      id: json['id']?.toString() ?? '',
      listingId: json['listingId']?.toString() ?? '',
      visitorId: json['visitorId']?.toString() ?? '',
      ownerId: json['ownerId']?.toString() ?? '',

      scheduledAt: _parseDate(json['scheduledAt']),
      proposedAt: _parseDate(json['proposedAt']),

      status: json['status']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',

      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),

      listing: json['listing'] is Map<String, dynamic>
          ? VisitListing.fromJson(
              json['listing'] as Map<String, dynamic>,
            )
          : null,

      visitor: json['visitor'] is Map<String, dynamic>
          ? VisitUser.fromJson(
              json['visitor'] as Map<String, dynamic>,
            )
          : null,

      owner: json['owner'] is Map<String, dynamic>
          ? VisitUser.fromJson(
              json['owner'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(
      value.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listingId': listingId,
      'visitorId': visitorId,
      'ownerId': ownerId,
      'scheduledAt': scheduledAt?.toIso8601String(),
      'proposedAt': proposedAt?.toIso8601String(),
      'status': status,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'listing': listing?.toJson(),
      'visitor': visitor?.toJson(),
      'owner': owner?.toJson(),
    };
  }
}

class VisitListing {
  final String id;
  final String? slug;
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

  final List<VisitPhoto> photos;

  VisitListing({
    required this.id,
    this.slug,
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
  });

  factory VisitListing.fromJson(Map<String, dynamic> json) {
    return VisitListing(
      id: json['id']?.toString() ?? '',
      slug: json['slug']?.toString(),

      propertyName:
          json['propertyName']?.toString() ?? '',

      description:
          json['description']?.toString() ?? '',

      purpose:
          json['purpose']?.toString() ?? '',

      type:
          json['type']?.toString() ?? '',

      latitude:
          (json['latitude'] as num?)?.toDouble(),

      longitude:
          (json['longitude'] as num?)?.toDouble(),

      bedrooms:
          (json['bedrooms'] as num?)?.toInt() ?? 0,

      bathrooms:
          (json['bathrooms'] as num?)?.toInt() ?? 0,

      area:
          (json['area'] as num?)?.toDouble() ?? 0,

      livingRooms:
          (json['livingRooms'] as num?)?.toInt() ?? 0,

      parkingSpaces:
          (json['parkingSpaces'] as num?)?.toInt() ?? 0,

      floorNumber:
          (json['floorNumber'] as num?)?.toInt(),

      totalFloors:
          (json['totalFloors'] as num?)?.toInt(),

      yearBuilt:
          (json['yearBuilt'] as num?)?.toInt(),

      furnishingStatus:
          json['furnishingStatus']?.toString() ?? '',

      price:
          (json['price'] as num?)?.toDouble() ?? 0,

      priceNegotiable:
          json['priceNegotiable'] == true,

      addressLine1:
          json['addressLine1']?.toString() ?? '',

      addressLine2:
          json['addressLine2']?.toString() ?? '',

      areaName:
          json['areaName']?.toString() ?? '',

      municipality:
          json['municipality']?.toString() ?? '',

      country:
          json['country']?.toString() ?? '',

      contactPhone:
          json['contactPhone']?.toString() ?? '',

      contactWhatsapp:
          json['contactWhatsapp']?.toString() ?? '',

      contactVerified:
          json['contactVerified'] == true,

      amenities: (json['amenities'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],

      nearbyTags: (json['nearbyTags'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],

      otherFeatures:
          json['otherFeatures']?.toString() ?? '',

      status:
          json['status']?.toString() ?? '',

      photos: (json['photos'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(VisitPhoto.fromJson)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'propertyName': propertyName,
      'description': description,
      'purpose': purpose,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area': area,
      'livingRooms': livingRooms,
      'parkingSpaces': parkingSpaces,
      'floorNumber': floorNumber,
      'totalFloors': totalFloors,
      'yearBuilt': yearBuilt,
      'furnishingStatus': furnishingStatus,
      'price': price,
      'priceNegotiable': priceNegotiable,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'areaName': areaName,
      'municipality': municipality,
      'country': country,
      'contactPhone': contactPhone,
      'contactWhatsapp': contactWhatsapp,
      'contactVerified': contactVerified,
      'amenities': amenities,
      'nearbyTags': nearbyTags,
      'otherFeatures': otherFeatures,
      'status': status,
      'photos': photos.map((e) => e.toJson()).toList(),
    };
  }
}

class VisitPhoto {
  final String id;
  final String url;
  final String? minioKey;
  final String caption;
  final int sortOrder;
  final DateTime? uploadedAt;

  VisitPhoto({
    required this.id,
    required this.url,
    this.minioKey,
    required this.caption,
    required this.sortOrder,
    this.uploadedAt,
  });

  factory VisitPhoto.fromJson(Map<String, dynamic> json) {
    return VisitPhoto(
      id: json['id']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      minioKey: json['minioKey']?.toString(),
      caption: json['caption']?.toString() ?? '',
      sortOrder:
          (json['sortOrder'] as num?)?.toInt() ?? 0,
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.tryParse(
              json['uploadedAt'].toString(),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'minioKey': minioKey,
      'caption': caption,
      'sortOrder': sortOrder,
      'uploadedAt': uploadedAt?.toIso8601String(),
    };
  }
}

class VisitUser {
  final String id;
  final String? name;
  final String? phone;
  final String? email;

  VisitUser({
    required this.id,
    this.name,
    this.phone,
    this.email,
  });

  factory VisitUser.fromJson(Map<String, dynamic> json) {
    return VisitUser(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
    };
  }
}
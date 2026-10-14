class NearbyPropertyResponse {
  final List<NearByListingModel> data;
  final NearbyMeta meta;
  final int totalActiveNearbyListingsCount;

  NearbyPropertyResponse({
    required this.data,
    required this.meta,
    required this.totalActiveNearbyListingsCount,
  });

  factory NearbyPropertyResponse.fromJson(Map<String, dynamic> json) {
    return NearbyPropertyResponse(
      data: (json['data'] as List? ?? [])
          .map((e) => NearByListingModel.fromJson(e))
          .toList(),
      meta: NearbyMeta.fromJson(json['meta'] ?? {}),
      totalActiveNearbyListingsCount:
          json['totalActiveNearbyListingsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        "data": data.map((e) => e.toJson()).toList(),
        "meta": meta.toJson(),
        "totalActiveNearbyListingsCount":
            totalActiveNearbyListingsCount,
      };
}

class NearbyMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  NearbyMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory NearbyMeta.fromJson(Map<String, dynamic> json) {
    return NearbyMeta(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPrevPage: json['hasPrevPage'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        "total": total,
        "page": page,
        "limit": limit,
        "totalPages": totalPages,
        "hasNextPage": hasNextPage,
        "hasPrevPage": hasPrevPage,
      };
}

class NearByListingModel {
  final String id;
  final String referenceCode;
  final String slug;
  final String propertyName;
  final String description;
  final String purpose;

  final String typeId;
  final ListingType? type;

  final double latitude;
  final double longitude;

  final bool isPotentialDuplicate;
  final String? duplicateOfId;

  final int bedrooms;
  final int bathrooms;

  final double area;

  final int livingRooms;
  final int parkingSpaces;

  final int floorNumber;
  final int totalFloors;

  final int yearBuilt;

  final String furnishingId;
  final Furnishing? furnishing;

  final dynamic extraProperties;

  final double price;
  final bool priceNegotiable;

  final String addressLine1;
  final String addressLine2;
  final String areaName;

  final String municipalityId;
  final Municipality? municipality;

  final String country;

  final String contactPhone;
  final String contactWhatsapp;

  final bool contactVerified;

  final List<Amenity> amenities;
  final List<NearbyTag> nearbyTags;

  final String otherFeatures;

  final String status;
  final int submissionCount;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final CreatedBy? createdBy;

  final List<Photo> photos;

  final List<FeaturedSubscription> featuredSubscriptions;

  final bool isWishlisted;
  final bool isFeatured;

  final double distanceMetres;
  final double distanceKm;

  NearByListingModel({
    required this.id,
    required this.referenceCode,
    required this.slug,
    required this.propertyName,
    required this.description,
    required this.purpose,
    required this.typeId,
    this.type,
    required this.latitude,
    required this.longitude,
    required this.isPotentialDuplicate,
    this.duplicateOfId,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.livingRooms,
    required this.parkingSpaces,
    required this.floorNumber,
    required this.totalFloors,
    required this.yearBuilt,
    required this.furnishingId,
    this.furnishing,
    this.extraProperties,
    required this.price,
    required this.priceNegotiable,
    required this.addressLine1,
    required this.addressLine2,
    required this.areaName,
    required this.municipalityId,
    this.municipality,
    required this.country,
    required this.contactPhone,
    required this.contactWhatsapp,
    required this.contactVerified,
    required this.amenities,
    required this.nearbyTags,
    required this.otherFeatures,
    required this.status,
    required this.submissionCount,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    required this.photos,
    required this.featuredSubscriptions,
    required this.isWishlisted,
    required this.isFeatured,
    required this.distanceMetres,
    required this.distanceKm,
  });

  factory NearByListingModel.fromJson(Map<String, dynamic> json) {
    return NearByListingModel(
      id: json['id'] ?? "",
      referenceCode: json['referenceCode'] ?? "",
      slug: json['slug'] ?? "",
      propertyName: json['propertyName'] ?? "",
      description: json['description'] ?? "",
      purpose: json['purpose'] ?? "",
      typeId: json['typeId'] ?? "",
      type: json['type'] != null
          ? ListingType.fromJson(json['type'])
          : null,
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      isPotentialDuplicate:
          json['isPotentialDuplicate'] ?? false,
      duplicateOfId: json['duplicateOfId'],
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      area: (json['area'] ?? 0).toDouble(),
      livingRooms: json['livingRooms'] ?? 0,
      parkingSpaces: json['parkingSpaces'] ?? 0,
      floorNumber: json['floorNumber'] ?? 0,
      totalFloors: json['totalFloors'] ?? 0,
      yearBuilt: json['yearBuilt'] ?? 0,
      furnishingId: json['furnishingId'] ?? "",
      furnishing: json['furnishing'] != null
          ? Furnishing.fromJson(json['furnishing'])
          : null,
      extraProperties: json['extraProperties'],
      price: (json['price'] ?? 0).toDouble(),
      priceNegotiable: json['priceNegotiable'] ?? false,
      addressLine1: json['addressLine1'] ?? "",
      addressLine2: json['addressLine2'] ?? "",
      areaName: json['areaName'] ?? "",
      municipalityId: json['municipalityId'] ?? "",
      municipality: json['municipality'] != null
          ? Municipality.fromJson(json['municipality'])
          : null,
      country: json['country'] ?? "",
      contactPhone: json['contactPhone'] ?? "",
      contactWhatsapp: json['contactWhatsapp'] ?? "",
      contactVerified: json['contactVerified'] ?? false,
      amenities: (json['amenities'] as List? ?? [])
          .map((e) => Amenity.fromJson(e))
          .toList(),
      nearbyTags: (json['nearbyTags'] as List? ?? [])
          .map((e) => NearbyTag.fromJson(e))
          .toList(),
      otherFeatures: json['otherFeatures'] ?? "",
      status: json['status'] ?? "",
      submissionCount: json['submissionCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      createdBy: json['createdBy'] != null
          ? CreatedBy.fromJson(json['createdBy'])
          : null,
      photos: (json['photos'] as List? ?? [])
          .map((e) => Photo.fromJson(e))
          .toList(),
      featuredSubscriptions:
          (json['featuredSubscriptions'] as List? ?? [])
              .map((e) => FeaturedSubscription.fromJson(e))
              .toList(),
      isWishlisted: json['isWishlisted'] ?? false,
      isFeatured: json['isFeatured'] ?? false,
      distanceMetres:
          (json['distanceMetres'] ?? 0).toDouble(),
      distanceKm: (json['distanceKm'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {};
}
class ListingType {
  final String id;
  final String title;

  ListingType({
    required this.id,
    required this.title,
  });

  factory ListingType.fromJson(Map<String, dynamic> json) {
    return ListingType(
      id: json["id"] ?? "",
      title: json["title"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
    };
  }
}

class Furnishing {
  final String id;
  final String title;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Furnishing({
    required this.id,
    required this.title,
    this.createdAt,
    this.updatedAt,
  });

  factory Furnishing.fromJson(Map<String, dynamic> json) {
    return Furnishing(
      id: json["id"] ?? "",
      title: json["title"] ?? "",
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : null,
      updatedAt: json["updatedAt"] != null
          ? DateTime.parse(json["updatedAt"])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
    };
  }
}

class Municipality {
  final String id;
  final String name;
  final String image;
  final double latitude;
  final double longitude;

  Municipality({
    required this.id,
    required this.name,
    required this.image,
    required this.latitude,
    required this.longitude,
  });

  factory Municipality.fromJson(Map<String, dynamic> json) {
    return Municipality(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      image: json["image"] ?? "",
      latitude: (json["latitude"] ?? 0).toDouble(),
      longitude: (json["longitude"] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "image": image,
      "latitude": latitude,
      "longitude": longitude,
    };
  }
}

class CreatedBy {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final dynamic dealerProfile;

  CreatedBy({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.dealerProfile,
  });

  factory CreatedBy.fromJson(Map<String, dynamic> json) {
    return CreatedBy(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      role: json["role"] ?? "",
      dealerProfile: json["dealerProfile"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "phone": phone,
      "role": role,
      "dealerProfile": dealerProfile,
    };
  }
}
class Amenity {
  final String id;
  final String title;
  final String image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Amenity({
    required this.id,
    required this.title,
    required this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory Amenity.fromJson(Map<String, dynamic> json) {
    return Amenity(
      id: json["id"] ?? "",
      title: json["title"] ?? "",
      image: json["image"] ?? "",
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : null,
      updatedAt: json["updatedAt"] != null
          ? DateTime.parse(json["updatedAt"])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "image": image,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

class NearbyTag {
  final String id;
  final String title;
  final String? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NearbyTag({
    required this.id,
    required this.title,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory NearbyTag.fromJson(Map<String, dynamic> json) {
    return NearbyTag(
      id: json["id"] ?? "",
      title: json["title"] ?? "",
      image: json["image"],
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : null,
      updatedAt: json["updatedAt"] != null
          ? DateTime.parse(json["updatedAt"])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "image": image,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

class Photo {
  final String id;
  final String url;
  final String? minioKey;
  final String caption;
  final int sortOrder;
  final DateTime? uploadedAt;

  Photo({
    required this.id,
    required this.url,
    this.minioKey,
    required this.caption,
    required this.sortOrder,
    this.uploadedAt,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json["id"] ?? "",
      url: json["url"] ?? "",
      minioKey: json["minioKey"],
      caption: json["caption"] ?? "",
      sortOrder: json["sortOrder"] ?? 0,
      uploadedAt: json["uploadedAt"] != null
          ? DateTime.parse(json["uploadedAt"])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "url": url,
        "minioKey": minioKey,
        "caption": caption,
        "sortOrder": sortOrder,
        "uploadedAt": uploadedAt?.toIso8601String(),
      };
}

class FeaturedSubscription {
  final String id;

  FeaturedSubscription({
    required this.id,
  });

  factory FeaturedSubscription.fromJson(Map<String, dynamic> json) {
    return FeaturedSubscription(
      id: json["id"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
      };
}
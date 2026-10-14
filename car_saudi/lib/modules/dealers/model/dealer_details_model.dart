class DealerDetailsModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final bool isActive;

  final DateTime createdAt;
  final DateTime updatedAt;

  final DealerProfile dealerProfile;

  final DealerApplication? dealerApplication;

  final List<DealerListing> listings;

  final bool hasActiveSubscription;

  final ActiveSubscription? activeSubscription;

  DealerDetailsModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.dealerProfile,
    this.dealerApplication,
    required this.listings,
    required this.hasActiveSubscription,
    this.activeSubscription,
  });

  factory DealerDetailsModel.fromJson(Map<String, dynamic> json) {
    return DealerDetailsModel(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      isActive: json["isActive"] ?? false,

      createdAt: DateTime.parse(json["createdAt"]),

      updatedAt: DateTime.parse(json["updatedAt"]),

      dealerProfile: DealerProfile.fromJson(json["dealerProfile"] ?? {}),

      dealerApplication: json["dealerApplication"] == null
          ? null
          : DealerApplication.fromJson(json["dealerApplication"]),

      listings: (json["listings"] as List? ?? [])
          .map((e) => DealerListing.fromJson(e))
          .toList(),

      hasActiveSubscription: json["hasActiveSubscription"] ?? false,

      activeSubscription: json["activeSubscription"] == null
          ? null
          : ActiveSubscription.fromJson(json["activeSubscription"]),
    );
  }
}

class DealerProfile {
  final String id;
  final String userId;

  final String dealerName;
  final String contactPhone;

  final String? tagline;

  final String? coverImage;

  final String? tradeNumber;
  final String? reraNumber;

  final String? address;
  final String? city;
  final String? country;

  final String? website;
  final String? description;

  final String? facebook;
  final String? youtube;
  final String? whatsapp;
  final String? instagram;

  final DateTime createdAt;
  final DateTime updatedAt;

  DealerProfile({
    required this.id,
    required this.userId,
    required this.dealerName,
    required this.contactPhone,
    this.tagline,
    required this.coverImage,
    required this.tradeNumber,
    required this.reraNumber,
    required this.address,
    required this.city,
    required this.country,
    required this.website,
    required this.description,
    this.facebook,
    this.youtube,
    this.whatsapp,
    this.instagram,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DealerProfile.fromJson(Map<String, dynamic> json) {
    return DealerProfile(
      id: json["id"] ?? "",
      userId: json["userId"] ?? "",

      dealerName: json["dealerName"] ?? "",
      contactPhone: json["contactPhone"] ?? "",

      tagline: json["tagline"],

      coverImage: json["coverImage"] ?? "",

      tradeNumber: json["tradeNumber"],
      reraNumber: json["reraNumber"],

      address: json["address"],
      city: json["city"],
      country: json["country"],

      website: json["website"],
      description: json["description"],

      facebook: json["facebook"],
      youtube: json["youtube"],
      whatsapp: json["whatsapp"],
      instagram: json["instagram"],

      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : DateTime.now(),

      updatedAt: DateTime.parse(json["updatedAt"]),
    );
  }
}

class DealerListing {
  final String id;
  final String referenceCode;
  final String slug;
  final String? propertyName;
  final String? description;
  final String purpose;

  final String typeId;
  final ListingType type;

  final double price;
  final bool priceNegotiable;

  final int bedrooms;
  final int bathrooms;
  final double area;

  final int livingRooms;
  final int parkingSpaces;

  final String? addressLine1;
  final String? addressLine2;
  final String? areaName;

  final String municipalityId;
  final Municipality municipality;

  final String? contactPhone;
  final String? contactWhatsapp;

  final List<Amenity> amenities;
  final List<NearbyTag> nearbyTags;

  final String status;

  final DateTime createdAt;
  final DateTime updatedAt;

  final List<Photo> photos;

  DealerListing({
    required this.id,
    required this.referenceCode,
    required this.slug,
    required this.propertyName,
    required this.description,
    required this.purpose,
    required this.typeId,
    required this.type,
    required this.price,
    required this.priceNegotiable,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.livingRooms,
    required this.parkingSpaces,
    required this.addressLine1,
    required this.addressLine2,
    required this.areaName,
    required this.municipalityId,
    required this.municipality,
    required this.contactPhone,
    required this.contactWhatsapp,
    required this.amenities,
    required this.nearbyTags,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.photos,
  });

  factory DealerListing.fromJson(Map<String, dynamic> json) {
    return DealerListing(
      id: json["id"] ?? "",
      referenceCode: json["referenceCode"] ?? "",
      slug: json["slug"] ?? "",
      propertyName: json["propertyName"] ?? "",
      description: json["description"] ?? "",
      purpose: json["purpose"] ?? "",

      typeId: json["typeId"] ?? "",
      type: ListingType.fromJson(json["type"] ?? {}),

      price: (json["price"] ?? 0).toDouble(),
      priceNegotiable: json["priceNegotiable"] ?? false,

      bedrooms: json["bedrooms"] ?? 0,
      bathrooms: json["bathrooms"] ?? 0,
      area: (json["area"] ?? 0).toDouble(),

      livingRooms: json["livingRooms"] ?? 0,
      parkingSpaces: json["parkingSpaces"] ?? 0,

      addressLine1: json["addressLine1"] ?? "",
      addressLine2: json["addressLine2"] ?? "",
      areaName: json["areaName"] ?? "",

      municipalityId: json["municipalityId"] ?? "",

      municipality: Municipality.fromJson(json["municipality"] ?? {}),

      contactPhone: json["contactPhone"] ?? "",

      contactWhatsapp: json["contactWhatsapp"] ?? "",

      amenities: (json["amenities"] as List? ?? [])
          .map((e) => Amenity.fromJson(e))
          .toList(),

      nearbyTags: (json["nearbyTags"] as List? ?? [])
          .map((e) => NearbyTag.fromJson(e))
          .toList(),

      status: json["status"] ?? "",

      createdAt: DateTime.parse(json["createdAt"]),

      updatedAt: DateTime.parse(json["updatedAt"]),

      photos: (json["photos"] as List? ?? [])
          .map((e) => Photo.fromJson(e))
          .toList(),
    );
  }

  List<Photo> get sortedPhotos {
    final list = List<Photo>.from(photos);
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }
}

class ListingType {
  final String id;
  final String title;

  ListingType({required this.id, required this.title});

  factory ListingType.fromJson(Map<String, dynamic> json) {
    return ListingType(id: json["id"] ?? "", title: json["title"] ?? "");
  }
}

class Municipality {
  final String id;
  final String?name;
  final String? image;

  Municipality({required this.id, required this.name, required this.image});

  factory Municipality.fromJson(Map<String, dynamic> json) {
    return Municipality(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      image: json["image"] ?? "",
    );
  }
}

class Amenity {
  final String id;
  final String? title;
  final String? image;

  final DateTime createdAt;
  final DateTime updatedAt;

  Amenity({
    required this.id,
    required this.title,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Amenity.fromJson(Map<String, dynamic> json) {
    return Amenity(
      id: json["id"] ?? "",
      title: json["title"] ?? "",
      image: json["image"] ?? "",

      createdAt: DateTime.parse(json["createdAt"]),

      updatedAt: DateTime.parse(json["updatedAt"]),
    );
  }
}

class NearbyTag {
  final String id;
  final String title;
  final String? image;

  final DateTime createdAt;
  final DateTime updatedAt;

  NearbyTag({
    required this.id,
    required this.title,
    this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NearbyTag.fromJson(Map<String, dynamic> json) {
    return NearbyTag(
      id: json["id"] ?? "",
      title: json["title"] ?? "",
      image: json["image"],

      createdAt: DateTime.parse(json["createdAt"]),

      updatedAt: DateTime.parse(json["updatedAt"]),
    );
  }
}

class Photo {
  final String id;
  final String? url;

  final String? minioKey;
  final String? caption;

  final int sortOrder;

  Photo({
    required this.id,
    required this.url,
    this.minioKey,
    required this.caption,
    required this.sortOrder,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json["id"] ?? "",
      url: json["url"] ?? "",
      minioKey: json["minioKey"],
      caption: json["caption"] ?? "",
      sortOrder: json["sortOrder"] ?? 0,
    );
  }
}

class ActiveSubscription {
  final String id;
  final String dealerId;
  final String planId;

  final DateTime startDate;
  final DateTime endDate;

  final String? paymentStatus;

  final String? stripePaymentIntentId;
  final String? stripeSessionId;

  final double? paidAmount;

  final String? assignedByAdminId;

  final DateTime createdAt;
  final DateTime updatedAt;

  final SubscriptionPlan plan;

  ActiveSubscription({
    required this.id,
    required this.dealerId,
    required this.planId,
    required this.startDate,
    required this.endDate,
    required this.paymentStatus,
    this.stripePaymentIntentId,
    this.stripeSessionId,
    required this.paidAmount,
    required this.assignedByAdminId,
    required this.createdAt,
    required this.updatedAt,
    required this.plan,
  });

  factory ActiveSubscription.fromJson(Map<String, dynamic> json) {
    return ActiveSubscription(
      id: json["id"] ?? "",
      dealerId: json["dealerId"] ?? "",
      planId: json["planId"] ?? "",

      startDate: DateTime.parse(json["startDate"]),

      endDate: DateTime.parse(json["endDate"]),

      paymentStatus: json["paymentStatus"] ?? "",

      stripePaymentIntentId: json["stripePaymentIntentId"],

      stripeSessionId: json["stripeSessionId"],

      paidAmount: (json["paidAmount"] ?? 0).toDouble(),

      assignedByAdminId: json["assignedByAdminId"] ?? "",

      createdAt: DateTime.parse(json["createdAt"]),

      updatedAt: DateTime.parse(json["updatedAt"]),

      plan: SubscriptionPlan.fromJson(json["plan"] ?? {}),
    );
  }
}

class SubscriptionPlan {
  final String id;
  final String? name;
  final int? maxListings;
  final int? validityDays;
  final double? price;
  final int? boostDiscountPercent;
  final bool isActive;

  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.maxListings,
    required this.validityDays,
    required this.price,
    required this.boostDiscountPercent,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json["id"] ?? "",

      name: json["name"] ?? "",

      maxListings: json["maxListings"] ?? 0,

      validityDays: json["validityDays"] ?? 0,

      price: (json["price"] ?? 0).toDouble(),

      boostDiscountPercent: json["boostDiscountPercent"] ?? 0,

      isActive: json["isActive"] ?? false,

      createdAt: DateTime.parse(json["createdAt"]),

      updatedAt: DateTime.parse(json["updatedAt"]),
    );
  }
}

class DealerApplication {
  final String? id;
  final String? userId;
  final String? status;
  final String? message;

  DealerApplication({this.id, this.userId, this.status, this.message});

  factory DealerApplication.fromJson(Map<String, dynamic> json) {
    return DealerApplication(
      id: json["id"],
      userId: json["userId"],
      status: json["status"],
      message: json["message"],
    );
  }
}

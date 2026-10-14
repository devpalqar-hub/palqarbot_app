import 'Amenity.dart';
import 'FurnishingModel.dart';
import 'MunicipalityModel.dart';
import 'NearbyTag.dart';

class PropertyModel {
  final String? id;
  final String? referenceCode;
  final String? slug;
  final String? propertyName;
  final String? description;
  final String? purpose;

  final String? typeId;
  final PropertyType? type;

  final double? latitude;
  final double? longitude;

  final bool? isPotentialDuplicate;
  final String? duplicateOfId;

  final int? bedrooms;
  final int? bathrooms;
  final double? area;
  final int? livingRooms;
  final int? parkingSpaces;

  final int? floorNumber;
  final int? totalFloors;
  final int? yearBuilt;

  final String? furnishingId;
  final Furnishing? furnishing;

  final Map<String, dynamic>? extraProperties;

  final double? price;
  final bool? priceNegotiable;

  final String? addressLine1;
  final String? addressLine2;
  final String? areaName;

  final String? municipalityId;
  final Municipality? municipality;

  final String? country;

  final String? contactPhone;
  final String? contactWhatsapp;
  final bool? contactVerified;

  final List<Amenity>? amenities;
  final List<NearbyTag>? nearbyTags;

  final String? otherFeatures;
  final String? status;

  final int? submissionCount;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final List<PropertyPhoto>? photos;

  final bool? isWishlisted;
  final bool? isFeatured;

  PropertyModel({
    this.id,
    this.referenceCode,
    this.slug,
    this.propertyName,
    this.description,
    this.purpose,
    this.typeId,
    this.type,
    this.latitude,
    this.longitude,
    this.isPotentialDuplicate,
    this.duplicateOfId,
    this.bedrooms,
    this.bathrooms,
    this.area,
    this.livingRooms,
    this.parkingSpaces,
    this.floorNumber,
    this.totalFloors,
    this.yearBuilt,
    this.furnishingId,
    this.furnishing,
    this.extraProperties,
    this.price,
    this.priceNegotiable,
    this.addressLine1,
    this.addressLine2,
    this.areaName,
    this.municipalityId,
    this.municipality,
    this.country,
    this.contactPhone,
    this.contactWhatsapp,
    this.contactVerified,
    this.amenities,
    this.nearbyTags,
    this.otherFeatures,
    this.status,
    this.submissionCount,
    this.createdAt,
    this.updatedAt,
    this.photos,
    this.isWishlisted,
    this.isFeatured,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'],
      referenceCode: json['referenceCode'],
      slug: json['slug'],
      propertyName: json['propertyName'],
      description: json['description'],
      purpose: json['purpose'],

      typeId: json['typeId'],
      type: json['type'] != null ? PropertyType.fromJson(json['type']) : null,

      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),

      isPotentialDuplicate: json['isPotentialDuplicate'],
      duplicateOfId: json['duplicateOfId'],

      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      area: (json['area'] as num?)?.toDouble(),
      livingRooms: json['livingRooms'],
      parkingSpaces: json['parkingSpaces'],

      floorNumber: json['floorNumber'],
      totalFloors: json['totalFloors'],
      yearBuilt: json['yearBuilt'],

      furnishingId: json['furnishingId'],
      furnishing: json['furnishing'] != null
          ? Furnishing.fromJson(json['furnishing'])
          : null,

      extraProperties: json['extraProperties'] != null
          ? Map<String, dynamic>.from(json['extraProperties'])
          : null,

      price: (json['price'] as num?)?.toDouble(),
      priceNegotiable: json['priceNegotiable'],

      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      areaName: json['areaName'],

      municipalityId: json['municipalityId'],
      municipality: json['municipality'] != null
          ? Municipality.fromJson(json['municipality'])
          : null,

      country: json['country'],

      contactPhone: json['contactPhone'],
      contactWhatsapp: json['contactWhatsapp'],
      contactVerified: json['contactVerified'],

      amenities: (json['amenities'] as List?)
          ?.map((e) => Amenity.fromJson(e))
          .toList(),

      nearbyTags: (json['nearbyTags'] as List?)
          ?.map((e) => NearbyTag.fromJson(e))
          .toList(),

      otherFeatures: json['otherFeatures'],
      status: json['status'],

      submissionCount: json['submissionCount'],

      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,

      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,

      photos: (json['photos'] as List?)
          ?.map((e) => PropertyPhoto.fromJson(e))
          .toList(),

      isWishlisted: json['isWishlisted'],
      isFeatured: json['isFeatured'],
    );
  }
}

class PropertyType {
  final String? id;
  final String? title;

  PropertyType({this.id, this.title});

  factory PropertyType.fromJson(Map<String, dynamic> json) {
    return PropertyType(id: json['id'], title: json['title']);
  }
}

class PropertyPhoto {
  final String? id;
  final String? url;
  final String? minioKey;
  final String? caption;
  final int? sortOrder;
  final DateTime? uploadedAt;

  PropertyPhoto({
    this.id,
    this.url,
    this.minioKey,
    this.caption,
    this.sortOrder,
    this.uploadedAt,
  });

  factory PropertyPhoto.fromJson(Map<String, dynamic> json) {
    return PropertyPhoto(
      id: json['id'],
      url: json['url'],
      minioKey: json['minioKey'],
      caption: json['caption'],
      sortOrder: json['sortOrder'],
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.tryParse(json['uploadedAt'])
          : null,
    );
  }
}

import 'package:get/get.dart';
class ChatListModel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Listing listing;
  final ChatUser user;
  final List<Participant> participants;
  final LastMessage? lastMessage;

  ChatListModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.listing,
    required this.user,
    required this.participants,
    required this.lastMessage,
  });

  factory ChatListModel.fromJson(Map<String, dynamic> json) {
  print("========== RAW CHAT LIST ==========");
  print("LISTING JSON: ${json["listing"]}");
  print("CONTACT PHONE RAW: ${json["listing"]?["contactPhone"]}");
  print("CREATED BY: ${json["listing"]?["createdBy"]}");
  print("===================================");

  return ChatListModel(
    id: json["id"] ?? "",
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    listing: Listing.fromJson(json["listing"] ?? {}),
    user: ChatUser.fromJson(json["user"]),
    participants: (json["participants"] as List? ?? [])
        .map((e) => Participant.fromJson(e))
        .toList(),
    lastMessage: json["lastMessage"] == null
        ? null
        : LastMessage.fromJson(json["lastMessage"]),
  );
}
  Participant? get otherParticipant {
  try {
    return participants.firstWhere(
      (p) => p.userId != user.id,
    );
  } catch (_) {
    return null;
  }
}

String get otherParticipantName {
  return otherParticipant?.user.name ?? "Seller".tr;
}
}
class Listing {
  final String id;
  final String propertyName;
  final String description;
  final ListingType? type;
  final String purpose;

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
  final int? yearBuilt;

  final String furnishingStatus;

  final Map<String, dynamic> extraProperties;

  final num price;
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
  final int submissionCount;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final ListingCreatedBy? createdBy;

  final List<ListingPhoto> photos;

  Listing({
    required this.id,
    required this.propertyName,
    required this.description,
    this.type,
    required this.purpose,
    required this.latitude,
    required this.longitude,
    required this.isPotentialDuplicate,
    required this.duplicateOfId,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.livingRooms,
    required this.parkingSpaces,
    required this.floorNumber,
    required this.totalFloors,
    required this.yearBuilt,
    required this.furnishingStatus,
    required this.extraProperties,
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
    required this.submissionCount,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.photos,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json["id"] ?? "",
      propertyName: json["propertyName"] ?? "",
      description: json["description"] ?? "",
      type: json["type"] == null
    ? null
    : ListingType.fromJson(json["type"]),
      purpose: json["purpose"] ?? "",

      latitude: (json["latitude"] ?? 0).toDouble(),
      longitude: (json["longitude"] ?? 0).toDouble(),

      isPotentialDuplicate: json["isPotentialDuplicate"] ?? false,
      duplicateOfId: json["duplicateOfId"],

      bedrooms: json["bedrooms"] ?? 0,
      bathrooms: json["bathrooms"] ?? 0,
      area: (json["area"] ?? 0).toDouble(),
      livingRooms: json["livingRooms"] ?? 0,
      parkingSpaces: json["parkingSpaces"] ?? 0,

      floorNumber: json["floorNumber"] ?? 0,
      totalFloors: json["totalFloors"] ?? 0,
      yearBuilt: json["yearBuilt"],

      furnishingStatus: json["furnishingStatus"] ?? "",

      extraProperties: Map<String, dynamic>.from(
        json["extraProperties"] ?? {},
      ),

      price: json["price"] ?? 0,
      priceNegotiable: json["priceNegotiable"] ?? false,

      addressLine1: json["addressLine1"] ?? "",
      addressLine2: json["addressLine2"] ?? "",
      areaName: json["areaName"] ?? "",
      municipality: json["municipality"] ?? "",
      country: json["country"] ?? "",

      contactPhone: json["contactPhone"] ?? "",
      contactWhatsapp: json["contactWhatsapp"] ?? "",
      contactVerified: json["contactVerified"] ?? false,

      amenities: List<String>.from(json["amenities"] ?? []),
      nearbyTags: List<String>.from(json["nearbyTags"] ?? []),

      otherFeatures: json["otherFeatures"] ?? "",
      status: json["status"] ?? "",
      submissionCount: json["submissionCount"] ?? 0,

      createdAt: json["createdAt"] == null
          ? null
          : DateTime.parse(json["createdAt"]),

      updatedAt: json["updatedAt"] == null
          ? null
          : DateTime.parse(json["updatedAt"]),

      createdBy: json["createdBy"] == null
          ? null
          : ListingCreatedBy.fromJson(json["createdBy"]),
        photos: (json["photos"] as List<dynamic>?)
        ?.map((e) => ListingPhoto.fromJson(e))
        .toList() ??
    [],
    );
  }
String get image => photos.isNotEmpty ? photos.first.url : "";
  
  
}


class ListingType {
  final String id;
  final String title;
  final String image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ListingType({
    required this.id,
    required this.title,
    required this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory ListingType.fromJson(Map<String, dynamic> json) {
    return ListingType(
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
}


class ListingPhoto {
  final String url;

  ListingPhoto({
    required this.url,
  });

  factory ListingPhoto.fromJson(Map<String, dynamic> json) {
    return ListingPhoto(
      url: json["url"] ?? "",
    );
  }
}
class ListingCreatedBy {
  final String id;
  final String? name;
  final String? email;
  final String? phone;
  final String role;

  ListingCreatedBy({
    required this.id,
    this.name,
    this.email,
    this.phone,
    required this.role,
  });

  factory ListingCreatedBy.fromJson(Map<String, dynamic> json) {
    return ListingCreatedBy(
      id: json["id"] ?? "",
      name: json["name"],
      email: json["email"],
      phone: json["phone"],
      role: json["role"] ?? "",
    );
  }
}

class ChatUser {
  final String id;
  final String? name;
  final String? email;

  ChatUser({
    required this.id,
    this.name,
    this.email,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json["id"],
      name: json["name"],
      email: json["email"],
    );
  }
}

class Participant {
  final String userId;
  final ParticipantUser user;

  Participant({
    required this.userId,
    required this.user,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      userId: json["userId"],
      user: ParticipantUser.fromJson(json["user"]),
    );
  }
}

class ParticipantUser {
  final String id;
  final String? name;
  final String role;

  ParticipantUser({
    required this.id,
    this.name,
    required this.role,
  });

  factory ParticipantUser.fromJson(Map<String, dynamic> json) {
    return ParticipantUser(
      id: json["id"],
      name: json["name"],
      role: json["role"],
    );
  }
}


class LastMessage {
  final String id;
  final String type;
  final String? content;
  final String? mediaUrl;
  final DateTime createdAt;
  final LastSender sender;

  LastMessage({
    required this.id,
    required this.type,
    this.content,
    this.mediaUrl,
    required this.createdAt,
    required this.sender,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      id: json["id"],
      type: json["type"],
      content: json["content"],
      mediaUrl: json["mediaUrl"],
      createdAt: DateTime.parse(json["createdAt"]),
      sender: LastSender.fromJson(json["sender"]),
    );
  }
}

class LastSender {
  final String id;
  final String? name;

  LastSender({
    required this.id,
    this.name,
  });

  factory LastSender.fromJson(Map<String, dynamic> json) {
    return LastSender(
      id: json["id"],
      name: json["name"],
    );
  }
}
import 'message_model.dart';

class ConversationModel {
  final Conversation conversation;
  final ListingModel listing;
  final List<MessageModel> messages;

  ConversationModel({
    required this.conversation,
    required this.listing,
    required this.messages,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      conversation: Conversation.fromJson(json["conversation"] ?? {}),
      listing: ListingModel.fromJson(json["listing"] ?? {}),
      messages: (json["messages"] as List? ?? [])
          .map((e) => MessageModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "conversation": conversation.toJson(),
      "listing": listing.toJson(),
      "messages": messages.map((e) => e.toJson()).toList(),
    };
  }
}

class Conversation {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> participantIds;

  Conversation({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.participantIds,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json["id"] ?? "",
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
      participantIds: List<String>.from(json["participantIds"] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      "participantIds": participantIds,
    };
  }
}
class ListingModel {
  final String id;
  final String propertyName;
  final ListingType type;
  final String purpose;
  final num price;
  final String areaName;
  final Municipality municipality;
  final int bedrooms;
  final int bathrooms;
  final num area;
  final String addressLine1;
  final String contactPhone;
  final String contactWhatsapp;
  final List<PhotoModel> photos;
  final CreatedByModel createdBy;

  ListingModel({
    required this.id,
    required this.propertyName,
    required this.type,
    required this.purpose,
    required this.price,
    required this.areaName,
    required this.municipality,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.addressLine1,
    required this.contactPhone,
    required this.contactWhatsapp,
    required this.photos,
    required this.createdBy,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      id: json["id"] ?? "",
      propertyName: json["propertyName"] ?? "",
      type: ListingType.fromJson(json["type"] ?? {}),
      purpose: json["purpose"] ?? "",
      price: json["price"] ?? 0,
      areaName: json["areaName"] ?? "",
      municipality: Municipality.fromJson(json["municipality"] ?? {}),
      bedrooms: json["bedrooms"] ?? 0,
      bathrooms: json["bathrooms"] ?? 0,
      area: json["area"] ?? 0,
      addressLine1: json["addressLine1"] ?? "",
      contactPhone: json["contactPhone"] ?? "",
      contactWhatsapp: json["contactWhatsapp"] ?? "",
      photos: (json["photos"] as List? ?? [])
          .map((e) => PhotoModel.fromJson(e))
          .toList(),
      createdBy: CreatedByModel.fromJson(json["createdBy"] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "propertyName": propertyName,
      "type": type.toJson(),
      "purpose": purpose,
      "price": price,
      "areaName": areaName,
      "municipality": municipality.toJson(),
      "bedrooms": bedrooms,
      "bathrooms": bathrooms,
      "area": area,
      "addressLine1": addressLine1,
      "contactPhone": contactPhone,
      "contactWhatsapp": contactWhatsapp,
      "photos": photos.map((e) => e.toJson()).toList(),
      "createdBy": createdBy.toJson(),
    };
  }
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

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
      };
}

class Municipality {
  final String id;
  final String name;

  Municipality({
    required this.id,
    required this.name,
  });

  factory Municipality.fromJson(Map<String, dynamic> json) {
    return Municipality(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
class PhotoModel {
  final String url;
  final String caption;
  final int sortOrder;

  PhotoModel({
    required this.url,
    required this.caption,
    required this.sortOrder,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      url: json["url"] ?? "",
      caption: json["caption"] ?? "",
      sortOrder: json["sortOrder"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "url": url,
      "caption": caption,
      "sortOrder": sortOrder,
    };
  }
}

class CreatedByModel {
  final String id;
  final String name;
  final String email;

  CreatedByModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory CreatedByModel.fromJson(Map<String, dynamic> json) {
    return CreatedByModel(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
    };
  }
}
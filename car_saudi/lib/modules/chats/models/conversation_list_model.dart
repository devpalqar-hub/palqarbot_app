import 'conversation_model.dart';
import 'message_model.dart';

class ConversationListModel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ConversationUserModel user;
  final ListingModel listing;
  final List<ParticipantModel> participants;
  final MessageModel? lastMessage;

  ConversationListModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.listing,
    required this.participants,
    this.lastMessage,
  });

  factory ConversationListModel.fromJson(Map<String, dynamic> json) {
    return ConversationListModel(
      id: json["id"] ?? "",
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
      user: ConversationUserModel.fromJson(json["user"] ?? {}),
      listing: ListingModel.fromJson(json["listing"] ?? {}),
      participants: (json["participants"] as List? ?? [])
          .map((e) => ParticipantModel.fromJson(e))
          .toList(),
      lastMessage: json["lastMessage"] == null
          ? null
          : MessageModel.fromJson(json["lastMessage"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      "user": user.toJson(),
      "listing": listing.toJson(),
      "participants": participants.map((e) => e.toJson()).toList(),
      "lastMessage": lastMessage?.toJson(),
    };

  }
  
  ParticipantModel? getOtherParticipant() {
  try {
    return participants.firstWhere(
      (p) => p.user.id != user.id,
    );
  } catch (_) {
    return null;
  }
}
}

class ConversationUserModel {
  final String id;
  final String name;
  final String email;

  ConversationUserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory ConversationUserModel.fromJson(Map<String, dynamic> json) {
    return ConversationUserModel(
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

class ParticipantModel {
  final String userId;
  final SenderModel user;

  ParticipantModel({
    required this.userId,
    required this.user,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      userId: json["userId"] ?? "",
      user: SenderModel.fromJson(json["user"] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "user": user.toJson(),
    };
  }
}
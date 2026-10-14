class MessageModel {
  final String id;
  final String conversationId;
  final String type;
  final String? content;
  final String? mediaUrl;
  final double? latitude;
  final double? longitude;
  final String? locationLabel;
  final DateTime createdAt;
  final SenderModel sender;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.type,
    this.content,
    this.mediaUrl,
    this.latitude,
    this.longitude,
    this.locationLabel,
    required this.createdAt,
    required this.sender,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      type: json['type'] ?? '',
      content: json['content'],
      mediaUrl: json['mediaUrl'],
      latitude: json['latitude'] == null
          ? null
          : (json['latitude'] as num).toDouble(),
      longitude: json['longitude'] == null
          ? null
          : (json['longitude'] as num).toDouble(),
      locationLabel: json['locationLabel'],
      createdAt: DateTime.parse(json['createdAt']),
      sender: SenderModel.fromJson(json['sender'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "conversationId": conversationId,
      "type": type,
      "content": content,
      "mediaUrl": mediaUrl,
      "latitude": latitude,
      "longitude": longitude,
      "locationLabel": locationLabel,
      "createdAt": createdAt.toIso8601String(),
      "sender": sender.toJson(),
    };
  }

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? type,
    String? content,
    String? mediaUrl,
    double? latitude,
    double? longitude,
    String? locationLabel,
    DateTime? createdAt,
    SenderModel? sender,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      type: type ?? this.type,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationLabel: locationLabel ?? this.locationLabel,
      createdAt: createdAt ?? this.createdAt,
      sender: sender ?? this.sender,
    );
  }
}

class SenderModel {
  final String id;
  final String name;
  final String email;
  final String role;

  SenderModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory SenderModel.fromJson(Map<String, dynamic> json) {
    return SenderModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "role": role,
    };
  }

  SenderModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
  }) {
    return SenderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}
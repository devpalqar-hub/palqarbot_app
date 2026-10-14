import 'message_model.dart';

class MessagePageModel {
  final List<MessageModel> data;
  final MessageMeta meta;

  MessagePageModel({
    required this.data,
    required this.meta,
  });

  factory MessagePageModel.fromJson(Map<String, dynamic> json) {
    return MessagePageModel(
      data: (json["data"] as List? ?? [])
          .map((e) => MessageModel.fromJson(e))
          .toList(),
      meta: MessageMeta.fromJson(json["meta"] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "data": data.map((e) => e.toJson()).toList(),
      "meta": meta.toJson(),
    };
  }
}

class MessageMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  MessageMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory MessageMeta.fromJson(Map<String, dynamic> json) {
    return MessageMeta(
      total: json["total"] ?? 0,
      page: json["page"] ?? 1,
      limit: json["limit"] ?? 50,
      totalPages: json["totalPages"] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "total": total,
      "page": page,
      "limit": limit,
      "totalPages": totalPages,
    };
  }
}
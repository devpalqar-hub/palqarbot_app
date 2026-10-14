class SupportTicketDetails {
  final String id;
  final String category;
  final String subject;
  final String message;
  final String status;
  final int replyCount;
  final String? listingId;
  final String? reportedUserId;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final SupportTicketUser? submitter;
  final SupportTicketUser? assignedTo;

  final List<SupportTicketReply> replies;

  const SupportTicketDetails({
    required this.id,
    required this.category,
    required this.subject,
    required this.message,
    required this.status,
    this.listingId,
    this.reportedUserId,
    this.createdAt,
    this.updatedAt,
    this.submitter,
    this.assignedTo,
    required this.replyCount,
    required this.replies,
  });

  factory SupportTicketDetails.fromJson(
    Map<String, dynamic> json,
  ) {
    return SupportTicketDetails(
      id: json['id']?.toString() ?? '',

      category:
          json['category']?.toString() ?? '',

      subject:
          json['subject']?.toString() ?? '',

      message:
          json['message']?.toString() ?? '',

      status:
          json['status']?.toString() ?? '',

      listingId:
          json['listingId']?.toString(),

      reportedUserId:
          json['reportedUserId']?.toString(),

      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(
                  json['createdAt'].toString(),
                )
              : null,

      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(
                  json['updatedAt'].toString(),
                )
              : null,

      submitter:
          json['submitter'] is Map
              ? SupportTicketUser.fromJson(
                  Map<String, dynamic>.from(
                    json['submitter'],
                  ),
                )
              : null,

      assignedTo:
          json['assignedTo'] is Map
              ? SupportTicketUser.fromJson(
                  Map<String, dynamic>.from(
                    json['assignedTo'],
                  ),
                )
              : null,

      replies:
          json['replies'] is List
              ? (json['replies'] as List)
                  .whereType<Map>()
                  .map(
                    (item) =>
                        SupportTicketReply.fromJson(
                      Map<String, dynamic>.from(
                        item,
                      ),
                    ),
                  )
                  .toList()
              : [],

      replyCount:
    json['_count'] is Map
        ? int.tryParse(
              json['_count']['replies']
                      ?.toString() ??
                  '0',
            ) ??
            0
        : 0,
    );
  }
}

// ============================================================
// USER / SUBMITTER / ASSIGNED ADMIN / REPLY AUTHOR
// ============================================================

class SupportTicketUser {
  final String id;
  final String? name;
  final String? email;
  final String role;

  const SupportTicketUser({
    required this.id,
    this.name,
    this.email,
    required this.role,
  });

  factory SupportTicketUser.fromJson(
    Map<String, dynamic> json,
  ) {
    return SupportTicketUser(
      id: json['id']?.toString() ?? '',

      name:
          json['name']?.toString(),

      email:
          json['email']?.toString(),

      role:
          json['role']?.toString() ?? '',
    );
  }
}

// ============================================================
// SUPPORT TICKET REPLY
// ============================================================

class SupportTicketReply {
  final String id;
  final String message;
  final bool isAdmin;
  final DateTime? createdAt;
  final SupportTicketUser? author;

  const SupportTicketReply({
    required this.id,
    required this.message,
    required this.isAdmin,
    this.createdAt,
    this.author,
  });

  factory SupportTicketReply.fromJson(
    Map<String, dynamic> json,
  ) {
    return SupportTicketReply(
      id: json['id']?.toString() ?? '',

      message:
          json['message']?.toString() ?? '',

      isAdmin:
          json['isAdmin'] == true,

      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(
                  json['createdAt'].toString(),
                )
              : null,

      author:
          json['author'] is Map
              ? SupportTicketUser.fromJson(
                  Map<String, dynamic>.from(
                    json['author'],
                  ),
                )
              : null,
    );
  }
}
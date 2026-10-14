class SupportTicket {
  final String id;
  final String category;
  final String subject;
  final String? message;
  final String status;

  final String? listingId;
  final String? reportedUserId;
  final String? referenceId;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final TicketSubmitter? submitter;

  final int repliesCount;

  const SupportTicket({
    required this.id,
    required this.category,
    required this.subject,
    this.message,
    required this.status,
    this.listingId,
    this.reportedUserId,
    this.referenceId,
    this.createdAt,
    this.updatedAt,
    this.submitter,
    this.repliesCount = 0,
  });

  factory SupportTicket.fromJson(
    Map<String, dynamic> json,
  ) {
    return SupportTicket(
      id: json['id']?.toString() ?? '',

      category:
          json['category']?.toString() ?? '',

      subject:
          json['subject']?.toString() ?? '',

      message:
          json['message']?.toString(),

      status:
          json['status']?.toString() ?? '',

      listingId:
          json['listingId']?.toString(),

      reportedUserId:
          json['reportedUserId']?.toString(),

      referenceId:
          json['referenceId']?.toString(),

      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(
              json['createdAt'].toString(),
            )
          : null,

      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(
              json['updatedAt'].toString(),
            )
          : null,

      submitter: json['submitter']
              is Map<String, dynamic>
          ? TicketSubmitter.fromJson(
              json['submitter'],
            )
          : null,

      repliesCount:
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
// SUBMITTER
// ============================================================

class TicketSubmitter {
  final String id;
  final String? name;
  final String? email;
  final String role;

  const TicketSubmitter({
    required this.id,
    this.name,
    this.email,
    required this.role,
  });

  factory TicketSubmitter.fromJson(
    Map<String, dynamic> json,
  ) {
    return TicketSubmitter(
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
// META
// ============================================================

class SupportTicketMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const SupportTicketMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory SupportTicketMeta.fromJson(
    Map<String, dynamic> json,
  ) {
    return SupportTicketMeta(
      total: int.tryParse(
            json['total']?.toString() ?? '0',
          ) ??
          0,

      page: int.tryParse(
            json['page']?.toString() ?? '1',
          ) ??
          1,

      limit: int.tryParse(
            json['limit']?.toString() ?? '20',
          ) ??
          20,

      totalPages: int.tryParse(
            json['totalPages']?.toString() ?? '1',
          ) ??
          1,
    );
  }
}

// ============================================================
// LIST RESPONSE
// ============================================================

class SupportTicketsResponse {
  final List<SupportTicket> data;
  final SupportTicketMeta meta;

  const SupportTicketsResponse({
    required this.data,
    required this.meta,
  });

  factory SupportTicketsResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawData = json['data'];

    return SupportTicketsResponse(
      data: rawData is List
          ? rawData
              .whereType<Map<String, dynamic>>()
              .map(
                (item) =>
                    SupportTicket.fromJson(item),
              )
              .toList()
          : [],

      meta: json['meta']
              is Map<String, dynamic>
          ? SupportTicketMeta.fromJson(
              json['meta'],
            )
          : const SupportTicketMeta(
              total: 0,
              page: 1,
              limit: 20,
              totalPages: 1,
            ),
    );
  }
}
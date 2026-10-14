/// Response shape of GET /api/dealers/analytics/dashboard.
class DealerAnalyticsResponse {
  final DealerOverview overview;
  final List<DealerGraphPoint> graph;
  final List<DealerTopListing> topListings;

  DealerAnalyticsResponse({
    required this.overview,
    required this.graph,
    required this.topListings,
  });

  factory DealerAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    final graphJson = json['graph'] as Map<String, dynamic>? ?? {};
    return DealerAnalyticsResponse(
      overview: DealerOverview.fromJson(
        Map<String, dynamic>.from(json['overview'] ?? {}),
      ),
      graph: ((graphJson['series'] as List?) ?? [])
          .map((e) => DealerGraphPoint.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      topListings: ((json['topListings'] as List?) ?? [])
          .map((e) => DealerTopListing.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class DealerOverview {
  final DealerListingsSummary listings;
  final DealerEngagement engagement;
  final DealerChats chats;
  final DealerWhatsapp whatsapp;
  final DealerVisits visits;
  final DealerQuota quota;
  final DealerSubscriptionSummary? subscription;
  final DealerStaffSummary staff;
  final DealerSales sales;

  DealerOverview({
    required this.listings,
    required this.engagement,
    required this.chats,
    required this.whatsapp,
    required this.visits,
    required this.quota,
    required this.subscription,
    required this.staff,
    required this.sales,
  });

  factory DealerOverview.fromJson(Map<String, dynamic> json) {
    return DealerOverview(
      listings: DealerListingsSummary.fromJson(
        Map<String, dynamic>.from(json['listings'] ?? {}),
      ),
      engagement: DealerEngagement.fromJson(
        Map<String, dynamic>.from(json['engagement'] ?? {}),
      ),
      chats: DealerChats.fromJson(Map<String, dynamic>.from(json['chats'] ?? {})),
      whatsapp: DealerWhatsapp.fromJson(
        Map<String, dynamic>.from(json['whatsapp'] ?? {}),
      ),
      visits: DealerVisits.fromJson(Map<String, dynamic>.from(json['visits'] ?? {})),
      quota: DealerQuota.fromJson(Map<String, dynamic>.from(json['quota'] ?? {})),
      subscription: json['subscription'] != null
          ? DealerSubscriptionSummary.fromJson(
              Map<String, dynamic>.from(json['subscription']),
            )
          : null,
      staff: DealerStaffSummary.fromJson(Map<String, dynamic>.from(json['staff'] ?? {})),
      sales: DealerSales.fromJson(Map<String, dynamic>.from(json['sales'] ?? {})),
    );
  }
}

class DealerListingsSummary {
  final int total;
  final int open;
  final int pending;
  final int rejected;
  final int sold;
  final int inactive;
  final int activeFeatured;

  DealerListingsSummary({
    required this.total,
    required this.open,
    required this.pending,
    required this.rejected,
    required this.sold,
    required this.inactive,
    required this.activeFeatured,
  });

  factory DealerListingsSummary.fromJson(Map<String, dynamic> json) {
    return DealerListingsSummary(
      total: json['total'] ?? 0,
      open: json['open'] ?? 0,
      pending: json['pending'] ?? 0,
      rejected: json['rejected'] ?? 0,
      sold: json['sold'] ?? 0,
      inactive: json['inactive'] ?? 0,
      activeFeatured: json['activeFeatured'] ?? 0,
    );
  }
}

class DealerEngagement {
  final int totalViews;
  final int periodViews;
  final int totalImpressions;
  final int periodImpressions;
  final int totalReach;
  final int periodReach;

  DealerEngagement({
    required this.totalViews,
    required this.periodViews,
    required this.totalImpressions,
    required this.periodImpressions,
    required this.totalReach,
    required this.periodReach,
  });

  factory DealerEngagement.fromJson(Map<String, dynamic> json) {
    return DealerEngagement(
      totalViews: json['totalViews'] ?? 0,
      periodViews: json['periodViews'] ?? 0,
      totalImpressions: json['totalImpressions'] ?? 0,
      periodImpressions: json['periodImpressions'] ?? 0,
      totalReach: json['totalReach'] ?? 0,
      periodReach: json['periodReach'] ?? 0,
    );
  }
}

class DealerChats {
  final int totalConversations;
  final int periodConversations;
  final int totalUsersStartedChat;
  final int periodUsersStartedChat;

  DealerChats({
    required this.totalConversations,
    required this.periodConversations,
    required this.totalUsersStartedChat,
    required this.periodUsersStartedChat,
  });

  factory DealerChats.fromJson(Map<String, dynamic> json) {
    return DealerChats(
      totalConversations: json['totalConversations'] ?? 0,
      periodConversations: json['periodConversations'] ?? 0,
      totalUsersStartedChat: json['totalUsersStartedChat'] ?? 0,
      periodUsersStartedChat: json['periodUsersStartedChat'] ?? 0,
    );
  }
}

class DealerWhatsapp {
  final int totalClicks;
  final int periodClicks;

  DealerWhatsapp({required this.totalClicks, required this.periodClicks});

  factory DealerWhatsapp.fromJson(Map<String, dynamic> json) {
    return DealerWhatsapp(
      totalClicks: json['totalClicks'] ?? 0,
      periodClicks: json['periodClicks'] ?? 0,
    );
  }
}

class DealerVisits {
  final int total;
  final int period;
  final Map<String, int> byStatus;

  DealerVisits({required this.total, required this.period, required this.byStatus});

  factory DealerVisits.fromJson(Map<String, dynamic> json) {
    final byStatusJson = Map<String, dynamic>.from(json['byStatus'] ?? {});
    return DealerVisits(
      total: json['total'] ?? 0,
      period: json['period'] ?? 0,
      byStatus: byStatusJson.map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0)),
    );
  }

  int get pending => byStatus['PENDING'] ?? 0;
  int get accepted => byStatus['ACCEPTED'] ?? 0;
}

class DealerQuota {
  final int remainingFreeListings;
  final int remainingFreeFeatured;

  DealerQuota({required this.remainingFreeListings, required this.remainingFreeFeatured});

  factory DealerQuota.fromJson(Map<String, dynamic> json) {
    return DealerQuota(
      remainingFreeListings: json['remainingFreeListings'] ?? 0,
      remainingFreeFeatured: json['remainingFreeFeatured'] ?? 0,
    );
  }
}

/// Current-plan summary embedded in the dashboard overview — distinct
/// from the full history returned by GET /api/dealer-subscriptions/my.
class DealerSubscriptionSummary {
  final bool hasActivePlan;
  final String? planId;
  final String? planName;
  final int maxListings;
  final DateTime? startDate;
  final DateTime? endDate;
  final int daysRemaining;
  final bool isExpired;

  DealerSubscriptionSummary({
    required this.hasActivePlan,
    this.planId,
    this.planName,
    required this.maxListings,
    this.startDate,
    this.endDate,
    required this.daysRemaining,
    required this.isExpired,
  });

  factory DealerSubscriptionSummary.fromJson(Map<String, dynamic> json) {
    return DealerSubscriptionSummary(
      hasActivePlan: json['hasActivePlan'] ?? false,
      planId: json['planId'],
      planName: json['planName'],
      maxListings: json['maxListings'] ?? 0,
      startDate: DateTime.tryParse(json['startDate'] ?? ''),
      endDate: DateTime.tryParse(json['endDate'] ?? ''),
      daysRemaining: json['daysRemaining'] ?? 0,
      isExpired: json['isExpired'] ?? false,
    );
  }
}

class DealerStaffSummary {
  final int totalStaffMembers;
  final List<DealerStaffMember> members;

  DealerStaffSummary({required this.totalStaffMembers, required this.members});

  factory DealerStaffSummary.fromJson(Map<String, dynamic> json) {
    return DealerStaffSummary(
      totalStaffMembers: json['totalStaffMembers'] ?? 0,
      members: ((json['members'] as List?) ?? [])
          .map((e) => DealerStaffMember.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class DealerStaffMember {
  final String id;
  final String name;
  final String email;
  final String position;

  DealerStaffMember({
    required this.id,
    required this.name,
    required this.email,
    required this.position,
  });

  factory DealerStaffMember.fromJson(Map<String, dynamic> json) {
    return DealerStaffMember(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      position: json['position'] ?? '',
    );
  }
}

class DealerSales {
  final int soldCount;
  final num soldValue;

  DealerSales({required this.soldCount, required this.soldValue});

  factory DealerSales.fromJson(Map<String, dynamic> json) {
    return DealerSales(
      soldCount: json['soldCount'] ?? 0,
      soldValue: json['soldValue'] ?? 0,
    );
  }
}

class DealerGraphPoint {
  final DateTime period;
  final int views;
  final int visits;
  final int chats;
  final int whatsappChats;

  DealerGraphPoint({
    required this.period,
    required this.views,
    required this.visits,
    required this.chats,
    required this.whatsappChats,
  });

  factory DealerGraphPoint.fromJson(Map<String, dynamic> json) {
    return DealerGraphPoint(
      period: DateTime.tryParse(json['period'] ?? '') ?? DateTime.now(),
      views: json['views'] ?? 0,
      visits: json['visits'] ?? 0,
      chats: json['chats'] ?? 0,
      whatsappChats: json['whatsappChats'] ?? 0,
    );
  }
}

class DealerListingType {
  final String id;
  final String title;

  DealerListingType({required this.id, required this.title});

  factory DealerListingType.fromJson(Map<String, dynamic> json) {
    return DealerListingType(id: json['id'] ?? '', title: json['title'] ?? '');
  }
}

class DealerTopListing {
  final String id;
  final String propertyName;
  final String slug;
  final String referenceCode;
  final String status;
  final String purpose;
  final num price;
  final DealerListingType? type;
  final int viewsCount;
  final int reachCount;
  final int whatsappClicksCount;
  final int conversationsCount;
  final int visitsCount;

  DealerTopListing({
    required this.id,
    required this.propertyName,
    required this.slug,
    required this.referenceCode,
    required this.status,
    required this.purpose,
    required this.price,
    required this.type,
    required this.viewsCount,
    required this.reachCount,
    required this.whatsappClicksCount,
    required this.conversationsCount,
    required this.visitsCount,
  });

  factory DealerTopListing.fromJson(Map<String, dynamic> json) {
    return DealerTopListing(
      id: json['id'] ?? '',
      propertyName: json['propertyName'] ?? '',
      slug: json['slug'] ?? '',
      referenceCode: json['referenceCode'] ?? '',
      status: json['status'] ?? '',
      purpose: json['purpose'] ?? '',
      price: json['price'] ?? 0,
      type: json['type'] != null
          ? DealerListingType.fromJson(Map<String, dynamic>.from(json['type']))
          : null,
      viewsCount: json['viewsCount'] ?? 0,
      reachCount: json['reachCount'] ?? 0,
      whatsappClicksCount: json['whatsappClicksCount'] ?? 0,
      conversationsCount: json['conversationsCount'] ?? 0,
      visitsCount: json['visitsCount'] ?? 0,
    );
  }
}

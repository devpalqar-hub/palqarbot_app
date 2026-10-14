/// One entry from GET /api/dealer-subscriptions/my — the dealer's full
/// subscription history (past, active, pending payment, failed, ...).
class DealerSubscriptionModel {
  final String id;
  final String dealerId;
  final String planId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String paymentStatus;
  final num? paidAmount;
  final DealerSubscriptionPlan? plan;

  DealerSubscriptionModel({
    required this.id,
    required this.dealerId,
    required this.planId,
    this.startDate,
    this.endDate,
    required this.paymentStatus,
    this.paidAmount,
    this.plan,
  });

  factory DealerSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return DealerSubscriptionModel(
      id: json['id'] ?? '',
      dealerId: json['dealerId'] ?? '',
      planId: json['planId'] ?? '',
      startDate: DateTime.tryParse(json['startDate'] ?? ''),
      endDate: DateTime.tryParse(json['endDate'] ?? ''),
      paymentStatus: json['paymentStatus'] ?? '',
      paidAmount: json['paidAmount'],
      plan: json['plan'] != null
          ? DealerSubscriptionPlan.fromJson(Map<String, dynamic>.from(json['plan']))
          : null,
    );
  }

  /// Whether this subscription is the one currently in effect: paid (or
  /// comped free/by-admin) and today falls inside its date range.
  bool get isCurrentlyActive {
    if (paymentStatus != 'PAID' && paymentStatus != 'FREE') return false;
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }
}

class DealerSubscriptionPlan {
  final String id;
  final String name;
  final int maxListings;
  final int validityDays;
  final num price;
  final int freeListings;
  final int freeFeaturedListings;

  DealerSubscriptionPlan({
    required this.id,
    required this.name,
    required this.maxListings,
    required this.validityDays,
    required this.price,
    required this.freeListings,
    required this.freeFeaturedListings,
  });

  factory DealerSubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return DealerSubscriptionPlan(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      maxListings: json['maxListings'] ?? 0,
      validityDays: json['validityDays'] ?? 0,
      price: json['price'] ?? 0,
      freeListings: json['freeListings'] ?? 0,
      freeFeaturedListings: json['freeFeaturedListings'] ?? 0,
    );
  }
}

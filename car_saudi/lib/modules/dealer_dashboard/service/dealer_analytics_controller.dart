import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:villas_qatar/Core/network/api_endpoints.dart';
import 'package:villas_qatar/Core/network/api_handler.dart';
import 'package:villas_qatar/modules/dealer_dashboard/model/dealer_analytics_model.dart';
import 'package:villas_qatar/modules/dealer_dashboard/model/dealer_subscription_model.dart';

/// Backs the single-screen dealer portal: fetches
/// GET /api/dealers/analytics/dashboard (overview + trend graph + top
/// listings) and GET /api/dealer-subscriptions/my (plan history, for the
/// subscription card), and holds every filter the dashboard endpoint
/// accepts so the filter sheet can drive them.
class DealerAnalyticsController extends GetxController {
  static final DateFormat _dateFmt = DateFormat('yyyy-MM-dd');

  bool isLoading = false;
  bool isLoadingSubscriptions = false;
  String? error;

  DealerAnalyticsResponse? data;
  List<DealerSubscriptionModel> subscriptions = [];

  // ---- filters (mirror every query param the endpoint accepts) ----
  DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime endDate = DateTime.now();
  String granularity = 'daily'; // daily | weekly | monthly
  String? listingId;
  String? staffUserId;
  String? typeId;
  String? purpose; // SALE | RENT
  String? status; // OPEN | PENDING | REJECTED | SOLD | INACTIVE
  String? municipalityId;
  String? areaName;

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
    fetchSubscriptions();
  }

  /// The subscription actually in effect right now, from the full
  /// history — falls back to the dashboard overview's own summary (which
  /// the backend already resolves this the same way) if the history
  /// hasn't loaded yet.
  DealerSubscriptionModel? get activeSubscription {
    for (final s in subscriptions) {
      if (s.isCurrentlyActive) return s;
    }
    return null;
  }

  Future<void> fetchDashboard() async {
    try {
      isLoading = true;
      error = null;
      update();

      final params = <String, String>{
        'startDate': _dateFmt.format(startDate),
        'endDate': _dateFmt.format(endDate),
        'granularity': granularity,
        if (listingId != null && listingId!.isNotEmpty) 'listingId': listingId!,
        if (staffUserId != null && staffUserId!.isNotEmpty)
          'staffUserId': staffUserId!,
        if (typeId != null && typeId!.isNotEmpty) 'typeId': typeId!,
        if (purpose != null && purpose!.isNotEmpty) 'purpose': purpose!,
        if (status != null && status!.isNotEmpty) 'status': status!,
        if (municipalityId != null && municipalityId!.isNotEmpty)
          'municipalityId': municipalityId!,
        if (areaName != null && areaName!.isNotEmpty) 'areaName': areaName!,
      };

      final query = Uri(queryParameters: params).query;

      final response = await ApiHandler.get(
        '${ApiEndpoints.dealerAnalyticsDashboard}?$query',
      );

      data = DealerAnalyticsResponse.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      debugPrint('Dealer Analytics Error: $e');
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> fetchSubscriptions() async {
    try {
      isLoadingSubscriptions = true;
      update();

      final response = await ApiHandler.get(ApiEndpoints.dealerSubscriptionsMy);

      subscriptions = ((response as List?) ?? [])
          .map((e) => DealerSubscriptionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      debugPrint('Dealer Subscriptions Error: $e');
    } finally {
      isLoadingSubscriptions = false;
      update();
    }
  }

  /// Applies a new set of filter values (any left null keeps its current
  /// value) and refetches the dashboard.
  void applyFilters({
    DateTime? startDate,
    DateTime? endDate,
    String? granularity,
    String? listingId,
    bool clearListingId = false,
    String? staffUserId,
    bool clearStaffUserId = false,
    String? typeId,
    bool clearTypeId = false,
    String? purpose,
    bool clearPurpose = false,
    String? status,
    bool clearStatus = false,
    String? municipalityId,
    bool clearMunicipalityId = false,
    String? areaName,
    bool clearAreaName = false,
  }) {
    if (startDate != null) this.startDate = startDate;
    if (endDate != null) this.endDate = endDate;
    if (granularity != null) this.granularity = granularity;

    this.listingId = clearListingId ? null : (listingId ?? this.listingId);
    this.staffUserId = clearStaffUserId ? null : (staffUserId ?? this.staffUserId);
    this.typeId = clearTypeId ? null : (typeId ?? this.typeId);
    this.purpose = clearPurpose ? null : (purpose ?? this.purpose);
    this.status = clearStatus ? null : (status ?? this.status);
    this.municipalityId =
        clearMunicipalityId ? null : (municipalityId ?? this.municipalityId);
    this.areaName = clearAreaName ? null : (areaName ?? this.areaName);

    fetchDashboard();
  }

  void resetFilters() {
    startDate = DateTime.now().subtract(const Duration(days: 30));
    endDate = DateTime.now();
    granularity = 'daily';
    listingId = null;
    staffUserId = null;
    typeId = null;
    purpose = null;
    status = null;
    municipalityId = null;
    areaName = null;
    fetchDashboard();
  }
}

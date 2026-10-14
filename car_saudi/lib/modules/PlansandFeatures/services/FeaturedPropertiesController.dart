import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:villas_qatar/Core/network/api_endpoints.dart';
import 'package:villas_qatar/Core/network/api_handler.dart';
import 'package:villas_qatar/modules/PlansandFeatures/model/myfeatured_property.dart';
import 'package:villas_qatar/modules/home/model/PropertyModel.dart';

class FeaturedPropertiesController extends GetxController {
  // ============================================================
  // HOME / LISTING FEATURED CAROUSEL
  // ============================================================

  Future<List<PropertyModel>> fetchFeatureProperty({
    bool isHome = false,
    bool isListing = false,
    bool isPropertyPage = false,
  }) async {
    List<PropertyModel> propertyList = [];
    String loc = (isHome)
        ? "PROPERTY_DETAIL_PAGE"
        : (isListing)
        ? "LISTING_PAGE"
        : "HOME_PAGE";
    final response = await ApiHandler.get(
      "/api/featured?location=${loc}&page=1&limit=10",
    );

    if (response["data"].isNotEmpty) {
      for (var data in response["data"]) {
        propertyList.add(PropertyModel.fromJson(data["listing"]));
      }
    }
    update();
    return propertyList;
  }

  // ============================================================
  // MY FEATURED PROPERTIES STATE
  // ============================================================

  List<MyFeaturedProperty> myFeaturedProperties = [];

  bool isMyFeaturedPropertiesLoading = false;

  String myFeaturedPropertiesError = '';

  String myFeaturedPropertiesSearch = '';

  Future<void> getMyFeaturedProperties({bool forceRefresh = false}) async {
    if (isMyFeaturedPropertiesLoading) {
      return;
    }

    if (!forceRefresh && myFeaturedProperties.isNotEmpty) {
      return;
    }

    try {
      isMyFeaturedPropertiesLoading = true;
      myFeaturedPropertiesError = '';

      update();

      final dynamic response = await ApiHandler.get(
        ApiEndpoints.myfeaturedProperties,
      );

      if (response is! List) {
        throw Exception('Invalid featured properties response'.tr);
      }

      final List<MyFeaturedProperty> parsed = response
          .whereType<Map>()
          .map((item) => MyFeaturedProperty.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      myFeaturedProperties = _dedupeMyFeaturedProperties(parsed);
    } catch (e, stackTrace) {
      myFeaturedPropertiesError = e.toString().replaceFirst('Exception: ', '');

      debugPrint('GET MY FEATURED PROPERTIES ERROR: $myFeaturedPropertiesError');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isMyFeaturedPropertiesLoading = false;

      update();
    }
  }

  // ============================================================
  // DEDUPE MY FEATURED PROPERTIES
  //
  // The backend has occasionally returned two rows for the same
  // checkout (e.g. a retried Stripe webhook re-inserting instead of
  // updating), which showed up as the same boost purchase listed
  // twice. Collapse rows that share a Stripe session - that's an
  // unambiguous "same purchase attempt" key, unlike listingId/planId
  // which a genuine repeat purchase would also share. Falls back to
  // `id` for the (should-be-impossible) case of a row with no
  // stripeSessionId at all, so at least literal duplicate entries
  // still collapse.
  //
  // When a purchase has duplicate rows, keep the one that best
  // reflects its real outcome: PAID over anything else, otherwise
  // the most recently updated row.
  // ============================================================

  List<MyFeaturedProperty> _dedupeMyFeaturedProperties(
    List<MyFeaturedProperty> entries,
  ) {
    final List<MyFeaturedProperty> bySession = _collapseByKey(
      entries,
      keyOf: (entry) => entry.stripeSessionId?.isNotEmpty == true
          ? 'session:${entry.stripeSessionId}'
          : 'id:${entry.id}',
    );

    // Second pass: a retried webhook can create a *different* Stripe
    // session for the same purchase instead of reusing the first one,
    // which the pass above can't catch. Rows for the same listing+plan
    // created within a few minutes of each other are treated as the
    // same purchase attempt - a genuine renewal of the same plan
    // happens hours/days later, not seconds apart.
    const Duration sameAttemptWindow = Duration(minutes: 15);

    final List<MyFeaturedProperty> sorted = List.of(bySession)
      ..sort(
        (a, b) => (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0)),
      );

    final List<MyFeaturedProperty> result = [];

    for (final entry in sorted) {
      final int existingIndex = result.indexWhere((kept) {
        if (kept.listingId != entry.listingId || kept.planId != entry.planId) {
          return false;
        }

        final DateTime? a = kept.createdAt;
        final DateTime? b = entry.createdAt;

        if (a == null || b == null) {
          // No timestamp to compare - treat missing-timestamp rows for
          // the same listing+plan as the same attempt rather than risk
          // showing an un-collapsible duplicate.
          return true;
        }

        return b.difference(a).abs() <= sameAttemptWindow;
      });

      if (existingIndex == -1) {
        result.add(entry);
        continue;
      }

      final MyFeaturedProperty existing = result[existingIndex];

      final bool entryIsBetter = entry.isPaid && !existing.isPaid ||
          (entry.isPaid == existing.isPaid &&
              (entry.updatedAt ?? DateTime(0)).isAfter(existing.updatedAt ?? DateTime(0)));

      if (entryIsBetter) {
        result[existingIndex] = entry;
      }
    }

    return result;
  }

  List<MyFeaturedProperty> _collapseByKey(
    List<MyFeaturedProperty> entries, {
    required String Function(MyFeaturedProperty entry) keyOf,
  }) {
    final Map<String, MyFeaturedProperty> byKey = {};
    final List<String> order = [];

    for (final entry in entries) {
      final String key = keyOf(entry);

      final MyFeaturedProperty? existing = byKey[key];

      if (existing == null) {
        byKey[key] = entry;
        order.add(key);
        continue;
      }

      final bool entryIsBetter = entry.isPaid && !existing.isPaid ||
          (entry.isPaid == existing.isPaid &&
              (entry.updatedAt ?? DateTime(0)).isAfter(existing.updatedAt ?? DateTime(0)));

      if (entryIsBetter) {
        byKey[key] = entry;
      }
    }

    return order.map((key) => byKey[key]!).toList();
  }

  // ============================================================
  // MY FEATURED PROPERTIES SEARCH
  // LOCAL SEARCH - NO API FILTER
  // ============================================================

  void clearMyFeaturedPropertiesSearch() {
    if (myFeaturedPropertiesSearch.isEmpty) {
      return;
    }

    myFeaturedPropertiesSearch = '';

    update();
  }

  void searchMyFeaturedProperties(String value) {
    myFeaturedPropertiesSearch = value.trim();

    update();
  }

  Future<void> refreshMyFeaturedProperties() async {
    await getMyFeaturedProperties(forceRefresh: true);
  }

  // ============================================================
  // FILTERED MY FEATURED PROPERTIES
  // ============================================================

  List<MyFeaturedProperty> get filteredMyFeaturedProperties {
    final String query = myFeaturedPropertiesSearch.trim().toLowerCase();

    if (query.isEmpty) {
      return myFeaturedProperties;
    }

    return myFeaturedProperties.where((property) {
      final listing = property.listing;
      final plan = property.plan;

      return listing.propertyName.toLowerCase().contains(query) ||
          listing.status.toLowerCase().contains(query) ||
          (listing.slug ?? '').toLowerCase().contains(query) ||
          plan.name.toLowerCase().contains(query) ||
          plan.duration.toLowerCase().contains(query) ||
          property.location.toLowerCase().contains(query) ||
          property.paymentStatus.toLowerCase().contains(query);
    }).toList();
  }
}

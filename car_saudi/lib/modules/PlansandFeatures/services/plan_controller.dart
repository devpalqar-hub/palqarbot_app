import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:villas_qatar/Core/network/api_handler.dart';
import 'package:villas_qatar/Core/network/api_endpoints.dart';
import 'package:villas_qatar/modules/PlansandFeatures/model/featured_palnmodel.dart';

class FeaturedPlanController extends GetxController {
  bool isLoading = false;

  String error = '';

  List<FeaturedPlanModel> plans = [];

  FeaturedPlanModel? selectedPlan;

  bool isCheckoutLoading = false;

  /// ============================================================
  /// INITIAL LOAD
  /// ============================================================

  @override
  void onInit() {
    super.onInit();

    fetchFeaturedPlans();
  }

  /// ============================================================
  /// FETCH PLANS
  /// ============================================================

  Future<void> fetchFeaturedPlans({bool showLoading = true}) async {
    try {
      if (showLoading) {
        isLoading = true;
      }

      error = '';

      update();

      debugPrint("========== FETCH FEATURED PLANS ==========");

      final dynamic response = await ApiHandler.get(ApiEndpoints.featuredPlans);

      debugPrint("Featured Plans Response: $response");

      if (response is List) {
        plans = response
            .whereType<Map<String, dynamic>>()
            .map((json) => FeaturedPlanModel.fromJson(json))
            .toList();
      } else {
        plans = [];
      }

      /// Only keep active plans.
      plans = plans.where((plan) => plan.isActive).toList();

      /// Automatically select first plan.
      if (plans.isNotEmpty) {
        /// Keep previous selection if it still exists.
        if (selectedPlan != null) {
          final previousId = selectedPlan!.id;

          final index = plans.indexWhere((plan) => plan.id == previousId);

          selectedPlan = index >= 0 ? plans[index] : plans.first;
        } else {
          selectedPlan = plans.first;
        }
      } else {
        selectedPlan = null;
      }

      debugPrint("Featured Plans Loaded: ${plans.length}");

      if (selectedPlan != null) {
        debugPrint("Selected Plan: ${selectedPlan!.name}");
      }
    } catch (e) {
      debugPrint("Fetch Featured Plans Error: $e");

      error = e.toString().replaceFirst("Exception: ", "");

      plans = [];
      selectedPlan = null;
    } finally {
      isLoading = false;

      update();
    }
  }

  /// ============================================================
  /// SELECT PLAN
  /// ============================================================

  void selectPlan(FeaturedPlanModel plan) {
    selectedPlan = plan;

    debugPrint("========== PLAN SELECTED ==========");

    debugPrint("Plan ID: ${plan.id}");

    debugPrint("Plan: ${plan.name}");

    debugPrint("Price: ${plan.formattedPrice}");

    debugPrint("Duration: ${plan.formattedDuration}");

    update();
  }

  /// ============================================================
  /// CHECK SELECTED
  /// ============================================================

  bool isPlanSelected(FeaturedPlanModel plan) {
    return selectedPlan?.id == plan.id;
  }

  /// ============================================================
  /// RETRY
  /// ============================================================

  Future<void> retry() async {
    await fetchFeaturedPlans();
  }

  /// ============================================================
  /// CHECKOUT
  ///
  /// POST /api/featured/checkout
  ///
  /// BODY:
  /// {
  ///   "listingId": listingId,
  ///   "planId": planId
  /// }
  ///
  /// Same mechanics as /api/listings/make-payment: returns a Stripe
  /// Checkout Session (`paymentUrl`/`checkoutUrl` always,
  /// `paymentIntentClientSecret` once a PaymentIntent has been
  /// created for it) - or throws on failure.
  /// ============================================================
Future<BoostCheckoutSession> checkout({
  required String listingId,
  required String planId,
}) async {
  try {
    isCheckoutLoading = true;
    update();

    final Map<String, dynamic> body = {
      "listingId": listingId,
      "planId": planId,
    };

    debugPrint("========== BOOST CHECKOUT REQUEST ==========");
    debugPrint("Listing ID: $listingId");
    debugPrint("Plan ID: $planId");
   debugPrint("Request Body: ${jsonEncode(body)}");

    final dynamic response = await ApiHandler.post(
      ApiEndpoints.featuredCheckout,
      body: body,
    );

    // Print complete response
    debugPrint("========== BOOST CHECKOUT RESPONSE ==========");

    if (response is Map || response is List) {
      debugPrint(
        const JsonEncoder.withIndent('  ').convert(response),
      );
    } else {
      debugPrint("Response Body: $response");
    }

    debugPrint("============================================");

    if (response is Map) {
      final Map<String, dynamic> data =
          Map<String, dynamic>.from(response);

      final dynamic url =
          data['url'] ??
          data['checkoutUrl'] ??
          data['sessionUrl'] ??
          data['paymentUrl'];

      final dynamic clientSecret = data['paymentIntentClientSecret'];

      debugPrint("Checkout URL: $url");
      debugPrint("PaymentIntent Client Secret: $clientSecret");

      final bool hasUrl = url != null && url.toString().isNotEmpty;
      final bool hasClientSecret =
          clientSecret != null && clientSecret.toString().isNotEmpty;

      if (hasUrl || hasClientSecret) {
        return BoostCheckoutSession(
          checkoutUrl: hasUrl ? url.toString() : null,
          paymentIntentClientSecret:
              hasClientSecret ? clientSecret.toString() : null,
        );
      }
    }

    throw Exception(
      "Unable to start checkout. Please try again.".tr,
    );
  } catch (e, stackTrace) {
    debugPrint("========== BOOST CHECKOUT ERROR ==========");
    debugPrint("Error: $e");
    debugPrint("StackTrace: $stackTrace");

    rethrow;
  } finally {
    isCheckoutLoading = false;
    update();
  }
}
}

/// Result of POST /api/featured/checkout.
class BoostCheckoutSession {
  final String? checkoutUrl;
  final String? paymentIntentClientSecret;

  const BoostCheckoutSession({
    this.checkoutUrl,
    this.paymentIntentClientSecret,
  });
}

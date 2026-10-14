import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:villas_qatar/Core/constants/stripe_config.dart';

/// Outcome of a native Stripe PaymentSheet attempt.
enum StripePaymentOutcome { success, cancelled }

/// ================================================================
/// STRIPE CHECKOUT HELPER
/// ================================================================
///
/// Shared "pay for this listing" logic reused by every screen that
/// hits a `/checkout`-shaped endpoint (PENDING_PAYMENT "Pay",
/// featured/boost checkout, ...). Purely native - Stripe's
/// PaymentSheet, no webview, no browser hop. All of these backends
/// now return `paymentIntentClientSecret`; if it's ever missing this
/// throws instead of silently falling back to a webview.
class StripeCheckoutHelper {
  StripeCheckoutHelper._();

  static Future<StripePaymentOutcome> pay({
    required String? clientSecret,
  }) async {
    if (clientSecret == null || clientSecret.isEmpty) {
      throw Exception("Unable to start payment. Please try again.".tr);
    }

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: StripeConfig.merchantDisplayName,
          style: ThemeMode.light,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      // presentPaymentSheet() only returns without throwing once the
      // payment has actually gone through.
      return StripePaymentOutcome.success;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return StripePaymentOutcome.cancelled;
      }

      final String message =
          (e.error.localizedMessage ?? e.error.message ?? "").isNotEmpty
          ? (e.error.localizedMessage ?? e.error.message)!
          : "Something went wrong. Please try again.".tr;

      throw Exception(message);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// ============================================================
/// BOOST CHECKOUT RESULT
/// ============================================================
///
/// Returned by [BoostCheckoutWebviewScreen] once the user leaves
/// the Stripe checkout page, so the caller can react accordingly.

enum BoostCheckoutResult { success, cancelled, unknown }

/// ============================================================
/// BOOST CHECKOUT WEBVIEW SCREEN
/// ============================================================
///
/// Opens the Stripe Checkout URL returned by
/// `POST /api/featured/checkout` inside the app, and watches
/// navigation so we can detect Stripe's redirect back to our own
/// backend once payment succeeds or is cancelled - without needing
/// a custom URL scheme or deep link setup.

class BoostCheckoutWebviewScreen extends StatefulWidget {
  final String checkoutUrl;

  const BoostCheckoutWebviewScreen({super.key, required this.checkoutUrl});

  @override
  State<BoostCheckoutWebviewScreen> createState() =>
      _BoostCheckoutWebviewScreenState();
}

class _BoostCheckoutWebviewScreenState
    extends State<BoostCheckoutWebviewScreen> {
  static const Color primaryColor = Color(0xff9E123F);

  late final WebViewController _controller;

  bool _isLoading = true;

  bool _isFinishing = false;

  @override
  void initState() {
    super.initState();

    final Uri checkoutUri = Uri.parse(widget.checkoutUrl);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;

            setState(() => _isLoading = true);
          },

          onPageFinished: (_) {
            if (!mounted) return;

            setState(() => _isLoading = false);
          },

          onNavigationRequest: (request) {
            return _handleNavigation(request.url, checkoutUri);
          },
        ),
      )
      ..loadRequest(checkoutUri);
  }

  /// ============================================================
  /// HANDLE NAVIGATION
  /// ============================================================
  ///
  /// Stripe hosted checkout stays on a checkout.stripe.com host
  /// while the user is paying. Once payment succeeds/cancels,
  /// Stripe redirects to the success_url / cancel_url configured
  /// by the backend - which points back to our own domain. That
  /// redirect is our signal to close the webview.

  NavigationDecision _handleNavigation(String url, Uri checkoutUri) {
    final Uri uri = Uri.tryParse(url) ?? checkoutUri;

    final bool isStripeHost = uri.host.toLowerCase().contains("stripe.com");

    if (isStripeHost || _isFinishing) {
      return NavigationDecision.navigate;
    }

    debugPrint("========== BOOST CHECKOUT REDIRECT ==========");
    debugPrint("Redirect URL: $url");

    final String lower = url.toLowerCase();

    BoostCheckoutResult result = BoostCheckoutResult.unknown;

    if (lower.contains("success")) {
      result = BoostCheckoutResult.success;
    } else if (lower.contains("cancel") ||
        lower.contains("fail") ||
        lower.contains("error")) {
      // Covers both "cancel" (user backed out of Stripe) and "fail"/
      // "error" (payment declined) redirect URLs - callers such as the
      // PENDING_PAYMENT "Pay" flow use a failedUrl containing "failed"
      // rather than "cancel".
      result = BoostCheckoutResult.cancelled;
    }

    _finish(result);

    return NavigationDecision.prevent;
  }

  void _finish(BoostCheckoutResult result) {
    if (_isFinishing) return;

    _isFinishing = true;

    debugPrint("========== BOOST CHECKOUT FINISHED ==========");
    debugPrint("Result: $result");

    Get.back(result: result);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,

      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        _finish(BoostCheckoutResult.cancelled);
      },

      child: Scaffold(
        backgroundColor: Colors.white,

        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,

          leading: IconButton(
            onPressed: () => _finish(BoostCheckoutResult.cancelled),
            icon: Icon(
              Icons.close_rounded,
              size: 22.sp,
              color: const Color(0xff222222),
            ),
          ),

          title: Text(
            "Complete Payment".tr,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xff1F1F1F),
            ),
          ),

          centerTitle: true,

          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: const Color(0xffEEEEEE)),
          ),
        ),

        body: Stack(
          children: [
            WebViewWidget(controller: _controller),

            if (_isLoading)
              Container(
                color: Colors.white,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: primaryColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:villas_qatar/modules/propertydetailscreen/propertydetailscreen.dart';
import 'package:villas_qatar/modules/propertydetailscreen/service/deeplink_controller.dart';
import 'package:villas_qatar/modules/searchscreen/service/searchlist_screen.dart';
import 'package:villas_qatar/Core/utils/app_toast.dart';

class DeepLinkService {
  DeepLinkService._();

  static final AppLinks _appLinks = AppLinks();

  static StreamSubscription<Uri>? _linkSubscription;

  static String? _lastHandledLink;

  static bool _initialized = false;

  /// ============================================================
  /// INITIALIZE APP LINKS
  /// ============================================================

  static Future<void> initialize() async {
    /// Prevent multiple listeners
    if (_initialized) {
      debugPrint("App Link Service already initialized");
      return;
    }

    _initialized = true;

    try {
      debugPrint(
        "========== APP LINK INITIALIZE ==========",
      );

      /// ---------------------------------------------------------
      /// APP OPENED FROM TERMINATED STATE
      /// ---------------------------------------------------------

      final Uri? initialUri =
          await _appLinks.getInitialLink();

      if (initialUri != null) {
        debugPrint(
          "Initial App Link: $initialUri",
        );

        WidgetsBinding.instance.addPostFrameCallback(
          (_) async {
            await handleAppLink(initialUri);
          },
        );
      }

      /// ---------------------------------------------------------
      /// APP ALREADY OPEN / BACKGROUND
      /// ---------------------------------------------------------

      _linkSubscription =
          _appLinks.uriLinkStream.listen(
        (Uri uri) async {
          debugPrint(
            "Incoming App Link: $uri",
          );

          await handleAppLink(uri);
        },
        onError: (error) {
          debugPrint(
            "App Link Stream Error: $error",
          );
        },
      );
    } catch (e) {
      debugPrint(
        "App Link Initialization Error: $e",
      );

      _initialized = false;
    }
  }

  /// ============================================================
  /// HANDLE APP LINK
  /// ============================================================

  static Future<void> handleAppLink(
    Uri uri,
  ) async {
    try {
      debugPrint(
        "========== HANDLE APP LINK ==========",
      );

      debugPrint("Full URI: $uri");
      debugPrint("Scheme: ${uri.scheme}");
      debugPrint("Host: ${uri.host}");
      debugPrint("Path: ${uri.path}");
      debugPrint(
        "Segments: ${uri.pathSegments}",
      );

      /// Only accept HTTPS App Links
      if (uri.scheme.toLowerCase() != "https") {
        debugPrint(
          "Ignored: Not HTTPS",
        );
        return;
      }

      /// Only accept our domain - this must match the App Link host
      /// registered in AndroidManifest.xml (<data android:host=.../>),
      /// which is the web/share domain, NOT the API backend host
      /// (apivillas.palqar.cloud). A mismatch here silently drops
      /// every real shared link before it ever reaches _openProperty.
      if (uri.host.toLowerCase() !=
          "villas.palqar.cloud") {
        debugPrint(
          "Ignored: Invalid host ${uri.host}",
        );
        return;
      }

      final String link =
          uri.toString();

      /// Avoid processing same event twice
      if (_lastHandledLink == link) {
        debugPrint(
          "App Link already handled: $link",
        );
        return;
      }

      /// Expected:
      ///
      /// https://villas.palqar.cloud/
      /// property/luxury-villas-tx44ux

      if (uri.pathSegments.length < 2) {
        debugPrint(
          "Invalid App Link path",
        );
        return;
      }

      if (uri.pathSegments[0]
              .toLowerCase() !=
          "property") {
        debugPrint(
          "Unknown App Link path: ${uri.path}",
        );
        return;
      }

      final String slug =
          Uri.decodeComponent(
        uri.pathSegments[1],
      ).trim();

      if (slug.isEmpty) {
        debugPrint(
          "Property slug is empty",
        );
        return;
      }

      /// Mark only valid links as handled.
      _lastHandledLink = link;

      debugPrint(
        "========== PROPERTY APP LINK ==========",
      );

      debugPrint(
        "Property Slug: $slug",
      );

      await _openProperty(
        slug: slug,
      );
    } catch (e) {
      debugPrint(
        "Handle App Link Error: $e",
      );

      /// Allow retry if processing failed.
      _lastHandledLink = null;
    }
  }

  /// ============================================================
  /// FETCH PROPERTY AND OPEN DETAILS
  /// ============================================================

  static Future<void> _openProperty({
    required String slug,
  }) async {
    try {
      debugPrint(
        "========== OPEN APP LINK PROPERTY ==========",
      );

      final DeepLinkController
          deepLinkController =
          Get.isRegistered<DeepLinkController>()
              ? Get.find<DeepLinkController>()
              : Get.put(
                  DeepLinkController(),
                  permanent: true,
                );

      /// Calls:
      ///
      /// GET
      /// /api/listings/slug/{slug}

      final property =
          await deepLinkController
              .fetchPropertyBySlug(
        slug: slug,
      );

      if (property == null) {
        _lastHandledLink = null;

        AppToast.show(
          msg: deepLinkController.error.isNotEmpty
              ? deepLinkController.error
              : "Unable to open this property".tr,
        );

        return;
      }

      debugPrint(
        "Property Loaded: "
        "${property.propertyName}",
      );

      /// PropertyDetailsScreen reads selectedProperty
      /// from PropertySearchController.

      final PropertySearchController
          propertyController =
          Get.isRegistered<
                  PropertySearchController>()
              ? Get.find<
                  PropertySearchController>()
              : Get.put(
                  PropertySearchController(),
                  permanent: true,
                );

      // propertyController.selectedProperty =
      //     property;

      // propertyController.isDetailsLoading =
      //     false;

      // propertyController.update();

      // debugPrint(
      //   "Opening PropertyDetailsScreen",
      // );

      // Get.to(
      //   () =>
      //       const PropertyDetailsScreen(),
      // );
      debugPrint(
  "Opening PropertyDetailsScreen: ${property.id}",
);

Get.to(
  () => PropertyDetailsScreen(
    propertyId: property.id,
  ),
);
    } catch (e) {
      _lastHandledLink = null;

      debugPrint(
        "Open App Link Property Error: $e",
      );

      AppToast.show(
        msg: "Unable to open this property".tr,
      );
    }
  }

  /// ============================================================
  /// DISPOSE
  /// ============================================================

  static Future<void> dispose() async {
    await _linkSubscription?.cancel();

    _linkSubscription = null;
    _lastHandledLink = null;
    _initialized = false;
  }
}
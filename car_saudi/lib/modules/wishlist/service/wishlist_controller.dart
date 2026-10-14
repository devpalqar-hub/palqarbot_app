import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:villas_qatar/Core/network/api_endpoints.dart';
import 'package:villas_qatar/Core/network/api_handler.dart';
import 'package:villas_qatar/Core/utils/auth_guard.dart';
import 'package:villas_qatar/modules/propertylist/model/myproperty_model.dart';

class WishlistController extends GetxController {
  bool isLoading = false;

  /// Keeps track of individual property wishlist API calls.
  final Set<String> loadingPropertyIds = {};

  String error = "";

  /// Full wishlist properties returned from GET /api/wishlists
  List<Property> wishlistProperties = [];

  /// Makes checking wishlist status fast.
  final Set<String> wishlistedIds = {};

  @override
  void onInit() {
    super.onInit();
    fetchWishlist();
  }

  // ============================================================
  // GET WISHLIST
  // ============================================================

  Future<void> fetchWishlist() async {
    try {
      isLoading = true;
      error = "";
      update();

      final response = await ApiHandler.get(ApiEndpoints.wishlists);

      debugPrint("========== WISHLIST RESPONSE ==========");
      debugPrint(response.toString());

      final List<dynamic> data = response is List ? response : [];

      wishlistProperties = data
          .map((json) => Property.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      /// Sync wishlist IDs
      wishlistedIds
        ..clear()
        ..addAll(wishlistProperties.map((property) => property.id));

      debugPrint("WISHLIST COUNT: ${wishlistProperties.length}");
    } catch (e) {
      error = e.toString();

      debugPrint("FETCH WISHLIST ERROR: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  // ============================================================
  // CHECK IF WISHLISTED
  // ============================================================

  bool isWishlisted(String propertyId) {
    return wishlistedIds.contains(propertyId);
  }

  bool isPropertyLoading(String propertyId) {
    return loadingPropertyIds.contains(propertyId);
  }

  // ============================================================
  // TOGGLE WISHLIST
  // ============================================================


Future<void> toggleWishlist(String propertyId) async {
  if (!AuthGuard.requireLogin(
    message: "Login is required to save properties to your wishlist.".tr,
  )) {
    return;
  }

  /// Prevent double clicks
  if (loadingPropertyIds.contains(propertyId)) {
    return;
  }

  try {
    loadingPropertyIds.add(propertyId);
    update();

    final response = await ApiHandler.post(
      ApiEndpoints.wishlistByProperty(propertyId),
    );

    final bool isNowWishlisted = response["isWishlisted"] == true;

    if (isNowWishlisted) {
      wishlistedIds.add(propertyId);
    } else {
      wishlistedIds.remove(propertyId);
      wishlistProperties.removeWhere(
        (property) => property.id == propertyId,
      );
    }

    update();

    await fetchWishlist();
  } catch (e) {
    debugPrint("TOGGLE WISHLIST ERROR: $e");
  } finally {
    loadingPropertyIds.remove(propertyId);
    update();
  }
}
  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshWishlist() async {
    await fetchWishlist();
  }
}

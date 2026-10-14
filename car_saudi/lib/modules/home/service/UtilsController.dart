import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:villas_qatar/Core/network/api_handler.dart';
import 'package:villas_qatar/modules/home/model/ListingOptions.dart';


class Utilscontroller extends GetxController {
  /// Plain (non-Rx) state — call update() after mutating and wrap the
  /// consuming widget in a GetBuilder<Utilscontroller>.
  bool isLoading = false;
  String? errorMessage;

  List<OptionItem> amenities = [];
  List<OptionItem> nearbyTags = [];
  List<OptionItem> furnishingOptions = [];
  List<OptionItem> listingTypes = [];
  List<Municipality> municipalities = [];

  Future<void> fetchPropertyType() async {
    isLoading = true;
    errorMessage = null;
    update();

    try {
      final response = await ApiHandler.get("/api/listings/options");

      final options = ListingOptions.fromJson(response);

      amenities = options.amenities;
      nearbyTags = options.nearbyTags;
      furnishingOptions = options.furnishingOptions;
      listingTypes = options.listingTypes;
      municipalities = options.municipalities;
    } catch (e) {
      // This runs unawaited from onInit() (including for guest sessions
      // right after Skip), so a network hiccup here must never surface
      // as an unhandled-exception snackbar — just note it and let the
      // screen render with empty option lists.
      debugPrint("FETCH LISTING OPTIONS ERROR: $e");
      errorMessage = "Failed to load listing options: $e";
    } finally {
      isLoading = false;
      update();
    }
  }

  /// Convenience: municipalities flagged as popular.
  List<Municipality> get popularMunicipalities =>
      municipalities.where((m) => m.isPopular).toList();

  /// Convenience: look up an OptionItem title by id (e.g. selected amenity ids).
  String? amenityTitleById(String id) =>
      amenities.firstWhereOrNull((a) => a.id == id)?.title;

}

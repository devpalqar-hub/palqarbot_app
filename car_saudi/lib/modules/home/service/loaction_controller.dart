import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:villas_qatar/Core/network/api_endpoints.dart';
import 'package:villas_qatar/Core/network/api_handler.dart';
import 'package:villas_qatar/Core/utils/app_location.dart';
import 'package:villas_qatar/modules/home/model/location_repsone_model.dart';
import 'package:villas_qatar/modules/home/model/nearBypropertyResponse.dart';
import 'package:villas_qatar/Core/utils/app_toast.dart';

class LocationController extends GetxController {
  static LocationController get to => Get.find();

  final TextEditingController searchController = TextEditingController();

  bool isLoading = false;

  LocationResponse? location;

  String get areaName => location?.data.areaName ?? "";

  String get formattedAddress => location?.data.formattedAddress ?? "";

  double get latitude => location?.data.latitude ?? 0.0;

  double get longitude => location?.data.longitude ?? 0.0;

  LocationResponse? selectedLocation;

  List<LocationResponse> results = [];
  List<NearByListingModel> nearbyProperties = [];

  bool isNearbyLoading = false;

  int nearbyPage = 1;
  final int nearbyLimit = 12;
  bool hasMoreNearby = true;

  @override
  void onInit() {
    super.onInit();

    /// Restore the last saved location (if any) so it survives
    /// app restarts instead of falling back to the Doha default.
    AppLocation.restore();
  }

  Future<bool> searchLocation(String keyword) async {
    try {
      isLoading = true;
      update();

      final response = await ApiHandler.get(
        "${ApiEndpoints.geocode}?location=${Uri.encodeComponent(keyword)}",
      );

      location = LocationResponse.fromJson(response);

      AppLocation.keyword = keyword;
      AppLocation.title = location?.data.title ?? "";
      AppLocation.areaName = location?.data.areaName ?? "";
      AppLocation.formattedAddress = location?.data.formattedAddress ?? "";
      AppLocation.latitude = location?.data.latitude;
      AppLocation.longitude = location?.data.longitude;
      await AppLocation.persist();
      await fetchNearbyProperties(refresh: true);

      update();

      return true;
    } catch (e) {
      debugPrint("Location Error: $e");
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> onSearchChanged(String value) async {
    if (value.trim().length < 2) {
      results.clear();
      update();
      return;
    }

    isLoading = true;
    update();

    final response = await ApiHandler.get(
      "${ApiEndpoints.geocode}?location=${Uri.encodeComponent(value)}",
    );

    results = [LocationResponse.fromJson(response)];

    isLoading = false;

    update();
  }

  void selectLocation(LocationResponse item) {
    location = item;
    selectedLocation = item;

    AppLocation.keyword = item.keyword;
    AppLocation.title = item.data.title;
    AppLocation.areaName = item.data.areaName;
    AppLocation.formattedAddress = item.data.formattedAddress;

    AppLocation.latitude = item.data.latitude;
    AppLocation.longitude = item.data.longitude;

    // If available in API
    // AppLocation.municipalityId = item.data.municipalityId ?? "";
    // AppLocation.municipalityName = item.data.municipalityName ?? "";
    AppLocation.persist();
    fetchNearbyProperties(refresh: true);
    searchController.clear();
    results.clear();

    update();
  }

  Future<void> detectCurrentLocation() async {
    try {
      isLoading = true;
      update();

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppToast.show(msg: "Please enable location services.".tr);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        AppToast.show(msg: "Location permission denied.".tr);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      debugPrint("========== CURRENT GPS ==========");
      debugPrint("Latitude : ${position.latitude}");
      debugPrint("Longitude: ${position.longitude}");

      final url =
          "${ApiHandler.baseUrl}${ApiEndpoints.reverseGeocode}"
          "?latitude=${position.latitude}"
          "&longitude=${position.longitude}";

      debugPrint("========== REVERSE GEOCODE REQUEST ==========");
      debugPrint("URL: $url");

      final response = await ApiHandler.get(
        "${ApiEndpoints.reverseGeocode}"
        "?latitude=${position.latitude}"
        "&longitude=${position.longitude}",
      );

      debugPrint("========== REVERSE GEOCODE RESPONSE ==========");
      debugPrint(response.toString());

      location = LocationResponse.fromJson(response);
      selectedLocation = location;
      AppLocation.keyword = "";

      AppLocation.title = location?.data.title ?? "";

      AppLocation.areaName = location?.data.areaName ?? "";

      AppLocation.formattedAddress = location?.data.formattedAddress ?? "";

      AppLocation.latitude = location?.data.latitude;

      AppLocation.longitude = location?.data.longitude;
      await AppLocation.persist();
      await fetchNearbyProperties(refresh: true);

      // If your API returns municipality
      // AppLocation.municipalityId =
      //     location?.data.municipalityId ?? "";
      //
      // AppLocation.municipalityName =
      //     location?.data.municipalityName ?? "";

      searchController.clear();
      results.clear();

      update();
    } catch (e, stackTrace) {
      debugPrint("========== REVERSE GEOCODE ERROR ==========");
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());

      AppToast.show(msg: "Unable to detect current location.".tr);
    } finally {
      isLoading = false;
      update();
    }
  }

  void _updateGlobalLocation(LocationResponse item) {
    AppLocation.keyword = item.keyword;

    AppLocation.title = item.data.title;

    AppLocation.areaName = item.data.areaName;

    AppLocation.formattedAddress = item.data.formattedAddress;

    AppLocation.latitude = item.data.latitude;

    AppLocation.longitude = item.data.longitude;

    // Uncomment if available in your model
    // AppLocation.municipalityId =
    //     item.data.municipalityId ?? "";
    // AppLocation.municipalityName =
    //     item.data.municipalityName ?? "";
  }

  Future<void> clearLocation() async {
    location = null;
    selectedLocation = null;

    await AppLocation.clear();

    searchController.clear();
    results.clear();
    nearbyProperties.clear();
nearbyPage = 1;
hasMoreNearby = true;

    update();
  }


  Future<void> fetchNearbyProperties({
  bool refresh = false,
}) async {
  try {
    if (refresh) {
      nearbyPage = 1;
      hasMoreNearby = true;
      nearbyProperties.clear();
    }

    if (!hasMoreNearby) return;

    isNearbyLoading = true;
    update();

    final response = await ApiHandler.get(
      "${ApiEndpoints.nearbyProperties}"
      "?latitude=${AppLocation.latitude}"
      "&longitude=${AppLocation.longitude}"
      "&radiusKm=10"
      "&page=$nearbyPage"
      "&limit=$nearbyLimit",
    );

    final model = NearbyPropertyResponse.fromJson(response);

    if (refresh) {
      nearbyProperties = model.data;
    } else {
      nearbyProperties.addAll(model.data);
    }

    hasMoreNearby = model.meta.hasNextPage;
    nearbyPage++;
  } catch (e) {
    debugPrint("Nearby Property Error : $e");
  } finally {
    isNearbyLoading = false;
    update();
  }
}

}

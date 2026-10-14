import 'package:villas_qatar/Core/services/storage_service.dart';

class AppLocation {
  AppLocation._();

  static String keyword = "";

  static String title = "";

  static String areaName = "";

  static String formattedAddress = "";

  static String municipalityId = "";

  static String municipalityName = "";

  static double? latitude;

  static double? longitude;

  static bool get hasLocation =>
      latitude != null && longitude != null;

  /// Restore the last saved location (call once at app startup,
  /// after StorageService.init()).
  static void restore() {
    final saved = StorageService.getLocation();

    if (saved == null) return;

    keyword = saved['keyword'] ?? "";
    title = saved['title'] ?? "";
    areaName = saved['areaName'] ?? "";
    formattedAddress = saved['formattedAddress'] ?? "";
    municipalityId = saved['municipalityId'] ?? "";
    municipalityName = saved['municipalityName'] ?? "";
    latitude = (saved['latitude'] as num?)?.toDouble();
    longitude = (saved['longitude'] as num?)?.toDouble();
  }

  /// Persist the current location so it survives app restarts.
  static Future<void> persist() async {
    await StorageService.saveLocation({
      'keyword': keyword,
      'title': title,
      'areaName': areaName,
      'formattedAddress': formattedAddress,
      'municipalityId': municipalityId,
      'municipalityName': municipalityName,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  static Future<void> clear() async {
    keyword = "";
    title = "";
    areaName = "";
    formattedAddress = "";
    municipalityId = "";
    municipalityName = "";
    latitude = null;
    longitude = null;

    await StorageService.removeLocation();
  }
}

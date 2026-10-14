class LocationResponse {
  final bool cached;
  final String keyword;
  final String title;
  final LocationData data;

  LocationResponse({
    required this.cached,
    required this.keyword,
    required this.title,
    required this.data,
  });

  factory LocationResponse.fromJson(Map<String, dynamic> json) {
    return LocationResponse(
      cached: json["cached"] ?? false,
      keyword: json["keyword"] ?? "",
      title: json["title"] ?? "",
      data: LocationData.fromJson(json["data"] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "cached": cached,
      "keyword": keyword,
      "title": title,
      "data": data.toJson(),
    };
  }
}

class LocationData {
  final String title;
  final String areaName;
  final double latitude;
  final double longitude;
  final String formattedAddress;

  LocationData({
    required this.title,
    required this.areaName,
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      title: json["title"] ?? "",
      areaName: json["areaName"] ?? "",
      latitude: (json["latitude"] as num?)?.toDouble() ?? 0,
      longitude: (json["longitude"] as num?)?.toDouble() ?? 0,
      formattedAddress: json["formattedAddress"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "areaName": areaName,
      "latitude": latitude,
      "longitude": longitude,
      "formattedAddress": formattedAddress,
    };
  }
}
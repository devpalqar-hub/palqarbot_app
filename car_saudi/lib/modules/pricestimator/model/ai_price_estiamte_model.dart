class AiPriceEstimatorRequest {
  final String areaName;
  final double areaSqft;
  final String propertyType;

  /// Optional specifications — left null when the user did not choose them,
  /// so the backend does not treat a default as a real answer.
  final int? bhk;
  final int? bathrooms;
  final String? furnishingStatus;
  final int? floorAbove;
  final int? totalFloors;
  final bool? parkingAvailable;
  final String highlights;

  const AiPriceEstimatorRequest({
    required this.areaName,
    required this.areaSqft,
    required this.propertyType,
    this.bhk,
    this.bathrooms,
    this.furnishingStatus,
    this.floorAbove,
    this.totalFloors,
    this.parkingAvailable,
    this.highlights = "",
  });

  Map<String, dynamic> toJson() {
    return {
      "areaName": areaName.trim(),
      "areaSqft": areaSqft,
      "propertyType": propertyType.trim(),
      if (bhk != null) "bhk": bhk,
      if (bathrooms != null) "bathrooms": bathrooms,
      if (furnishingStatus != null && furnishingStatus!.trim().isNotEmpty)
        "furnishingStatus": furnishingStatus!.trim(),
      if (floorAbove != null) "floorAbove": floorAbove,
      if (totalFloors != null) "totalFloors": totalFloors,
      if (parkingAvailable != null) "parkingAvailable": parkingAvailable,
      if (highlights.trim().isNotEmpty) "highlights": highlights.trim(),
    };
  }
}

class AiPriceEstimatorResponse {
  final double minPrice;
  final double maxPrice;
  final double averagePrice;

  const AiPriceEstimatorResponse({
    required this.minPrice,
    required this.maxPrice,
    required this.averagePrice,
  });

  factory AiPriceEstimatorResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return AiPriceEstimatorResponse(
      minPrice: _parseDouble(
        json["minPrice"],
      ),
      maxPrice: _parseDouble(
        json["maxPrice"],
      ),
      averagePrice: _parseDouble(
        json["averagePrice"],
      ),
    );
  }

  static double _parseDouble(
    dynamic value,
  ) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }
}
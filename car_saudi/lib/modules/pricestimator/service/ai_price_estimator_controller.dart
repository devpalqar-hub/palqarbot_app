import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:villas_qatar/Core/network/api_endpoints.dart';
import 'package:villas_qatar/Core/network/api_handler.dart';
import 'package:villas_qatar/modules/pricestimator/model/ai_price_estiamte_model.dart';


class AiPriceEstimatorController extends GetxController {
  bool isLoading = false;

  String error = "";

  AiPriceEstimatorResponse? estimation;
  bool get hasResult => estimation != null;

  double get minPrice => estimation?.minPrice ?? 0;

  double get maxPrice => estimation?.maxPrice ?? 0;

  double get averagePrice =>
      estimation?.averagePrice ?? 0;
  final Set<String> _selectedAmenities = {};

  

  Future<bool> estimatePrice({
    required String areaName,
    required double areaSqft,
    required String propertyType,
    int? bhk,
    int? bathrooms,
    String? furnishingStatus,
    int? floorAbove,
    int? totalFloors,
    bool? parkingAvailable,
    String highlights = "",
  }) async {
    if (isLoading) {
      return false;
    }

    try {
      isLoading = true;

      error = "";

      estimation = null;

      update();

      final AiPriceEstimatorRequest request =
          AiPriceEstimatorRequest(
        areaName: areaName,
        areaSqft: areaSqft,
        propertyType: propertyType,
        bhk: bhk,
        bathrooms: bathrooms,
        furnishingStatus: furnishingStatus,
        floorAbove: floorAbove,
        totalFloors: totalFloors,
        parkingAvailable: parkingAvailable,
        highlights: highlights,
      );

      final Map<String, dynamic> body =
          request.toJson();


      debugPrint(
        "==========================================",
      );

      debugPrint(
        "AI PRICE ESTIMATOR REQUEST",
      );

      debugPrint(
        "ENDPOINT: ${ApiEndpoints.estimatePrice}",
      );

      debugPrint(
        "REQUEST BODY: $body",
      );

      debugPrint(
        "==========================================",
      );

    

      final dynamic response =
          await ApiHandler.post(
        ApiEndpoints.estimatePrice,
        body: body,
      );


      debugPrint(
        "==========================================",
      );

      debugPrint(
        "AI PRICE ESTIMATOR RESPONSE",
      );

      debugPrint(
        "RESPONSE BODY: $response",
      );

      debugPrint(
        "==========================================",
      );

      if (response is! Map<String, dynamic>) {
        throw Exception(
          "Invalid price estimation response".tr,
        );
      }

     

      estimation =
          AiPriceEstimatorResponse.fromJson(
        response,
      );


      debugPrint(
        "MIN PRICE: ${estimation!.minPrice}",
      );

      debugPrint(
        "AVERAGE PRICE: ${estimation!.averagePrice}",
      );

      debugPrint(
        "MAX PRICE: ${estimation!.maxPrice}",
      );

      update();

      return true;
    } catch (e, stackTrace) {
     

      error = e
          .toString()
          .replaceFirst(
            "Exception: ",
            "",
          );

      estimation = null;

      debugPrint(
        "==========================================",
      );

      debugPrint(
        "AI PRICE ESTIMATOR ERROR",
      );

      debugPrint(
        "ERROR: $error",
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      debugPrint(
        "==========================================",
      );

      return false;
    } finally {
      // ========================================================
      // STOP LOADING
      // ========================================================

      isLoading = false;

      update();
    }
  }

  void clearEstimation() {
    estimation = null;

    error = "";

    update();
  }
}
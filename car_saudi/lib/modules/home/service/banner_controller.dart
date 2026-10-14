import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:villas_qatar/Core/network/api_endpoints.dart';
import 'package:villas_qatar/Core/network/api_handler.dart';
import 'package:villas_qatar/modules/home/model/banner_model.dart';

class BannerController extends GetxController {
  List<BannerModel> banners = [];

  bool isLoading = false;
  String errorMessage = '';

  Future<void> fetchBanners() async {
    if (isLoading) return;

    try {
      isLoading = true;
      errorMessage = '';

      update();

      debugPrint(
        'Fetching banners: ${ApiEndpoints.banners}',
      );

      final dynamic response = await ApiHandler.get(
        ApiEndpoints.banners,
      );

      debugPrint(
        'Banner response: $response',
      );

      if (response is List) {
        banners = response
            .whereType<Map>()
            .map(
              (item) => BannerModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();

        // Sort using position from API
        banners.sort(
          (a, b) => a.position.compareTo(b.position),
        );

        debugPrint(
          'Total banners: ${banners.length}',
        );
      } else {
        banners.clear();

        errorMessage =
            'Invalid banner response format';

        debugPrint(
          'Expected List but received: '
          '${response.runtimeType}',
        );
      }
    } catch (e, stackTrace) {
      banners.clear();

      errorMessage = e
          .toString()
          .replaceFirst('Exception: ', '');

      debugPrint(
        'Fetch banners error: $e',
      );

      debugPrint(
        'Stack trace: $stackTrace',
      );
    } finally {
      isLoading = false;

      update();
    }
  }

  Future<void> refreshBanners() async {
    await fetchBanners();
  }
}
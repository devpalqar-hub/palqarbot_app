import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'package:villas_qatar/Core/network/api_endpoints.dart';
import 'package:villas_qatar/Core/network/api_handler.dart';
import 'package:villas_qatar/modules/dealers/model/dealer_details_model.dart';
import 'package:villas_qatar/modules/dealers/model/dealer_list_model.dart';


import 'package:villas_qatar/Core/utils/app_toast.dart';
class DealerController extends GetxController {
  bool isLoading = false;
  bool isLoadingMore = false;

  bool hasMore = true;

  int page = 1;
  final int limit = 10;

  String error = "";

  List<Dealer> dealers = [];

  DealerDetailsModel? dealer;

  //==========================================================
  // DEALER LIST
  //==========================================================

  Future<void> fetchDealers({
    bool loadMore = false,
  }) async {
    if (loadMore) {
      if (isLoadingMore || !hasMore) return;

      isLoadingMore = true;
    } else {
      if (isLoading) return;

      isLoading = true;
      page = 1;
      hasMore = true;
      error = "";
    }

    update();

    try {
      final uri = Uri.parse(
        ApiEndpoints.dealers,
      ).replace(
        queryParameters: {
          "page": loadMore ? page.toString() : "1",
          "limit": limit.toString(),
        },
      );

      final response = await ApiHandler.get(
        uri.toString(),
      );

      final model = DealerListModel.fromJson(response);

      if (loadMore) {
        dealers.addAll(
          model.data.where(
            (e) => !dealers.any(
              (x) => x.id == e.id,
            ),
          ),
        );
      } else {
        dealers = model.data;
      }

      hasMore = page < model.meta.totalPages;

      if (hasMore) page++;

      update();
    } catch (e) {
      error = e.toString().replaceFirst("Exception: ", "");

      // This runs automatically on Home screen load — including for guest
      // sessions right after "Skip", who never send an auth token — so a
      // failure here (e.g. "Unauthorized") must not pop a toast. The UI
      // already renders a "No dealers found" empty state from `error`/
      // an empty `dealers` list, so just log it.
      debugPrint("FETCH DEALERS ERROR: $error");
    } finally {
      isLoading = false;
      isLoadingMore = false;
      update();
    }
  }

  Future<void> refreshDealers() async {
    page = 1;
    hasMore = true;
    dealers.clear();
    await fetchDealers();
  }

  //==========================================================
  // DEALER DETAILS
  //==========================================================

  Future<void> fetchDealerDetails(
    String dealerId,
  ) async {
    try {
      isLoading = true;
      update();

      final response = await ApiHandler.get(
        ApiEndpoints.dealerDetails(
          dealerId,
        ),
      );

      dealer = DealerDetailsModel.fromJson(
        response,
      );
    } catch (e) {
      AppToast.show(
        msg: e.toString().replaceFirst(
          "Exception: ",
          "",
        ),
      );

      debugPrint(e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }
}
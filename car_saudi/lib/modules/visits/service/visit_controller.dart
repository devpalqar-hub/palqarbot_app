import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:villas_qatar/Core/network/api_endpoints.dart';
import 'package:villas_qatar/Core/network/api_handler.dart';
import 'package:villas_qatar/modules/visits/model/visit_model.dart';

import 'package:villas_qatar/Core/utils/app_toast.dart';
class VisitController extends GetxController {
  bool isScheduling = false;
  bool isAccepting = false;

  bool isOwnerVisitsLoading = false;
  bool isVisitorVisitsLoading = false;
  bool isRejecting = false;

  dynamic scheduledVisit;

  List<VisitModel> ownerVisits = [];
  List<VisitModel> visitorVisits = [];

  @override
  void onInit() {
    super.onInit();

    fetchOwnerVisits();
    fetchVisitorVisits();
  }

  Future<bool> scheduleVisit({
    required String propertyId,
    required DateTime scheduledAt,
    String? notes,
  }) async {
    try {
      isScheduling = true;
      update();

      final body = {
        "scheduledAt": scheduledAt.toUtc().toIso8601String(),
        "notes": notes?.trim() ?? "",
      };

      debugPrint("========== SCHEDULE VISIT ==========");
      debugPrint("Property ID: $propertyId");
      debugPrint("BODY: $body");

      final response = await ApiHandler.post(
        ApiEndpoints.scheduleVisit(propertyId),
        body: body,
      );
      scheduledVisit = response;

      // Refresh visitor list after booking
      await fetchVisitorVisits(showLoading: false);

      AppToast.show(
        msg: "Visit scheduled successfully".tr,
      );

      return true;
    } catch (e) {
      debugPrint("Schedule Visit Error: $e");

      AppToast.show(
        msg: e.toString().replaceFirst("Exception: ", ""),
      );

      return false;
    } finally {
      isScheduling = false;
      update();
    }
  }

  Future<bool> acceptVisit({required String visitId}) async {
    try {
      isAccepting = true;
      update();
      final response = await ApiHandler.patch(
        ApiEndpoints.acceptVisit(visitId),
        body: {},
      );
      await fetchOwnerVisits(showLoading: false);

      AppToast.show(
        msg: "Visit scheduled successfully".tr,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green.shade700,
        textColor: Colors.white,
      );
      return true;
    } catch (e) {
      debugPrint("Accept Visit Error: $e");

      AppToast.show(
        msg: e.toString().replaceFirst("Exception: ", ""),
      );

      return false;
    } finally {
      isAccepting = false;
      update();
    }
  }

  Future<void> fetchOwnerVisits({bool showLoading = true}) async {
    try {
      if (showLoading) {
        isOwnerVisitsLoading = true;
        update();
      }

      final response = await ApiHandler.get(ApiEndpoints.visitsAsOwner);
      if (response is List) {
        ownerVisits = response
            .whereType<Map<String, dynamic>>()
            .map((json) => VisitModel.fromJson(json))
            .toList();
      } else {
        ownerVisits = [];
      }

      debugPrint("Owner Visits Count: ${ownerVisits.length}");
    } catch (e) {
      debugPrint("Fetch Owner Visits Error: $e");

      ownerVisits = [];
    } finally {
      isOwnerVisitsLoading = false;
      update();
    }
  }

  // =========================================================
  // GET VISITS AS VISITOR
  // GET /api/visits/as-visitor
  // =========================================================

  Future<void> fetchVisitorVisits({bool showLoading = true}) async {
    try {
      if (showLoading) {
        isVisitorVisitsLoading = true;
        update();
      }

      debugPrint("========== FETCH VISITOR VISITS ==========");

      final response = await ApiHandler.get(ApiEndpoints.visitsAsVisitor);

      debugPrint("Visitor Visits Response: $response");

      if (response is List) {
        visitorVisits = response
            .whereType<Map<String, dynamic>>()
            .map((json) => VisitModel.fromJson(json))
            .toList();
      } else {
        visitorVisits = [];
      }

      debugPrint("Visitor Visits Count: ${visitorVisits.length}");
    } catch (e) {
      debugPrint("Fetch Visitor Visits Error: $e");

      visitorVisits = [];
    } finally {
      isVisitorVisitsLoading = false;
      update();
    }
  }

  Future<bool> rejectVisit({required String visitId}) async {
    final String id = visitId.trim();

    if (id.isEmpty) {
      debugPrint("Reject Visit: Visit ID is empty");

      AppToast.show(
        msg: "Visit ID is missing".tr,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );

      return false;
    }

    try {
      isRejecting = true;
      update();
      final response = await ApiHandler.patch(
        ApiEndpoints.closeVisit(id),
        body: {},
      );
      /// Update local visit
      if (response is Map<String, dynamic>) {
        final updatedVisit = VisitModel.fromJson(response);

        final int index = ownerVisits.indexWhere((visit) => visit.id == id);

        if (index != -1) {
          ownerVisits[index] = updatedVisit;
        }

        update();
      }

      /// Get latest visits from server
      await fetchOwnerVisits(showLoading: false);
      return true;
    } catch (e) {
      AppToast.show(
        msg: e.toString().replaceFirst("Exception: ", ""),
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );

      return false;
    } finally {
      isRejecting = false;
      update();
    }
  }
}

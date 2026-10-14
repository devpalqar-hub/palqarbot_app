import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:villas_qatar/Core/network/api_endpoints.dart';
import 'package:villas_qatar/Core/network/api_handler.dart';
import 'package:villas_qatar/modules/invoices/model/invoice_model.dart';

// ============================================================
// INVOICE CONTROLLER
//
// GET /api/invoices?status=PAID&search=&page=&limit=
// ============================================================

class InvoiceController extends GetxController {
  bool isLoading = false;
  bool isLoadingMore = false;
  String error = "";

  List<Invoice> invoices = [];
  InvoiceMeta? meta;

  /// null -> "All" tab, "PAID" -> "Paid" tab.
  String? status;
  String search = "";

  int page = 1;
  final int limit = 20;
  bool hasMore = true;

  // Guards against a stale response (e.g. a fast search edit firing a
  // second request before the first resolves) overwriting fresher state.
  int _requestToken = 0;

  Timer? _searchDebounce;

  Future<void> fetchInvoices({
    bool loadMore = false,
    bool showLoader = true,
  }) async {
    final int myToken = ++_requestToken;

    if (loadMore) {
      if (isLoadingMore || !hasMore) return;
      isLoadingMore = true;
    } else {
      if (showLoader) isLoading = true;
      error = "";
      page = 1;
      hasMore = true;
    }

    update();

    try {
      final int requestedPage = loadMore ? page : 1;

      final query = <String, String>{
        "page": requestedPage.toString(),
        "limit": limit.toString(),
      };

      if (status != null && status!.isNotEmpty) {
        query["status"] = status!;
      }

      if (search.trim().isNotEmpty) {
        query["search"] = search.trim();
      }

      final uri = Uri.parse(
        ApiEndpoints.invoices,
      ).replace(queryParameters: query);

      debugPrint("FETCH INVOICES: $uri");

      final response = await ApiHandler.get(uri.toString());

      final result = InvoiceListResponse.fromJson(
        response is Map<String, dynamic> ? response : <String, dynamic>{},
      );

      if (myToken != _requestToken) return;

      if (loadMore) {
        final Set<String> existingIds = invoices.map((e) => e.id).toSet();

        invoices.addAll(
          result.data.where((invoice) => !existingIds.contains(invoice.id)),
        );
      } else {
        invoices = result.data;
      }

      meta = result.meta;

      hasMore = requestedPage < result.meta.totalPages;
      page = requestedPage + 1;

      error = "";
    } catch (e, stackTrace) {
      if (myToken != _requestToken) return;

      error = e.toString().replaceFirst("Exception: ", "");

      debugPrint("FETCH INVOICES ERROR: $e");
      debugPrint(stackTrace.toString());
    } finally {
      if (myToken == _requestToken) {
        isLoading = false;
        isLoadingMore = false;
        update();
      }
    }
  }

  Future<void> refreshInvoices() async {
    page = 1;
    hasMore = true;
    await fetchInvoices();
  }

  void applyStatus(String? newStatus) {
    if (status == newStatus) return;
    status = newStatus;
    fetchInvoices();
  }

  /// Debounced so every keystroke doesn't fire its own request.
  void applySearch(String value) {
    search = value;

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      fetchInvoices();
    });
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }
}

// ============================================================
// INVOICE DETAIL CONTROLLER
//
// GET /api/invoices/:id -> single invoice object (not wrapped in "data").
// ============================================================

class InvoiceDetailController extends GetxController {
  bool isLoading = false;
  String error = "";
  Invoice? invoice;

  Future<void> fetchInvoice(String id) async {
    isLoading = true;
    error = "";
    update();

    try {
      final response = await ApiHandler.get(ApiEndpoints.invoiceDetail(id));

      invoice = Invoice.fromJson(
        response is Map<String, dynamic> ? response : <String, dynamic>{},
      );
    } catch (e, stackTrace) {
      error = e.toString().replaceFirst("Exception: ", "");

      debugPrint("FETCH INVOICE DETAIL ERROR: $e");
      debugPrint(stackTrace.toString());
    } finally {
      isLoading = false;
      update();
    }
  }
}

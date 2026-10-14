import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:villas_qatar/Core/network/api_endpoints.dart';
import 'package:villas_qatar/Core/network/api_handler.dart';
import 'package:villas_qatar/modules/support/model/support_ticket_details.dart';
import 'package:villas_qatar/modules/support/model/support_ticket_model.dart';

enum SupportCategory {
  reportListing('REPORT_LISTING', 'Report Listing'),
  reportUser('REPORT_USER', 'Report User'),
  payment('PAYMENT', 'Payment'),
  general('GENERAL', 'General');

  final String apiValue;
  final String displayName;

  const SupportCategory(this.apiValue, this.displayName);
}

class SupportTicketController extends GetxController {
  // ============================================================
  // DATA
  // ============================================================

  List<SupportTicket> tickets = [];
  

  SupportTicketMeta? meta;

  SupportTicketDetails? selectedTicket;

SupportTicket? createdTicket;
  

bool isTicketDetailsLoading = false;

String ticketDetailsError = '';

  // ============================================================
  // CATEGORY
  // ============================================================

  SupportCategory selectedCategory = SupportCategory.general;

  List<SupportCategory> get categories => SupportCategory.values;

  // ============================================================
  // LOADING
  // ============================================================

  bool isLoading = false;

  bool isLoadingMore = false;

  bool isCreating = false;

  // ============================================================
  // ERRORS
  // ============================================================

  String error = '';

  String createError = '';

  // ============================================================
  // PAGINATION
  // ============================================================

  int page = 1;

  final int limit = 20;

  bool hasMore = true;

  int get total => meta?.total ?? tickets.length;

  // ============================================================
  // GET SUPPORT TICKETS
  // ============================================================

  Future<void> fetchTickets({
    bool loadMore = false,
    bool forceRefresh = false,
  }) async {
    // Prevent duplicate API calls

    if (loadMore) {
      if (isLoadingMore || !hasMore) {
        return;
      }

      isLoadingMore = true;
    } else {
      if (isLoading) {
        return;
      }

      if (!forceRefresh && tickets.isNotEmpty) {
        return;
      }

      isLoading = true;

      page = 1;
      hasMore = true;

      if (forceRefresh) {
        tickets.clear();
        meta = null;
      }
    }

    error = '';

    update();

    try {
      // ========================================================
      // BUILD ENDPOINT
      // ========================================================

      final String endpoint =
          '${ApiEndpoints.supportTickets}'
          '?limit=$limit'
          '&page=$page';

      debugPrint('Fetching support tickets: $endpoint');

      // ========================================================
      // API CALL
      // ========================================================

      final response = await ApiHandler.get(endpoint);

      if (response is! Map<String, dynamic>) {
        throw Exception('Invalid support tickets response'.tr);
      }

      // ========================================================
      // PARSE
      // ========================================================

      final SupportTicketsResponse result = SupportTicketsResponse.fromJson(
        response,
      );

      // ========================================================
      // SAVE / APPEND
      // ========================================================

      if (loadMore) {
        final Set<String> existingIds = tickets.map((e) => e.id).toSet();

        final List<SupportTicket> newItems = result.data.where((ticket) {
          return !existingIds.contains(ticket.id);
        }).toList();

        tickets.addAll(newItems);
      } else {
        tickets = result.data;
      }

      // ========================================================
      // META
      // ========================================================

      meta = result.meta;

      // ========================================================
      // HAS MORE
      // ========================================================

      hasMore = result.meta.page < result.meta.totalPages;

      // ========================================================
      // NEXT PAGE
      // ========================================================

      if (hasMore) {
        page = result.meta.page + 1;
      }

      debugPrint('Tickets loaded: ${tickets.length}');

      debugPrint('Total tickets: ${result.meta.total}');

      debugPrint('Has more: $hasMore');
    } catch (e, stackTrace) {
      error = e.toString().replaceFirst('Exception: ', '');

      debugPrint('Fetch support tickets error: $e');

      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (loadMore) {
        isLoadingMore = false;
      } else {
        isLoading = false;
      }

      update();
    }
  }

  // ============================================================
  // CREATE SUPPORT TICKET
  // ============================================================
Future<SupportTicket?> createTicket({
  required SupportCategory category,
  required String subject,
  required String message,
  String? listingId,
  String? reportedUserId,
  String? referenceId,
}) async {
  if (isCreating) return null;

  isCreating = true;
  createError = '';
  createdTicket = null;

  update();

  try {
    // ============================================================
    // REQUEST BODY
    // ============================================================

    final Map<String, dynamic> body = {
      'category': category.apiValue,
      'subject': subject.trim(),
      'message': message.trim(),

      if (listingId != null && listingId.trim().isNotEmpty)
        'listingId': listingId.trim(),

      if (reportedUserId != null &&
          reportedUserId.trim().isNotEmpty)
        'reportedUserId': reportedUserId.trim(),

      if (referenceId != null &&
          referenceId.trim().isNotEmpty)
        'referenceId': referenceId.trim(),
    };

    // ============================================================
    // PRINT REQUEST
    // ============================================================

    debugPrint(
      '========== CREATE SUPPORT TICKET REQUEST ==========',
    );

    debugPrint(
      'ENDPOINT: ${ApiEndpoints.supportTickets}',
    );

    debugPrint(
      'CATEGORY: ${category.apiValue}',
    );

    debugPrint(
      'SUBJECT: ${subject.trim()}',
    );

    debugPrint(
      'MESSAGE: ${message.trim()}',
    );

    debugPrint(
      'LISTING ID: ${listingId ?? ""}',
    );

    debugPrint(
      'REPORTED USER ID: ${reportedUserId ?? ""}',
    );

    debugPrint(
      'REFERENCE ID: ${referenceId ?? ""}',
    );

    debugPrint('REQUEST BODY:');

    debugPrint(
      const JsonEncoder.withIndent('  ').convert(body),
    );

    debugPrint(
      '===================================================',
    );

    // ============================================================
    // API CALL
    // ============================================================

    final response = await ApiHandler.post(
      ApiEndpoints.supportTickets,
      body: body,
    );

    // ============================================================
    // PRINT RESPONSE
    // ============================================================

    debugPrint(
      '========== CREATE SUPPORT TICKET RESPONSE ==========',
    );

    debugPrint(
      'RESPONSE TYPE: ${response.runtimeType}',
    );

    try {
      debugPrint(
        const JsonEncoder.withIndent('  ').convert(response),
      );
    } catch (_) {
      debugPrint(
        'RAW RESPONSE: $response',
      );
    }

    debugPrint(
      '====================================================',
    );

    // ============================================================
    // VALIDATE RESPONSE
    // ============================================================

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid create ticket response'.tr,
      );
    }

    // ============================================================
    // PARSE RESPONSE
    // ============================================================

    final SupportTicket ticket =
        SupportTicket.fromJson(response);

    createdTicket = ticket;

    // ============================================================
    // UPDATE LOCAL LIST
    // ============================================================

    tickets.removeWhere(
      (item) => item.id == ticket.id,
    );

    tickets.insert(
      0,
      ticket,
    );

    debugPrint(
      'SUPPORT TICKET CREATED SUCCESSFULLY',
    );

    debugPrint(
      'TICKET ID: ${ticket.id}',
    );

    return ticket;
  } catch (e, stackTrace) {
    createError = e
        .toString()
        .replaceFirst('Exception: ', '');

    debugPrint(
      '========== CREATE SUPPORT TICKET ERROR ==========',
    );

    debugPrint(
      'ERROR: $e',
    );

    debugPrint(
      'STACK TRACE: $stackTrace',
    );

    debugPrint(
      '=================================================',
    );

    return null;
  } finally {
    isCreating = false;
    update();
  }
}


// ============================================================
// GET SUPPORT TICKET DETAILS
// GET /api/support/tickets/:ticketId
// ============================================================

Future<SupportTicketDetails?> fetchTicketDetails(
  String ticketId, {
  bool showLoading = true,
}) async {
  final String id = ticketId.trim();

  if (id.isEmpty) {
    ticketDetailsError = 'Ticket ID is missing'.tr;
    update();
    return null;
  }

  try {
    if (showLoading) {
      isTicketDetailsLoading = true;
    }

    ticketDetailsError = '';

    /// Clear previously opened ticket
    selectedTicket = null;

    update();

    final String endpoint =
        '${ApiEndpoints.supportTickets}/$id';

    // ============================================================
    // PRINT REQUEST
    // ============================================================

    debugPrint(
      '========== GET SUPPORT TICKET DETAILS REQUEST ==========',
    );

    debugPrint('METHOD: GET');
    debugPrint('ENDPOINT: $endpoint');
    debugPrint('TICKET ID: $id');

    debugPrint(
      '========================================================',
    );

    // ============================================================
    // API CALL
    // ============================================================

    final response = await ApiHandler.get(
      endpoint,
    );

    // ============================================================
    // PRINT RESPONSE
    // ============================================================

    debugPrint(
      '========== GET SUPPORT TICKET DETAILS RESPONSE ==========',
    );

    try {
      debugPrint(
        const JsonEncoder.withIndent(
          '  ',
        ).convert(response),
      );
    } catch (_) {
      debugPrint(
        'RAW RESPONSE: $response',
      );
    }

    debugPrint(
      '=========================================================',
    );

    // ============================================================
    // VALIDATE RESPONSE
    // ============================================================

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid support ticket details response'.tr,
      );
    }

    // ============================================================
    // PARSE FULL DETAILS MODEL
    // ============================================================

    final SupportTicketDetails ticket =
        SupportTicketDetails.fromJson(
      response,
    );

    selectedTicket = ticket;

    debugPrint(
      'TICKET DETAILS LOADED SUCCESSFULLY',
    );

    debugPrint(
      'TICKET ID: ${ticket.id}',
    );

    debugPrint(
      'CATEGORY: ${ticket.category}',
    );

    debugPrint(
      'SUBJECT: ${ticket.subject}',
    );

    debugPrint(
      'STATUS: ${ticket.status}',
    );

    debugPrint(
      'MESSAGE: ${ticket.message}',
    );

    debugPrint(
      'REPLIES COUNT: ${ticket.replies.length}',
    );

    update();

    return ticket;
  } catch (e, stackTrace) {
    ticketDetailsError = e
        .toString()
        .replaceFirst(
          'Exception: ',
          '',
        );

    selectedTicket = null;

    debugPrint(
      '========== GET SUPPORT TICKET DETAILS ERROR ==========',
    );

    debugPrint(
      'ERROR: $e',
    );

    debugPrintStack(
      stackTrace: stackTrace,
    );

    debugPrint(
      '======================================================',
    );

    return null;
  } finally {
    isTicketDetailsLoading = false;

    update();
  }
}

  Future<void> loadMore() async {
    if (isLoading || isLoadingMore || !hasMore) {
      return;
    }

    await fetchTickets(loadMore: true);
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshTickets() async {
    await fetchTickets(forceRefresh: true);
  }

  // ============================================================
  // RETRY
  // ============================================================

  Future<void> retry() async {
    await fetchTickets(forceRefresh: true);
  }

  // ============================================================
  // CLEAR CREATED TICKET
  // ============================================================

  void clearCreatedTicket() {
    createdTicket = null;

    createError = '';

    update();
  }

  void changeCategory(
  SupportCategory category,
) {
  selectedCategory = category;
  update();
}

void resetCategory() {
  selectedCategory =
      SupportCategory.general;
  update();
}

void clearTicketDetails() {
  selectedTicket = null;
  ticketDetailsError = '';
  isTicketDetailsLoading = false;

  update();
}


}

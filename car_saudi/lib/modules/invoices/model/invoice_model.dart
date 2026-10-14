// ============================================================
// INVOICE MODEL
//
// Mirrors GET /api/invoices response:
// { "data": [ {...invoice} ], "meta": { total, page, limit, totalPages } }
// ============================================================

class InvoiceListResponse {
  final List<Invoice> data;
  final InvoiceMeta meta;

  const InvoiceListResponse({required this.data, required this.meta});

  factory InvoiceListResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawList = json["data"] is List
        ? json["data"] as List<dynamic>
        : <dynamic>[];

    return InvoiceListResponse(
      data: rawList
          .whereType<Map>()
          .map((e) => Invoice.fromJson(e.cast<String, dynamic>()))
          .toList(),
      meta: InvoiceMeta.fromJson(
        json["meta"] is Map
            ? (json["meta"] as Map).cast<String, dynamic>()
            : const <String, dynamic>{},
      ),
    );
  }
}

class InvoiceMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const InvoiceMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory InvoiceMeta.fromJson(Map<String, dynamic> json) {
    return InvoiceMeta(
      total: (json["total"] as num?)?.toInt() ?? 0,
      page: (json["page"] as num?)?.toInt() ?? 1,
      limit: (json["limit"] as num?)?.toInt() ?? 20,
      totalPages: (json["totalPages"] as num?)?.toInt() ?? 1,
    );
  }
}

class Invoice {
  final String id;
  final String invoiceNumber;
  final String type;
  final String status;

  final String billedToId;
  final String billedToName;
  final String? billedToEmail;
  final String? billedToPhone;
  final String? billedToCompany;
  final String? billedToTradeNumber;
  final String? billedToAddress;

  final String description;
  final List<InvoiceLineItem> lineItems;

  final String? referenceId;

  final double subtotal;
  final double vatRate;
  final double vatAmount;
  final double totalAmount;
  final String currency;

  final String? paymentMethod;
  final DateTime? paidAt;

  final String? pdfObjectKey;
  final DateTime? emailedAt;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.type,
    required this.status,
    required this.billedToId,
    required this.billedToName,
    this.billedToEmail,
    this.billedToPhone,
    this.billedToCompany,
    this.billedToTradeNumber,
    this.billedToAddress,
    required this.description,
    required this.lineItems,
    this.referenceId,
    required this.subtotal,
    required this.vatRate,
    required this.vatAmount,
    required this.totalAmount,
    required this.currency,
    this.paymentMethod,
    this.paidAt,
    this.pdfObjectKey,
    this.emailedAt,
    this.createdAt,
    this.updatedAt,
  });

  bool get isPaid => status.toUpperCase() == "PAID";

  factory Invoice.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawItems = json["lineItems"] is List
        ? json["lineItems"] as List<dynamic>
        : <dynamic>[];

    return Invoice(
      id: json["id"]?.toString() ?? "",
      invoiceNumber: json["invoiceNumber"]?.toString() ?? "",
      type: json["type"]?.toString() ?? "",
      status: json["status"]?.toString() ?? "",
      billedToId: json["billedToId"]?.toString() ?? "",
      billedToName: json["billedToName"]?.toString() ?? "",
      billedToEmail: json["billedToEmail"]?.toString(),
      billedToPhone: json["billedToPhone"]?.toString(),
      billedToCompany: json["billedToCompany"]?.toString(),
      billedToTradeNumber: json["billedToTradeNumber"]?.toString(),
      billedToAddress: json["billedToAddress"]?.toString(),
      description: json["description"]?.toString() ?? "",
      lineItems: rawItems
          .whereType<Map>()
          .map((e) => InvoiceLineItem.fromJson(e.cast<String, dynamic>()))
          .toList(),
      referenceId: json["referenceId"]?.toString(),
      subtotal: (json["subtotal"] as num?)?.toDouble() ?? 0,
      vatRate: (json["vatRate"] as num?)?.toDouble() ?? 0,
      vatAmount: (json["vatAmount"] as num?)?.toDouble() ?? 0,
      totalAmount: (json["totalAmount"] as num?)?.toDouble() ?? 0,
      currency: json["currency"]?.toString() ?? "QAR",
      paymentMethod: json["paymentMethod"]?.toString(),
      paidAt: DateTime.tryParse(json["paidAt"]?.toString() ?? ""),
      pdfObjectKey: json["pdfObjectKey"]?.toString(),
      emailedAt: DateTime.tryParse(json["emailedAt"]?.toString() ?? ""),
      createdAt: DateTime.tryParse(json["createdAt"]?.toString() ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"]?.toString() ?? ""),
    );
  }
}

class InvoiceLineItem {
  final String description;
  final num quantity;
  final num unitPrice;
  final num amount;

  const InvoiceLineItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
  });

  factory InvoiceLineItem.fromJson(Map<String, dynamic> json) {
    return InvoiceLineItem(
      description: json["description"]?.toString() ?? "",
      quantity: (json["quantity"] as num?) ?? 0,
      unitPrice: (json["unitPrice"] as num?) ?? 0,
      amount: (json["amount"] as num?) ?? 0,
    );
  }
}

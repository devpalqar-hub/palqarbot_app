import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/network/api_handler.dart';
import 'package:villas_qatar/Core/services/storage_service.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/modules/invoices/model/invoice_model.dart';
import 'package:villas_qatar/modules/invoices/service/invoice_controller.dart';

import 'package:villas_qatar/Core/utils/app_toast.dart';
// ============================================================
// INVOICE DETAIL SCREEN
//
// GET /api/invoices/:id
// ============================================================

class InvoiceDetailScreen extends StatefulWidget {
  const InvoiceDetailScreen({super.key, required this.invoiceId});

  final String invoiceId;

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  late final InvoiceDetailController controller;

  // bool _isDownloadingPdf = false;

  @override
  void initState() {
    super.initState();

    controller = Get.put(InvoiceDetailController(), tag: widget.invoiceId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchInvoice(widget.invoiceId);
    });
  }

  @override
  void dispose() {
    Get.delete<InvoiceDetailController>(tag: widget.invoiceId);
    super.dispose();
  }

  // ============================================================
  // DOWNLOAD PDF
  //
  // FETCHES THE INVOICE PDF, SAVES IT TO A TEMP FILE, THEN OPENS
  // THE SHARE SHEET SO THE USER CAN VIEW / SAVE / SEND IT.
  // ============================================================

  // Future<void> _downloadPdf() async {
  //   if (_isDownloadingPdf) return;

  //   final invoice = controller.invoice;

  //   if (invoice == null) {
  //     debugPrint("❌ Invoice is null");
  //     return;
  //   }

  //   if ((invoice.pdfObjectKey ?? "").isEmpty) {
  //     _showSnack("PDF is not available for this invoice".tr);
  //     return;
  //   }

  //   final String url =
  //       "${ApiHandler.baseUrl}/api/invoices/${invoice.id}/download";

  //   final String? token = StorageService.getToken();

  //   if (token == null || token.isEmpty) {
  //     _showSnack("Please login to download the invoice.".tr);
  //     return;
  //   }

  //   setState(() => _isDownloadingPdf = true);

  //   try {
  //     debugPrint("════════════════════════════════════");
  //     debugPrint("📄 INVOICE PDF DOWNLOAD");
  //     debugPrint("Invoice ID: ${invoice.id}");
  //     debugPrint("Invoice Number: ${invoice.invoiceNumber}");
  //     debugPrint("Request URL: $url");
  //     debugPrint("════════════════════════════════════");

  //     final response = await http.get(
  //       Uri.parse(url),
  //       headers: {
  //         "Authorization": "Bearer $token",
  //         "Accept": "application/pdf",
  //       },
  //     );

  //     debugPrint("📥 INVOICE PDF RESPONSE");
  //     debugPrint("Status Code: ${response.statusCode}");
  //     debugPrint("Content-Type: ${response.headers['content-type']}");
  //     debugPrint("Content-Length: ${response.headers['content-length']}");

  //     if (response.statusCode < 200 || response.statusCode >= 300) {
  //       debugPrint("❌ Invoice PDF request failed");
  //       debugPrint("Response: ${response.body}");
  //       _showSnack("Unable to download invoice PDF".tr);
  //       return;
  //     }

  //     final String contentType = response.headers['content-type'] ?? '';

  //     if (!contentType.contains('application/pdf')) {
  //       debugPrint("⚠️ Server returned non-PDF response");
  //       debugPrint(response.body);
  //       _showSnack("Unable to download invoice PDF".tr);
  //       return;
  //     }

  //     debugPrint("✅ Server returned PDF (${response.bodyBytes.length} bytes)");

  //     final Directory dir = await getTemporaryDirectory();

  //     final String fileName =
  //         "Invoice_${invoice.invoiceNumber.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_')}.pdf";

  //     final File file = File('${dir.path}/$fileName');
  //     await file.writeAsBytes(response.bodyBytes, flush: true);

  //     if (!mounted) return;

  //     await SharePlus.instance.share(
  //       ShareParams(
  //         files: [XFile(file.path, mimeType: 'application/pdf')],
  //         subject: 'Invoice ${invoice.invoiceNumber}',
  //       ),
  //     );
  //   } catch (e, stackTrace) {
  //     debugPrint("❌ Invoice PDF exception: $e");
  //     debugPrint(stackTrace.toString());
  //     _showSnack("Unable to download invoice PDF".tr);
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isDownloadingPdf = false);
  //     }
  //   }
  // }

  void _showSnack(String message) {
    if (!mounted) return;
    AppToast.show(msg: message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Invoice Details".tr,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: _isDownloadingPdf
        //         ? SizedBox(
        //             width: 20.sp,
        //             height: 20.sp,
        //             child: const CircularProgressIndicator(
        //               strokeWidth: 2,
        //               color: AppColors.primary,
        //             ),
        //           )
        //         : const Icon(
        //             Icons.file_download_outlined,
        //             color: AppColors.primary,
        //           ),
        //     onPressed: _isDownloadingPdf ? null : _downloadPdf,
        //   ),
        // ],
      ),
      body: GetBuilder<InvoiceDetailController>(
        tag: widget.invoiceId,
        builder: (controller) {
          if (controller.isLoading && controller.invoice == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error.isNotEmpty && controller.invoice == null) {
            return _ErrorState(
              message: controller.error,
              onRetry: () => controller.fetchInvoice(widget.invoiceId),
            );
          }

          final Invoice? invoice = controller.invoice;
          if (invoice == null) return const SizedBox.shrink();

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => controller.fetchInvoice(widget.invoiceId),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
              children: [
                _TopSummaryCard(invoice: invoice),
                SizedBox(height: 15.h),
                _BilledToAndPaymentCard(invoice: invoice),
                if (invoice.description.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  _SectionCard(
                    icon: Icons.description_outlined,
                    title: "Description".tr,
                    child: Text(
                      invoice.description,
                      style: AppTextStyles.body14,
                    ),
                  ),
                ],
                SizedBox(height: 14.h),
                _LineItemsCard(invoice: invoice),
                SizedBox(height: 14.h),
                _TotalsCard(invoice: invoice),
                SizedBox(height: 14.h),
                _MetaCard(invoice: invoice),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// TOP SUMMARY CARD
// ============================================================
class _TopSummaryCard extends StatelessWidget {
  const _TopSummaryCard({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,##0.00");

    final DateTime? date = invoice.paidAt ?? invoice.createdAt;

    final String dateLabel = date != null
        ? DateFormat("d MMM yyyy, hh:mm a").format(date)
        : "";

    return _CardShell(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ============================================================
          // LEFT — INVOICE INFO
          // ============================================================
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Invoice Number".tr,
                        style: AppTextStyles.body12.copyWith(
                          color: Colors.grey,
                        ),
                      ),

                      SizedBox(height: 3.h),

                      Text(
                        invoice.invoiceNumber,
                        style: AppTextStyles.title14,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 5.h),

                      _StatusChip(status: invoice.status),

                      if (dateLabel.isNotEmpty) ...[
                        SizedBox(height: 8.h),

                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 13.sp,
                              color: Colors.grey,
                            ),

                            SizedBox(width: 6.w),

                            Expanded(
                              child: Text(
                                dateLabel,
                                style: AppTextStyles.body12.copyWith(
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // VERTICAL DIVIDER
          // ============================================================
          Container(
            width: 1,
            height: 72.h,
            margin: EdgeInsets.symmetric(horizontal: 14.w),
            color: AppColors.fieldBorder,
          ),

          // ============================================================
          // RIGHT — TOTAL + TYPE
          // ============================================================
          SizedBox(
            width: 105.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Total Amount".tr,
                  style: AppTextStyles.body12.copyWith(color: Colors.grey),
                ),

                SizedBox(height: 3.h),

                Text(
                  "${invoice.currency.tr} ${formatter.format(invoice.totalAmount)}",
                  style: AppTextStyles.title14.copyWith(
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                if (invoice.type.isNotEmpty) ...[
                  SizedBox(height: 10.h),

                  _TypeChip(type: invoice.type),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// ============================================================
// BILLED TO + PAYMENT INFO
// ============================================================

class _BilledToAndPaymentCard extends StatelessWidget {
  const _BilledToAndPaymentCard({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: EdgeInsets.all(16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  icon: Icons.person_outline,
                  title: "Billed To".tr,
                ),
                SizedBox(height: 10.h),
                Text(
                  invoice.billedToName.isEmpty ? "-" : invoice.billedToName,
                  style: AppTextStyles.body14,
                ),
                SizedBox(height: 8.h),
                _KeyValueRow(
                  icon: Icons.phone_outlined,
                  value: invoice.billedToPhone,
                ),
                _LabeledValue(label: "Email".tr, value: invoice.billedToEmail),
                _LabeledValue(
                  label: "Company".tr,
                  value: invoice.billedToCompany,
                ),
                _LabeledValue(
                  label: "Trade Number".tr,
                  value: invoice.billedToTradeNumber,
                ),
                _LabeledValue(
                  label: "Address".tr,
                  value: invoice.billedToAddress,
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Container(width: 1, height: 190.h, color: AppColors.fieldBorder),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  icon: Icons.credit_card_outlined,
                  title: "Payment Information".tr,
                ),
                SizedBox(height: 10.h),
                _LabeledValue(
                  label: "Payment Method".tr,
                  value: invoice.paymentMethod,
                ),
                _LabeledValue(
                  label: "Paid At".tr,
                  value: invoice.paidAt != null
                      ? DateFormat(
                          "d MMM yyyy, hh:mm a",
                        ).format(invoice.paidAt!)
                      : null,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Status".tr,
                        style: AppTextStyles.body12.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      _StatusChip(status: invoice.status),
                    ],
                  ),
                ),
                _LabeledValue(
                  label: "Emailed At".tr,
                  value: invoice.emailedAt != null
                      ? DateFormat(
                          "d MMM yyyy, hh:mm a",
                        ).format(invoice.emailedAt!)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LINE ITEMS
// ============================================================

class _LineItemsCard extends StatelessWidget {
  const _LineItemsCard({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,##0.00");

    return _CardShell(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
            child: _SectionHeader(
              icon: Icons.list_alt_outlined,
              title: "Line Items".tr,
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(14.r),
              bottomRight: Radius.circular(14.r),
            ),
            child: Column(
              children: [
                Container(
                  color: AppColors.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 10.h,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text("Item".tr, style: _headStyle),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Unit Price".tr,
                          style: _headStyle,
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Qty".tr,
                          style: _headStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Amount".tr,
                          style: _headStyle,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                ...invoice.lineItems.map(
                  (item) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: AppColors.divider)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            item.description,
                            style: AppTextStyles.body13,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "${invoice.currency.tr} ${formatter.format(item.unitPrice)}",
                            style: AppTextStyles.body13,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "${item.quantity}",
                            style: AppTextStyles.body13,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "${invoice.currency.tr} ${formatter.format(item.amount)}",
                            style: AppTextStyles.body13,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static final TextStyle _headStyle = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

// ============================================================
// TOTALS
// ============================================================

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,##0.00");

    return _CardShell(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _totalsRow(
            "Subtotal".tr,
            "${invoice.currency.tr} ${formatter.format(invoice.subtotal)}",
          ),
          SizedBox(height: 10.h),
          _totalsRow(
            "VAT (@rate%)".trParams({
              "rate": invoice.vatRate.toStringAsFixed(0),
            }),
            "${invoice.currency.tr} ${formatter.format(invoice.vatAmount)}",
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          _totalsRow(
            "Total Amount".tr,
            "${invoice.currency.tr} ${formatter.format(invoice.totalAmount)}",
            emphasize: true,
          ),
        ],
      ),
    );
  }

  Widget _totalsRow(String label, String value, {bool emphasize = false}) {
    final TextStyle style = emphasize
        ? AppTextStyles.title16.copyWith(color: AppColors.primary)
        : AppTextStyles.body14;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: emphasize
              ? AppTextStyles.title16.copyWith(color: AppColors.primary)
              : AppTextStyles.body14.copyWith(color: Colors.grey.shade700),
        ),
        Text(value, style: style),
      ],
    );
  }
}

// ============================================================
// META (Reference ID / PDF / Created / Updated)
// ============================================================
class _MetaCard extends StatelessWidget {
  const _MetaCard({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: EdgeInsets.all(16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// LEFT COLUMN
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MetaItem(
                  label: "Reference ID".tr,
                  value: invoice.referenceId,
                  copyable: true,
                ),
                SizedBox(height: 20.h),
                _MetaItem(
                  label: "PDF".tr,
                  value: invoice.pdfObjectKey,
                  copyable: true,
                ),
              ],
            ),
          ),

          /// VERTICAL DIVIDER
          Container(
            width: 1,
            height: 110.h,
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            color: const Color(0xFFE8E8E8),
          ),

          /// RIGHT COLUMN
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MetaItem(
                  label: "Created At".tr,
                  value: invoice.createdAt != null
                      ? DateFormat(
                          "d MMM yyyy, hh:mm a",
                        ).format(invoice.createdAt!)
                      : null,
                ),
                SizedBox(height: 20.h),
                _MetaItem(
                  label: "Updated At".tr,
                  value: invoice.updatedAt != null
                      ? DateFormat(
                          "d MMM yyyy, hh:mm a",
                        ).format(invoice.updatedAt!)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.label,
    required this.value,
    this.copyable = false,
  });

  final String label;
  final String? value;
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF8A8A8A),
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Expanded(
              child: Text(
                value?.isNotEmpty == true ? value! : "—",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF222222),
                  height: 1.h,
                ),
              ),
            ),

            if (copyable && value?.isNotEmpty == true) ...[
              SizedBox(width: 6.w),
              Icon(
                Icons.copy_rounded,
                size: 15.sp,
                color: const Color(0xFF8A8A8A),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
// ============================================================
// SHARED PIECES
// ============================================================

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child, required this.padding});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17.sp, color: AppColors.primary),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11.sp),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(icon: icon, title: title),
          SizedBox(height: 10.h),
          child,
        ],
      ),
    );
  }
}

class _LabeledValue extends StatelessWidget {
  const _LabeledValue({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final String display = (value == null || value!.isEmpty) ? "-" : value!;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.body12.copyWith(color: Colors.grey)),
          SizedBox(width: 10.w),
          Flexible(
            child: Text(
              display,
              style: AppTextStyles.body12,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({required this.icon, required this.value});

  final IconData icon;
  final String? value;

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: Colors.grey),
          SizedBox(width: 6.w),
          Text(value!, style: AppTextStyles.body13),
        ],
      ),
    );
  }
}

class _CopyableValue extends StatelessWidget {
  const _CopyableValue({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final String display = (value == null || value!.isEmpty) ? "-" : value!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.body12.copyWith(color: Colors.grey)),
        SizedBox(height: 4.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                display,
                style: AppTextStyles.body13,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (value != null && value!.isNotEmpty)
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value!));
                  AppToast.show(msg: "Copied to clipboard".tr);
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 6.w),
                  child: Icon(
                    Icons.copy_outlined,
                    size: 15.sp,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final bool paid = status.toUpperCase() == "PAID";

    final Color fg = paid ? AppColors.greenText : AppColors.warning;
    final Color bg = paid
        ? AppColors.greenBg
        : AppColors.warning.withOpacity(.12);

    final String label = paid
        ? "Paid".tr
        : status.isEmpty
        ? "Unknown".tr
        : (status[0].toUpperCase() + status.substring(1).toLowerCase()).tr;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.w),
          Text(
            label.tr,
            style: AppTextStyles.body12.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final String label = type.replaceAll("_", " ");

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.pinkBg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label.tr,
        style: AppTextStyles.body10.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
          fontSize: 9.5.sp,
        ),
      ),
    );
  }
}

// ============================================================
// ERROR STATE
// ============================================================

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: Colors.grey.shade400),
            SizedBox(height: 12.h),
            Text(
              message,
              style: AppTextStyles.body13,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            TextButton(onPressed: onRetry, child: Text("Retry".tr)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/modules/invoices/model/invoice_model.dart';
import 'package:villas_qatar/modules/invoices/service/invoice_controller.dart';
import 'package:villas_qatar/modules/invoices/views/invoice_detail_screen.dart';

class MyInvoicesScreen extends StatefulWidget {
  const MyInvoicesScreen({super.key});

  @override
  State<MyInvoicesScreen> createState() => _MyInvoicesScreenState();
}

class _MyInvoicesScreenState extends State<MyInvoicesScreen> {
  late final InvoiceController controller;
  final TextEditingController _searchTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<InvoiceController>()
        ? Get.find<InvoiceController>()
        : Get.put(InvoiceController(), permanent: true);

    _searchTextController.text = controller.search;

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        controller.fetchInvoices(loadMore: true);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchInvoices();
    });
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    _scrollController.dispose();
    super.dispose();
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
        title: Text(
          "My Invoices".tr,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
      body: GetBuilder<InvoiceController>(
        builder: (controller) {
          if (controller.isLoading && controller.invoices.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: controller.refreshInvoices,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 12.h),
                  sliver: SliverToBoxAdapter(
                    child: _SearchField(
                      controller: _searchTextController,
                      onChanged: controller.applySearch,
                    ),
                  ),
                ),

                if (controller.error.isNotEmpty && controller.invoices.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ErrorState(
                      message: controller.error,
                      onRetry: () => controller.fetchInvoices(),
                    ),
                  )
                else if (controller.invoices.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index == controller.invoices.length) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: Center(
                              child: controller.isLoadingMore
                                  ? const CircularProgressIndicator()
                                  : const SizedBox.shrink(),
                            ),
                          );
                        }

                        final invoice = controller.invoices[index];

                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: _InvoiceCard(invoice: invoice),
                        );
                      }, childCount: controller.invoices.length + 1),
                    ),
                  ),

                SliverToBoxAdapter(child: SizedBox(height: 24.h)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// SUMMARY CARD
// ============================================================

class _InvoiceSummaryCard extends StatelessWidget {
  const _InvoiceSummaryCard({
    required this.total,
    required this.amount,
    required this.currency,
  });

  final int total;
  final double amount;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,##0.00");

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10.w,
            top: -10.h,
            child: Icon(
              Icons.receipt_long_rounded,
              size: 90.sp,
              color: Colors.white.withOpacity(.08),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total Paid".tr,
                style: AppTextStyles.body13.copyWith(
                  color: Colors.white.withOpacity(.85),
                ),
              ),

              SizedBox(height: 8.h),

              Text(
                "${currency.tr} ${formatter.format(amount)}",
                style: AppTextStyles.title18.copyWith(
                  color: Colors.white,
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: 10.h),

              Text(
                total == 1
                    ? "@count Invoice".trParams({"count": "$total"})
                    : "@count Invoices".trParams({"count": "$total"}),
                style: AppTextStyles.body13.copyWith(
                  color: Colors.white.withOpacity(.85),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SEARCH FIELD
// ============================================================

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 18.sp, color: const Color(0xff8E95A4)),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              textAlignVertical: TextAlignVertical.center,
              style: AppTextStyles.body14.copyWith(
                color: const Color(0xff32354A),
              ),
              onChanged: onChanged,
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                hintText: "Search invoices".tr,
                hintStyle: AppTextStyles.body13.copyWith(
                  color: const Color(0xffA5ADBA),
                ),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            InkWell(
              onTap: () {
                controller.clear();
                onChanged("");
              },
              child: Icon(
                Icons.close,
                size: 18.sp,
                color: const Color(0xff8E95A4),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// STATUS TABS — All / Paid only.
// ============================================================

class _StatusTabs extends StatelessWidget {
  const _StatusTabs({required this.selected, required this.onChanged});

  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _tab(context, "All".tr, null)),
        SizedBox(width: 10.w),
        Expanded(child: _tab(context, "Paid".tr, "PAID")),
      ],
    );
  }

  Widget _tab(BuildContext context, String label, String? value) {
    final bool isSelected = selected == value;

    return InkWell(
      borderRadius: BorderRadius.circular(10.r),
      onTap: () => onChanged(value),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.fieldBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body13.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// INVOICE CARD
// ============================================================

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,##0.00");
    final DateTime? date = invoice.paidAt ?? invoice.createdAt;
    final String dateLabel = date != null
        ? DateFormat("d MMM yyyy").format(date)
        : "";

    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: () => Get.to(() => InvoiceDetailScreen(invoiceId: invoice.id)),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.fieldBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10.r),
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
                    invoice.invoiceNumber,
                    style: AppTextStyles.title14,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (dateLabel.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      dateLabel,
                      style: AppTextStyles.body12.copyWith(color: Colors.grey),
                    ),
                  ],

                  if (invoice.description.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      invoice.description,
                      style: AppTextStyles.body12.copyWith(color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(width: 8.w),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${invoice.currency.tr} ${formatter.format(invoice.totalAmount)}",
                  style: AppTextStyles.title14,
                ),
                SizedBox(height: 8.h),
                _StatusChip(status: invoice.status),
              ],
            ),
          ],
        ),
      ),
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
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label.tr,
        style: AppTextStyles.body12.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY / ERROR STATES
// ============================================================

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48.sp,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 12.h),
            Text(
              "No invoices found".tr,
              style: AppTextStyles.title14,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Text(
              "Your invoices will appear here once available".tr,
              style: AppTextStyles.body13.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

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

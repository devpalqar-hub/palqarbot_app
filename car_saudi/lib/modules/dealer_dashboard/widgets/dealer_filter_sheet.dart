import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/theme/app_textstyles.dart';
import 'package:villas_qatar/modules/dealer_dashboard/service/dealer_analytics_controller.dart';

/// Bottom sheet exposing every query param GET
/// /api/dealers/analytics/dashboard accepts — date range, granularity,
/// listing, staff member, type, purpose, status, municipality and area —
/// so the dealer can slice the dashboard the same way the API allows.


Future<void> showDealerFilterSheet(
  BuildContext context,
  DealerAnalyticsController controller,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (_) => _DealerFilterSheet(controller: controller),
  );
}


class _DealerFilterSheet extends StatefulWidget {
  final DealerAnalyticsController controller;
  const _DealerFilterSheet({required this.controller});

  @override
  State<_DealerFilterSheet> createState() => _DealerFilterSheetState();
}

class _DealerFilterSheetState extends State<_DealerFilterSheet> {
  late DateTime _startDate;
  late DateTime _endDate;
  late String _granularity;
  String? _listingId;
  String? _staffUserId;
  String? _typeId;
  String? _purpose;
  String? _status;
  late final TextEditingController _municipalityController;
  late final TextEditingController _areaController;

  static const _granularities = ['daily', 'weekly', 'monthly', 'yearly'];
  static const _purposes = ['SALE', 'RENT'];
  static const _statuses = [
    'PENDING',
    'ACTIVE',
    'INACTIVE',
    'REJECTED',
    'RESUBMITTED',
    'SOLD',
    'PENDING_PAYMENT',
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.controller;
    _startDate = c.startDate;
    _endDate = c.endDate;
    _granularity = c.granularity;
    _listingId = c.listingId;
    _staffUserId = c.staffUserId;
    _typeId = c.typeId;
    _purpose = c.purpose;
    _status = c.status;
    _municipalityController = TextEditingController(
      text: c.municipalityId ?? '',
    );
    _areaController = TextEditingController(text: c.areaName ?? '');
  }

  @override
  void dispose() {
    _municipalityController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }


@override
Widget build(BuildContext context) {
  final data = widget.controller.data;
  final listings = data?.topListings ?? [];
  final staff = data?.overview.staff.members ?? [];

  final types = {
    for (final l in listings)
      if (l.type != null) l.type!.id: l.type!.title,
  };

  return Padding(
    padding: EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom,
    ),
    child: Container(
      // Important:
      // Don't give the sheet a fixed 88% height.
      // It will use only the height it needs until this maximum.
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF8F8),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --------------------------------------------------
          // Drag handle
          // --------------------------------------------------
          SizedBox(height: 9.h),

          Container(
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFD8D1D3),
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),

          SizedBox(height: 12.h),

          // --------------------------------------------------
          // Header
          // --------------------------------------------------
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Filter Analytics".tr,
                    style: AppTextStyles.title18.copyWith(
                      fontSize: 18.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                InkWell(
                  borderRadius: BorderRadius.circular(20.r),
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.border,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.close_rounded,
                      size: 17.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // --------------------------------------------------
          // SCROLLABLE FILTER CONTENT
          // --------------------------------------------------
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                20.w,
                0,
                20.w,
                12.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= DATE =================
                  Text(
                    "Date range".tr,
                    style: AppTextStyles.medium13.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),

                  SizedBox(height: 7.h),

                  Row(
                    children: [
                      Expanded(
                        child: _dateField(
                          label: DateFormat(
                            'MMM d, yyyy',
                          ).format(_startDate),
                          onTap: () => _pickDate(
                            isStart: true,
                          ),
                        ),
                      ),

                      SizedBox(width: 8.w),

                      Expanded(
                        child: _dateField(
                          label: DateFormat(
                            'MMM d, yyyy',
                          ).format(_endDate),
                          onTap: () => _pickDate(
                            isStart: false,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 14.h),

                  // ================= GRANULARITY =================
                  Text(
                    "Granularity".tr,
                    style: AppTextStyles.medium13,
                  ),

                  SizedBox(height: 7.h),

                  Wrap(
                    spacing: 7.w,
                    runSpacing: 7.h,
                    children: _granularities.map((g) {
                      return _chip(
                        label: (g[0].toUpperCase() + g.substring(1)).tr,
                        selected: _granularity == g,
                        onTap: () {
                          setState(() {
                            _granularity = g;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 14.h),

                  // ================= PURPOSE =================
                  Text(
                    "Purpose".tr,
                    style: AppTextStyles.medium13,
                  ),

                  SizedBox(height: 7.h),

                  Wrap(
                    spacing: 7.w,
                    runSpacing: 7.h,
                    children: [
                      _chip(
                        label: "Any".tr,
                        selected: _purpose == null,
                        onTap: () {
                          setState(() {
                            _purpose = null;
                          });
                        },
                      ),

                      ..._purposes.map(
                        (p) => _chip(
                          label: p.tr,
                          selected: _purpose == p,
                          onTap: () {
                            setState(() {
                              _purpose = p;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 14.h),

                  // ================= STATUS =================
                  Text(
                    "Status".tr,
                    style: AppTextStyles.medium13,
                  ),

                  SizedBox(height: 7.h),

                  Wrap(
                    spacing: 7.w,
                    runSpacing: 7.h,
                    children: [
                      _chip(
                        label: "Any".tr,
                        selected: _status == null,
                        onTap: () {
                          setState(() {
                            _status = null;
                          });
                        },
                      ),

                      ..._statuses.map(
                        (s) => _chip(
                          label: s.tr,
                          selected: _status == s,
                          onTap: () {
                            setState(() {
                              _status = s;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  // ================= LISTING =================
                  if (listings.isNotEmpty) ...[
                    SizedBox(height: 14.h),

                    Text(
                      "Listing".tr,
                      style: AppTextStyles.medium13,
                    ),

                    SizedBox(height: 7.h),

                    _dropdown<String?>(
                      value: _listingId,
                      hint: "All listings".tr,
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(
                            "All listings".tr,
                            style: AppTextStyles.body13,
                          ),
                        ),
                        ...listings.map(
                          (l) => DropdownMenuItem<String?>(
                            value: l.id,
                            child: Text(
                              l.propertyName,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body13,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        setState(() {
                          _listingId = v;
                        });
                      },
                    ),
                  ],

                  // ================= STAFF =================
                  if (staff.isNotEmpty) ...[
                    SizedBox(height: 14.h),

                    Text(
                      "Staff member".tr,
                      style: AppTextStyles.medium13,
                    ),

                    SizedBox(height: 7.h),

                    _dropdown<String?>(
                      value: _staffUserId,
                      hint: "All staff".tr,
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(
                            "All staff".tr,
                            style: AppTextStyles.body13,
                          ),
                        ),
                        ...staff.map(
                          (s) => DropdownMenuItem<String?>(
                            value: s.id,
                            child: Text(
                              s.name,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body13,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        setState(() {
                          _staffUserId = v;
                        });
                      },
                    ),
                  ],

                  // ================= PROPERTY TYPE =================
                  if (types.isNotEmpty) ...[
                    SizedBox(height: 14.h),

                    Text(
                      "Property type".tr,
                      style: AppTextStyles.medium13,
                    ),

                    SizedBox(height: 7.h),

                    _dropdown<String?>(
                      value: _typeId,
                      hint: "All types".tr,
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(
                            "All types".tr,
                            style: AppTextStyles.body13,
                          ),
                        ),
                        ...types.entries.map(
                          (e) => DropdownMenuItem<String?>(
                            value: e.key,
                            child: Text(
                              e.value,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body13,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        setState(() {
                          _typeId = v;
                        });
                      },
                    ),
                  ],

                  // ================= AREA =================
                  SizedBox(height: 14.h),

                  Text(
                    "Area name".tr,
                    style: AppTextStyles.medium13,
                  ),

                  SizedBox(height: 7.h),

                  _textField(
                    _areaController,
                    "e.g. Pearl".tr,
                  ),

                  SizedBox(height: 18.h),
                ],
              ),
            ),
          ),

          // --------------------------------------------------
          // FIXED BOTTOM ACTIONS
          // --------------------------------------------------
          Container(
            padding: EdgeInsets.fromLTRB(
              20.w,
              10.h,
              20.w,
              14.h,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF8F8),
              border: Border(
                top: BorderSide(
                  color: AppColors.border.withOpacity(.6),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        widget.controller.resetFilters();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(
                          double.infinity,
                          44.h,
                        ),
                        side: const BorderSide(
                          color: AppColors.primary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        "Reset".tr,
                        style: AppTextStyles.medium14.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 10.w),

                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.controller.applyFilters(
                          startDate: _startDate,
                          endDate: _endDate,
                          granularity: _granularity,

                          listingId: _listingId,
                          clearListingId:
                              _listingId == null,

                          staffUserId: _staffUserId,
                          clearStaffUserId:
                              _staffUserId == null,

                          typeId: _typeId,
                          clearTypeId:
                              _typeId == null,

                          purpose: _purpose,
                          clearPurpose:
                              _purpose == null,

                          status: _status,
                          clearStatus:
                              _status == null,

                          areaName:
                              _areaController.text.trim(),
                          clearAreaName:
                              _areaController.text
                                  .trim()
                                  .isEmpty,
                        );

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: Size(
                          double.infinity,
                          44.h,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        "Apply Filters".tr,
                        style: AppTextStyles.medium14.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
  
    




  Widget _dateField({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 13.sp,
              color: AppColors.primary,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body13,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          style: AppTextStyles.body13.copyWith(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _dropdown<T>({
    required T value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(hint, style: AppTextStyles.body13),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _textField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: AppTextStyles.body13,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body13.copyWith(color: AppColors.textHint),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:quill_html_editor/quill_html_editor.dart';
import 'package:villas_qatar/Core/constants/app_colors.dart';
import 'package:villas_qatar/Core/widgets/primary_button.dart';
import 'package:villas_qatar/modules/home/model/location_repsone_model.dart';
import 'package:villas_qatar/modules/home/service/UtilsController.dart';
import 'package:villas_qatar/modules/home/service/loaction_controller.dart';
import 'package:villas_qatar/modules/mainscreen/mainscreen.dart';
import 'package:villas_qatar/modules/propertylist/model/myproperty_model.dart';
import 'package:villas_qatar/modules/propertylist/service/listproperty_controller.dart';
import 'package:villas_qatar/modules/propertylist/widgets/list_property_widgets.dart';

import 'package:villas_qatar/Core/utils/app_toast.dart';
class ListYourPropertyScreen extends StatefulWidget {
  final Property? property;
  final bool isEdit;
  const ListYourPropertyScreen({super.key, this.property, this.isEdit = false});

  @override
  State<ListYourPropertyScreen> createState() => _ListYourPropertyScreenState();
}

class _ListYourPropertyScreenState extends State<ListYourPropertyScreen> {
  static const int _maxPhotos = 20;

  final ListPropertyController controller = Get.put(ListPropertyController());
  final Utilscontroller utilsController = Get.put(Utilscontroller());
  late final LocationController _location = Get.put(LocationController());
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scroll = ScrollController();

  // Rich-text description editor. `controller.descriptionController`
  // (a plain TextEditingController) stays the single source of truth
  // that submission/review/edit-loading already read and write -
  // this just keeps its `.text` in sync with the Quill editor's HTML
  // output instead of being bound to a plain TextField.
  final QuillEditorController _descriptionQuillController =
      QuillEditorController();
  double _descriptionEditorHeight = 160;

  /// One anchor per validatable field, so a failed "Continue" can scroll
  /// the offending field into view.
  final Map<String, GlobalKey> _anchors = {};

  String _pickedLocationTitle = '';
  bool _detectingLocation = false;
  bool _showAllAmenities = false;
  bool _showAllNearby = false;

  @override
  void initState() {
    super.initState();

    // The controller outlives this screen, so always start from a clean
    // slate — otherwise the previous listing (and its step) reappears.
    controller.resetForm();

    if (widget.isEdit && widget.property != null) {
      controller.loadProperty(widget.property!);
    }

    if (utilsController.listingTypes.isEmpty && !utilsController.isLoading) {
      utilsController.fetchPropertyType();
    }
  }

  @override
  void dispose() {
    _descriptionQuillController.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------
  // VALIDATION HELPERS
  // ---------------------------------------------------------
  GlobalKey _anchor(String name) =>
      _anchors.putIfAbsent(name, () => GlobalKey(debugLabel: name));

  Widget _anchored(String name, Widget child) =>
      KeyedSubtree(key: _anchor(name), child: child);

  bool _err(String name) => controller.errorField == name;

  /// Clears the error outline once the user starts fixing that field.
  void _fixing(String name) {
    if (_err(name)) controller.clearError();
  }

  /// Applies a selection change and clears that field's error in one update.
  void _select(String name, VoidCallback apply) {
    apply();
    if (_err(name)) {
      controller.stepError = null;
      controller.errorField = null;
    }
    controller.update();
  }

  // ---------------------------------------------------------
  // NAVIGATION
  // ---------------------------------------------------------
  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(0);
    });
  }

  void _revealError() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _anchors[controller.errorField]?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          alignment: .15,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _goNext() {
    FocusScope.of(context).unfocus();
    controller.nextStep();

    if (controller.errorField != null) {
      _revealError();
    } else {
      _scrollToTop();
    }
  }

  void _goBack() {
    FocusScope.of(context).unfocus();
    controller.previousStep();
    _scrollToTop();
  }

  void _goToStep(int index) {
    FocusScope.of(context).unfocus();
    controller.goToStep(index);
    _scrollToTop();
  }

  // Prefer a normal pop back to whatever screen pushed this one
  // (usually MyPropertiesScreen, still alive underneath). Using
  // Get.offAll() here unconditionally used to tear down the entire
  // navigation stack - including that still-mounted screen - while
  // a brand new MainScreen was being built at the same time, which
  // could race with in-flight work on the old screen (e.g. a
  // fetchProperties() callback or the search field's controller)
  // and throw "used after being disposed". Only fall back to
  // rebuilding MainScreen when there's genuinely nothing to pop
  // back to (e.g. this screen was opened via a deep link).
  void _goBackOrHome() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      Get.offAll(() => const MainScreen(initialIndex: 2));
    }
  }

  bool get _hasEnteredData =>
      [
        controller.fullNameController,
        controller.phoneController,
        controller.emailController,
        controller.propertyNameController,
        controller.priceController,
        controller.addressController,
      ].any((c) => c.text.trim().isNotEmpty) ||
      controller.images.isNotEmpty ||
      controller.coverImage.isNotEmpty;

  /// Back arrow / system back: step back through the wizard, and only
  /// leave (after confirming, if there's something to lose) from step 1.
  Future<void> _handleBack() async {
    if (controller.currentStep > 0) {
      _goBack();
      return;
    }

    FocusScope.of(context).unfocus();

    if (!widget.isEdit && _hasEnteredData) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Discard listing?'.tr,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Your progress will be lost.'.tr,
            style: const TextStyle(fontSize: 14, color: LpColors.muted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Keep Editing'.tr),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: LpColors.error),
              child: Text('Discard'.tr),
            ),
          ],
        ),
      );

      if (discard != true || !mounted) return;
    }

    _goBackOrHome();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final bool success = widget.isEdit
        ? await controller.updateProperty(widget.property!.id)
        : await controller.addProperty();

    if (success) {
      Get.back(result: true);
    }
  }

  // ---------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: GetBuilder<ListPropertyController>(
          builder: (_) {
            final total = controller.steps.length;
            final step = controller.currentStep;

            return Scaffold(
              backgroundColor: LpColors.pageBg,
              body: Column(
                children: [
                  LpTopBar(
                    title: widget.isEdit
                        ? 'Edit Property'.tr
                        : 'List Your Property'.tr,
                    stepLabel:
                        '${'Step @current of @total'.trParams({'current': '${step + 1}', 'total': '$total'})}'
                        ' · ${controller.steps[step].tr}',
                    currentStep: step,
                    totalSteps: total,
                    onBack: _handleBack,
                    onStepTap: _goToStep,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scroll,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                      child: _stepContent(step),
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: LpBottomBar(
                child: _buildActions(step, total),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _stepContent(int step) {
    switch (step) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      case 3:
        return _buildStep4();
      case 4:
        return _buildStep5();
      case 5:
        return _buildReviewStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildActions(int step, int total) {
    final bool isReview = step == total - 1;

    return Row(
      children: [
        if (step > 0) ...[
          Expanded(
            flex: 2,
            child: LpOutlineButton(
              label: 'Back'.tr,
              height: 50,
              onTap: controller.isSubmitting ? null : _goBack,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: 3,
          child: PrimaryButton(
            height: 50,
            isLoading: controller.isSubmitting,
            title: isReview
                ? (widget.isEdit ? 'Update Property'.tr : 'Submit Property'.tr)
                : 'Continue'.tr,
            suffix: Icon(
              isReview ? Icons.check_rounded : Icons.arrow_forward,
              size: 18,
              color: Colors.white,
            ),
            onTap: isReview ? _submit : _goNext,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // STEP 1 — BASIC INFO
  // ---------------------------------------------------------
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LpStepHeading(
          icon: Icons.person_outline,
          title: 'Property Owner Details'.tr,
          subtitle: 'Enter your details to get started'.tr,
        ),
        const SizedBox(height: 20),

        LpSectionCard(
          icon: Icons.contact_phone_outlined,
          title: 'Contact Details'.tr,
          subtitle: 'Buyers will use these details to reach you'.tr,
          children: [
            _anchored(
              'fullName',
              LpLabeledField(
                label: 'Full Name'.tr,
                required: true,
                child: LpTextField(
                  controller: controller.fullNameController,
                  hint: 'Enter your full name'.tr,
                  prefixIcon: Icons.person_outline,
                  textCapitalization: TextCapitalization.words,
                  hasError: _err('fullName'),
                  onChanged: (_) => _fixing('fullName'),
                ),
              ),
            ),
            const SizedBox(height: 16),

            _anchored(
              'phone',
              LpLabeledField(
                label: 'Contact Number'.tr,
                required: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _CountryCodeDropdown(
                            value: controller.countryCode,
                            enabled: !controller.phoneChecked,
                            onChanged: controller.setCountryCode,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LpTextField(
                              controller: controller.phoneController,
                              hint: 'Enter mobile number'.tr,
                              keyboardType: TextInputType.phone,
                              digitsOnly: true,
                              enabled: !controller.phoneChecked,
                              hasError: _err('phone'),
                              onChanged: (_) => _fixing('phone'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildPhoneVerification(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            LpLabeledField(
              label: 'Email Address'.tr,
              child: LpTextField(
                controller: controller.emailController,
                hint: 'Enter your email'.tr,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _checkPhone() async {
    FocusScope.of(context).unfocus();

    if (controller.phoneController.text.trim().isEmpty) {
      controller.errorField = 'phone';
      controller.update();
      AppToast.show(msg: 'Please enter your contact number'.tr);
      return;
    }

    await controller.checkPhone();
  }

  Widget _changeNumberLink() {
    return TextButton(
      onPressed: controller.resetPhoneVerification,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(0, 32),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        'Change'.tr,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildPhoneVerification() {
    // Not checked yet
    if (!controller.phoneChecked) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          children: [
            const Icon(
              Icons.chat_outlined,
              size: 18,
              color: AppColors.hintGrey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Confirm your number is verified on WhatsApp.'.tr,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.35,
                  color: LpColors.muted,
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 96,
              child: LpOutlineButton(
                label: 'Verify'.tr,
                loading: controller.isLoading,
                onTap: _checkPhone,
              ),
            ),
          ],
        ),
      );
    }

    // Verified
    if (controller.whatsappVerified) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: LpBanner(
          tone: LpBannerTone.success,
          title: 'WhatsApp Verified'.tr,
          message: 'Your contact number has been verified.'.tr,
          action: _changeNumberLink(),
        ),
      );
    }

    // Needs OTP verification
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LpBanner(
            tone: LpBannerTone.warning,
            title: 'Verification Required'.tr,
            message:
                'Verify your WhatsApp number before publishing this property.'
                    .tr,
            action: _changeNumberLink(),
          ),
          const SizedBox(height: 14),

          if (!controller.showOtpField)
            PrimaryButton(
              title: 'Send OTP'.tr,
              height: 46,
              isLoading: controller.isLoading,
              onTap: controller.sendOtp,
            )
          else ...[
            LpFieldLabel('Verification Code'.tr, required: true),
            LpTextField(
              controller: controller.otpController,
              hint: 'Enter 6-digit OTP'.tr,
              prefixIcon: Icons.lock_outline,
              digitsOnly: true,
              maxLength: 6,
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              title: 'Verify Number'.tr,
              height: 46,
              isLoading: controller.isLoading,
              onTap: controller.verifyOtp,
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: controller.sendOtp,
                child: Text('Resend OTP'.tr),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // STEP 2 — PROPERTY DETAILS
  // ---------------------------------------------------------
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LpStepHeading(
          icon: Icons.home_outlined,
          title: 'Property Details'.tr,
          subtitle: 'Tell us about your property'.tr,
        ),
        const SizedBox(height: 20),

        // ---- Property information ----
        LpSectionCard(
          icon: Icons.apartment_outlined,
          title: 'Property Information'.tr,
          children: [
            _anchored(
              'propertyType',
              LpLabeledField(
                label: 'Property Type'.tr,
                required: true,
                child: _buildPropertyTypeChips(),
              ),
            ),
            const SizedBox(height: 16),

            _anchored(
              'purpose',
              LpLabeledField(
                label: 'Property For'.tr,
                required: true,
                child: LpSegmented(
                  hasError: _err('purpose'),
                  selected: controller.propertyPurpose.toUpperCase(),
                  options: [
                    LpSegmentOption(
                      ListPropertyController.purposeSale,
                      'For Sale'.tr,
                      Icons.sell_outlined,
                    ),
                    LpSegmentOption(
                      ListPropertyController.purposeRent,
                      'For Rent'.tr,
                      Icons.key_outlined,
                    ),
                  ],
                  onChanged: (v) =>
                      _select('purpose', () => controller.propertyPurpose = v),
                ),
              ),
            ),
            const SizedBox(height: 16),

            _anchored(
              'propertyName',
              LpLabeledField(
                label: 'Property Name'.tr,
                required: true,
                child: LpTextField(
                  controller: controller.propertyNameController,
                  hint: 'Enter property name'.tr,
                  prefixIcon: Icons.home_outlined,
                  textCapitalization: TextCapitalization.sentences,
                  hasError: _err('propertyName'),
                  onChanged: (_) => _fixing('propertyName'),
                ),
              ),
            ),
          ],
        ),

        // ---- Description ----
        LpSectionCard(
          icon: Icons.notes_rounded,
          title: 'Property Description'.tr,
          required: true,
          subtitle: 'Highlight what makes your property special'.tr,
          children: [_anchored('description', _buildDescriptionEditor())],
        ),

        // ---- Pricing ----
        LpSectionCard(
          icon: Icons.payments_outlined,
          title: 'Pricing'.tr,
          children: [
            _anchored(
              'price',
              LpLabeledField(
                label: 'Price'.tr,
                required: true,
                child: LpTextField(
                  controller: controller.priceController,
                  hint: 'Enter price'.tr,
                  digitsOnly: true,
                  prefix: const _QarPrefix(),
                  suffixText:
                      controller.propertyPurpose.toUpperCase() ==
                          ListPropertyController.purposeRent
                      ? ' / month'.tr
                      : null,
                  hasError: _err('price'),
                  onChanged: (_) => _fixing('price'),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _buildNegotiableRow(),
          ],
        ),

        // ---- Specifications ----
        LpSectionCard(
          icon: Icons.straighten_outlined,
          title: 'Specifications'.tr,
          children: [
            LpFieldRow(
              left: _anchored(
                'bedrooms',
                LpLabeledField(
                  label: 'Bedrooms'.tr,
                  required: true,
                  child: LpTextField(
                    controller: controller.bedroomsController,
                    hint: 'e.g. 4'.tr,
                    digitsOnly: true,
                    maxLength: 2,
                    prefixIcon: Icons.bed_outlined,
                    hasError: _err('bedrooms'),
                    onChanged: (_) => _fixing('bedrooms'),
                  ),
                ),
              ),
              right: _anchored(
                'bathrooms',
                LpLabeledField(
                  label: 'Bathrooms'.tr,
                  required: true,
                  child: LpTextField(
                    controller: controller.bathroomsController,
                    hint: 'e.g. 3'.tr,
                    digitsOnly: true,
                    maxLength: 2,
                    prefixIcon: Icons.bathtub_outlined,
                    hasError: _err('bathrooms'),
                    onChanged: (_) => _fixing('bathrooms'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            LpFieldRow(
              left: LpLabeledField(
                label: 'Living Rooms'.tr,
                child: LpTextField(
                  controller: controller.livingRoomsController,
                  hint: 'e.g. 2'.tr,
                  digitsOnly: true,
                  maxLength: 2,
                  prefixIcon: Icons.weekend_outlined,
                ),
              ),
              right: LpLabeledField(
                label: 'Parking Spaces'.tr,
                child: LpTextField(
                  controller: controller.parkingSpacesController,
                  hint: 'e.g. 2'.tr,
                  digitsOnly: true,
                  maxLength: 2,
                  prefixIcon: Icons.local_parking_outlined,
                ),
              ),
            ),
            const SizedBox(height: 16),

            LpFieldRow(
              left: _anchored(
                'area',
                LpLabeledField(
                  label: 'Area (sqm)'.tr,
                  required: true,
                  child: LpTextField(
                    controller: controller.areaController,
                    hint: 'Enter property area'.tr,
                    decimal: true,
                    prefixIcon: Icons.square_foot_outlined,
                    hasError: _err('area'),
                    onChanged: (_) => _fixing('area'),
                  ),
                ),
              ),
              right: LpLabeledField(
                label: 'Year Built'.tr,
                child: LpTextField(
                  controller: controller.yearBuiltController,
                  hint: 'e.g. 2024'.tr,
                  digitsOnly: true,
                  maxLength: 4,
                  prefixIcon: Icons.calendar_today_outlined,
                ),
              ),
            ),
            const SizedBox(height: 16),

            LpFieldRow(
              left: LpLabeledField(
                label: 'Floor Number'.tr,
                child: LpTextField(
                  controller: controller.floorNumberController,
                  hint: 'e.g. 5'.tr,
                  digitsOnly: true,
                  maxLength: 3,
                  prefixIcon: Icons.layers_outlined,
                ),
              ),
              right: LpLabeledField(
                label: 'Total Floors'.tr,
                child: LpTextField(
                  controller: controller.totalFloorsController,
                  hint: 'e.g. 20'.tr,
                  digitsOnly: true,
                  maxLength: 3,
                  prefixIcon: Icons.apartment_outlined,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPropertyTypeChips() {
    return GetBuilder<Utilscontroller>(
      builder: (utils) {
        if (utils.listingTypes.isEmpty) {
          return utils.isLoading
              ? const _ChipSkeleton()
              : _OptionsUnavailable(
                  message: 'No property types available'.tr,
                  onRetry: utils.fetchPropertyType,
                );
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: utils.listingTypes.map((type) {
            return LpChoiceChip(
              label: type.title,
              selected: controller.selectedTypeId == type.id,
              onTap: () => _select('propertyType', () {
                controller.propertyType = type.title;
                controller.selectedTypeId = type.id;
              }),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildNegotiableRow() {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 6, 8, 6),
      decoration: BoxDecoration(
        color: LpColors.fieldFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LpColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.handshake_outlined,
            size: 20,
            color: AppColors.hintGrey,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price is negotiable'.tr,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: LpColors.ink,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Open to offers from buyers'.tr,
                  style: const TextStyle(fontSize: 12, color: LpColors.muted),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: controller.priceNegotiable,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
            onChanged: controller.setPriceNegotiable,
          ),
        ],
      ),
    );
  }

  // Same package already used to render descriptions read-only
  // elsewhere (Mypropertiesscreen.dart's _DescriptionSheet), so the
  // HTML this produces round-trips cleanly through the rest of the
  // app.
  Widget _buildDescriptionEditor() {
    final hasError = _err('description');

    return Container(
      decoration: BoxDecoration(
        color: LpColors.fieldFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasError ? LpColors.error : LpColors.border,
          width: hasError ? 1.3 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ToolBar(
            controller: _descriptionQuillController,
            toolBarColor: Colors.white,
            iconColor: AppColors.hintGrey,
            activeIconColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            iconSize: 18,
            toolBarConfig: const [
              ToolBarStyle.bold,
              ToolBarStyle.italic,
              ToolBarStyle.underline,
              ToolBarStyle.listBullet,
              ToolBarStyle.listOrdered,
              ToolBarStyle.clean,
            ],
          ),
          const Divider(height: 1, color: LpColors.border),
          Padding(
            padding: const EdgeInsets.all(12),
            child: QuillHtmlEditor(
              controller: _descriptionQuillController,
              hintText: 'Describe your property'.tr,
              minHeight: _descriptionEditorHeight,
              isEnabled: true,
              padding: EdgeInsets.zero,
              hintTextPadding: EdgeInsets.zero,
              backgroundColor: LpColors.fieldFill,
              textStyle: const TextStyle(fontSize: 14, color: LpColors.ink),
              hintTextStyle: const TextStyle(
                color: AppColors.hintGrey,
                fontSize: 14,
              ),
              loadingBuilder: (_) => const SizedBox(
                height: 60,
                child: Center(
                  child: SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              onEditorCreated: () {
                // Returning to this step (or edit mode): the existing HTML
                // is already in descriptionController - push it in now.
                final existing = controller.descriptionController.text;

                if (existing.isNotEmpty) {
                  _descriptionQuillController.setText(existing);
                }
              },
              onTextChanged: (text) {
                controller.descriptionController.text = text;
                _fixing('description');
              },
              onEditorResized: (height) {
                if (mounted && height != _descriptionEditorHeight) {
                  setState(() => _descriptionEditorHeight = height);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // STEP 3 — FEATURES & AMENITIES
  // ---------------------------------------------------------
  Widget _buildStep3() {
    final furnishing = controller.furnishingOptions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LpStepHeading(
          icon: Icons.widgets_outlined,
          title: 'Features & Amenities'.tr,
          subtitle: 'Select the amenities and nearby facilities'.tr,
        ),
        const SizedBox(height: 20),

        LpSectionCard(
          icon: Icons.chair_outlined,
          title: 'Furnishing'.tr,
          children: [
            _optionsBody(
              isEmpty: furnishing.isEmpty,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: furnishing.map((o) {
                  return LpChoiceChip(
                    label: o.title,
                    selected: controller.selectedFurnishing.contains(o.id),
                    onTap: () => controller.toggleFurnishing(o.id),
                  );
                }).toList(),
              ),
            ),
          ],
        ),

        LpSectionCard(
          icon: Icons.widgets_outlined,
          title: 'Amenities'.tr,
          trailing: _selectedBadge(controller.selectedAmenities.length),
          children: [
            _optionsBody(
              isEmpty: controller.amenities.isEmpty,
              child: LpChipWrap(
                expanded: _showAllAmenities,
                onToggle: () =>
                    setState(() => _showAllAmenities = !_showAllAmenities),
                chips: controller.amenities.map((o) {
                  return LpChoiceChip(
                    label: o.title,
                    imageUrl: o.image,
                    selected: controller.selectedAmenities.contains(o.id),
                    onTap: () => controller.toggleAmenity(o.id),
                  );
                }).toList(),
              ),
            ),
          ],
        ),

        LpSectionCard(
          icon: Icons.location_on_outlined,
          title: 'Nearby Places'.tr,
          trailing: _selectedBadge(controller.selectedNearbyTags.length),
          children: [
            _optionsBody(
              isEmpty: controller.nearbyTags.isEmpty,
              child: LpChipWrap(
                expanded: _showAllNearby,
                onToggle: () =>
                    setState(() => _showAllNearby = !_showAllNearby),
                chips: controller.nearbyTags.map((o) {
                  return LpChoiceChip(
                    label: o.title,
                    imageUrl: o.image,
                    selected: controller.selectedNearbyTags.contains(o.id),
                    onTap: () => controller.toggleNearbyTag(o.id),
                  );
                }).toList(),
              ),
            ),
          ],
        ),

        LpSectionCard(
          icon: Icons.tune_outlined,
          title: 'Other Features'.tr,
          subtitle: 'Add any additional features not listed above'.tr,
          children: [
            LpTextField(
              controller: controller.otherFeatureController,
              hint: 'Enter other features'.tr,
              prefixIcon: Icons.edit_note_outlined,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ],
    );
  }

  /// Loading skeleton / retry banner / the options themselves.
  Widget _optionsBody({required bool isEmpty, required Widget child}) {
    if (!isEmpty) return child;

    if (controller.isLoading) return const _ChipSkeleton();

    return _OptionsUnavailable(
      message: "Couldn't load options".tr,
      onRetry: controller.fetchListingOptions,
    );
  }

  Widget _selectedBadge(int count) {
    if (count == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.pinkBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count ${'Selected'.tr}',
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // STEP 4 — LOCATION
  // ---------------------------------------------------------
  void _fillCoordinates(LocationResponse location) {
    controller.latitudeController.text = location.data.latitude.toString();
    controller.longitudeController.text = location.data.longitude.toString();
    controller.addressController.text = location.data.formattedAddress;
    controller.areaNameController.text = location.data.areaName;

    _pickedLocationTitle = location.data.title.isNotEmpty
        ? location.data.title
        : location.data.formattedAddress;

    if (_err('location') || _err('address') || _err('areaName')) {
      controller.stepError = null;
      controller.errorField = null;
    }

    controller.update();
  }

  Future<void> _useCurrentLocation() async {
    if (_detectingLocation) return;

    setState(() => _detectingLocation = true);

    final before = _location.location;
    await _location.detectCurrentLocation();
    final after = _location.location;

    if (mounted) setState(() => _detectingLocation = false);

    // A failed lookup (permission denied, GPS off) leaves the previous,
    // unrelated location in place — only accept a fresh result.
    if (after != null && !identical(after, before)) {
      _fillCoordinates(after);
    }
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LpStepHeading(
          icon: Icons.location_on_outlined,
          title: 'Property Location'.tr,
          subtitle: 'Tell buyers where your property is located'.tr,
        ),
        const SizedBox(height: 20),

        // ---- Pin location ----
        LpSectionCard(
          icon: Icons.my_location_rounded,
          title: 'Pin Location'.tr,
          required: true,
          subtitle:
              'Use your current position or search for the place to fill in the address automatically.'
                  .tr,
          children: [
            Row(
              children: [
                Expanded(
                  child: LpOutlineButton(
                    icon: Icons.my_location_rounded,
                    label: 'Use my location'.tr,
                    loading: _detectingLocation,
                    onTap: _useCurrentLocation,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LpOutlineButton(
                    icon: Icons.search_rounded,
                    label: 'Search'.tr,
                    onTap: _showLocationSheet,
                  ),
                ),
              ],
            ),

            if (_pickedLocationTitle.isNotEmpty) ...[
              const SizedBox(height: 12),
              LpBanner(
                tone: LpBannerTone.success,
                icon: Icons.place_rounded,
                title: _pickedLocationTitle,
              ),
            ],

            const SizedBox(height: 16),

            _anchored(
              'location',
              LpFieldRow(
                left: LpLabeledField(
                  label: 'Latitude'.tr,
                  required: true,
                  child: LpTextField(
                    controller: controller.latitudeController,
                    hint: 'Latitude'.tr,
                    decimal: true,
                    prefixIcon: Icons.my_location,
                    hasError: _err('location'),
                    onChanged: (_) => _fixing('location'),
                  ),
                ),
                right: LpLabeledField(
                  label: 'Longitude'.tr,
                  required: true,
                  child: LpTextField(
                    controller: controller.longitudeController,
                    hint: 'Longitude'.tr,
                    decimal: true,
                    prefixIcon: Icons.explore_outlined,
                    hasError: _err('location'),
                    onChanged: (_) => _fixing('location'),
                  ),
                ),
              ),
            ),
          ],
        ),

        // ---- Address ----
        LpSectionCard(
          icon: Icons.home_work_outlined,
          title: 'Address'.tr,
          children: [
            _anchored(
              'address',
              LpLabeledField(
                label: 'Address Line 1'.tr,
                required: true,
                child: LpTextField(
                  controller: controller.addressController,
                  hint: 'Enter address'.tr,
                  prefixIcon: Icons.location_on_outlined,
                  textCapitalization: TextCapitalization.sentences,
                  hasError: _err('address'),
                  onChanged: (_) => _fixing('address'),
                ),
              ),
            ),
            const SizedBox(height: 16),

            LpLabeledField(
              label: 'Address Line 2'.tr,
              child: LpTextField(
                controller: controller.streetController,
                hint: 'Apartment / Building / Street'.tr,
                prefixIcon: Icons.home_work_outlined,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(height: 16),

            LpFieldRow(
              left: _anchored(
                'areaName',
                LpLabeledField(
                  label: 'Area'.tr,
                  required: true,
                  child: LpTextField(
                    controller: controller.areaNameController,
                    hint: 'Name of Area'.tr,
                    prefixIcon: Icons.map_outlined,
                    textCapitalization: TextCapitalization.words,
                    hasError: _err('areaName'),
                    onChanged: (_) => _fixing('areaName'),
                  ),
                ),
              ),
              right: _anchored(
                'municipality',
                LpLabeledField(
                  label: 'Municipality'.tr,
                  required: true,
                  child: GetBuilder<Utilscontroller>(
                    builder: (utils) {
                      return LpDropdownField(
                        value: controller.cityController.text.isEmpty
                            ? null
                            : controller.cityController.text,
                        hint: 'Select'.tr,
                        icon: Icons.location_city_outlined,
                        hasError: _err('municipality'),
                        items: utils.municipalities.map((e) => e.name).toList(),
                        onChanged: (value) {
                          if (value == null) return;

                          final selected = utils.municipalities.firstWhere(
                            (e) => e.name == value,
                          );

                          _select('municipality', () {
                            controller.cityController.text = selected.name;
                            controller.selectedMunicipalityId = selected.id;
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            LpLabeledField(
              label: 'Landmark'.tr,
              child: LpTextField(
                controller: controller.landmarkController,
                hint: 'Nearby landmark'.tr,
                prefixIcon: Icons.place_outlined,
                textCapitalization: TextCapitalization.words,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showLocationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * .7,
            child: GetBuilder<LocationController>(
              builder: (location) {
                final query = location.searchController.text.trim();

                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Column(
                    children: [
                      Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.fieldBorder,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Search location'.tr,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LpTextField(
                        controller: location.searchController,
                        hint: 'Search location'.tr,
                        prefixIcon: Icons.search_rounded,
                        onChanged: location.onSearchChanged,
                      ),
                      const SizedBox(height: 8),
                      if (location.isLoading)
                        const LinearProgressIndicator(
                          minHeight: 2,
                          color: AppColors.primary,
                          backgroundColor: AppColors.pinkBg,
                        ),
                      Expanded(
                        child: location.results.isEmpty
                            ? Center(
                                child: Text(
                                  query.length >= 2 && !location.isLoading
                                      ? 'No results found'.tr
                                      : '',
                                  style: const TextStyle(
                                    color: LpColors.muted,
                                    fontSize: 13,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: location.results.length,
                                separatorBuilder: (_, _) => const Divider(
                                  height: 1,
                                  color: LpColors.border,
                                ),
                                itemBuilder: (_, index) {
                                  final item = location.results[index];

                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const CircleAvatar(
                                      radius: 18,
                                      backgroundColor: AppColors.pinkBg,
                                      child: Icon(
                                        Icons.location_on_rounded,
                                        size: 18,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    title: Text(
                                      item.data.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    subtitle: Text(
                                      item.data.formattedAddress,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12.5),
                                    ),
                                    onTap: () {
                                      location.selectLocation(item);
                                      _fillCoordinates(item);
                                      Navigator.pop(sheetContext);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------
  // STEP 5 — MEDIA
  // ---------------------------------------------------------
  Widget _buildStep5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LpStepHeading(
          icon: Icons.camera_alt_outlined,
          title: 'Photos & Media'.tr,
          subtitle: 'Add high quality photos to attract more buyers'.tr,
        ),
        const SizedBox(height: 20),

        LpSectionCard(
          icon: Icons.image_outlined,
          title: 'Cover Photo'.tr,
          required: true,
          subtitle: 'This image will be shown first in listings'.tr,
          children: [_anchored('cover', _buildCover())],
        ),

        LpSectionCard(
          icon: Icons.photo_library_outlined,
          title: 'Property Photos'.tr,
          required: true,
          subtitle: 'Upload clear and attractive photos (Max 20 photos)'.tr,
          trailing: Text(
            '${controller.galleryCount}/$_maxPhotos',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: LpColors.muted,
            ),
          ),
          children: [_anchored('photos', _buildGallery())],
        ),

        LpBanner(
          tone: LpBannerTone.success,
          icon: Icons.auto_awesome,
          title: 'Tip: Properties with photos get 10x more interest!'.tr,
          message: 'Use clear, well-lit photos of every room'.tr,
        ),
      ],
    );
  }

  Widget _buildCover() {
    if (!controller.hasCover) {
      return LpUploadBox(
        icon: Icons.image_outlined,
        title: 'Upload Cover Image'.tr,
        subtitle: 'JPG, PNG up to 10MB'.tr,
        height: 170,
        hasError: _err('cover'),
        onTap: _pickCoverImage,
      );
    }

    final Widget image = controller.coverImage.isNotEmpty
        ? Image.file(
            File(controller.coverImage),
            fit: BoxFit.cover,
            cacheWidth: 1000,
          )
        : Image.network(
            controller.existingCover!.url,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: const Color(0xFFEDEAE4),
              child: const Icon(
                Icons.broken_image_outlined,
                color: AppColors.hintGrey,
              ),
            ),
          );

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(14), child: image),
          PositionedDirectional(
            top: 10,
            end: 10,
            child: Row(
              children: [
                LpRoundIconButton(
                  icon: Icons.edit_outlined,
                  tooltip: 'Change'.tr,
                  onTap: _pickCoverImage,
                ),
                const SizedBox(width: 8),
                LpRoundIconButton(
                  icon: Icons.close_rounded,
                  tooltip: 'Remove'.tr,
                  onTap: controller.removeCover,
                ),
              ],
            ),
          ),
          PositionedDirectional(
            start: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Cover'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGallery() {
    final total = controller.galleryCount;

    if (total == 0) {
      return LpUploadBox(
        icon: Icons.add_photo_alternate_outlined,
        title: 'Add Photos'.tr,
        subtitle: 'JPG, PNG up to 10MB each'.tr,
        hasError: _err('photos'),
        onTap: _pickImages,
      );
    }

    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final photo in controller.existingGallery)
          LpPhotoTile(
            networkUrl: photo.url,
            onRemove: () => controller.removeExistingPhoto(photo),
          ),
        for (int i = 0; i < controller.images.length; i++)
          LpPhotoTile(
            filePath: controller.images[i],
            onRemove: () => controller.removeImage(i),
          ),
        if (total < _maxPhotos) LpAddPhotoTile(onTap: _pickImages),
      ],
    );
  }

  Future<void> _pickCoverImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    controller.setCoverImage(image.path);
    _fixing('cover');
  }

  Future<void> _pickImages() async {
    final files = await _picker.pickMultiImage(imageQuality: 80);

    if (files.isEmpty) return;

    final remaining = _maxPhotos - controller.galleryCount;

    if (files.length > remaining) {
      AppToast.show(msg: 'You can add up to 20 photos'.tr);
    }

    for (final image in files.take(remaining)) {
      controller.addImage(image.path);
    }

    _fixing('photos');
  }

  // ---------------------------------------------------------
  // STEP 6 — REVIEW
  // ---------------------------------------------------------
  Widget _buildReviewStep() {
    final c = controller;

    final amenities = c.amenities
        .where((e) => c.selectedAmenities.contains(e.id))
        .map((e) => e.title)
        .toList();
    final nearby = c.nearbyTags
        .where((e) => c.selectedNearbyTags.contains(e.id))
        .map((e) => e.title)
        .toList();
    final furnishing = c.furnishingOptions
        .where((e) => c.selectedFurnishing.contains(e.id))
        .map((e) => e.title)
        .toList();

    final description = _plainDescriptionPreview(c.descriptionController.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LpStepHeading(
          icon: Icons.fact_check_outlined,
          title: 'Review Listing'.tr,
          subtitle: 'Verify all details before submitting'.tr,
        ),
        const SizedBox(height: 20),

        _buildReviewHero(),
        const SizedBox(height: 14),

        LpReviewSection(
          icon: Icons.contact_phone_outlined,
          title: 'Contact Details'.tr,
          onEdit: () => _goToStep(0),
          children: [
            LpReviewRow('Full Name'.tr, c.fullNameController.text),
            LpReviewRow(
              'Phone'.tr,
              '${c.countryCode} ${c.phoneController.text}',
            ),
            _optionalRow('Email'.tr, c.emailController.text),
            LpReviewRow(
              'WhatsApp Verified'.tr,
              c.whatsappVerified ? 'Yes'.tr : 'No'.tr,
            ),
          ],
        ),

        LpReviewSection(
          icon: Icons.apartment_outlined,
          title: 'Property Details'.tr,
          onEdit: () => _goToStep(1),
          children: [
            LpReviewRow('Property Name'.tr, c.propertyNameController.text),
            LpReviewRow('Property Type'.tr, c.propertyType),
            LpReviewRow('Purpose'.tr, _purposeLabel),
            LpReviewRow('Price'.tr, _priceLabel),
            if (c.priceNegotiable)
              LpReviewRow('Price is negotiable'.tr, 'Yes'.tr),
            LpReviewRow('Area'.tr, '${c.areaController.text} sqm'),
            LpReviewRow('Bedrooms'.tr, c.bedroomsController.text),
            LpReviewRow('Bathrooms'.tr, c.bathroomsController.text),
            _optionalRow('Living Rooms'.tr, c.livingRoomsController.text),
            _optionalRow('Parking Spaces'.tr, c.parkingSpacesController.text),
            _optionalRow('Floor Number'.tr, c.floorNumberController.text),
            _optionalRow('Total Floors'.tr, c.totalFloorsController.text),
            _optionalRow('Year Built'.tr, c.yearBuiltController.text),
            if (description.isNotEmpty) ...[
              const Divider(height: 16, color: LpColors.border),
              Text(
                description,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: LpColors.ink,
                ),
              ),
              const SizedBox(height: 6),
            ],
          ],
        ),

        LpReviewSection(
          icon: Icons.widgets_outlined,
          title: 'Features & Amenities'.tr,
          onEdit: () => _goToStep(2),
          children: [
            _reviewChips('Furnishing'.tr, furnishing),
            _reviewChips('Amenities'.tr, amenities),
            _reviewChips('Nearby Places'.tr, nearby),
            _optionalRow('Other Features'.tr, c.otherFeatureController.text),
            if (furnishing.isEmpty &&
                amenities.isEmpty &&
                nearby.isEmpty &&
                c.otherFeatureController.text.trim().isEmpty)
              LpReviewRow('Amenities'.tr, ''),
          ],
        ),

        LpReviewSection(
          icon: Icons.location_on_outlined,
          title: 'Location'.tr,
          onEdit: () => _goToStep(3),
          children: [
            LpReviewRow('Address Line 1'.tr, c.addressController.text),
            _optionalRow('Address Line 2'.tr, c.streetController.text),
            LpReviewRow('Area'.tr, c.areaNameController.text),
            LpReviewRow('Municipality'.tr, c.cityController.text),
            _optionalRow('Landmark'.tr, c.landmarkController.text),
            LpReviewRow(
              'Coordinates'.tr,
              '${c.latitudeController.text}, ${c.longitudeController.text}',
            ),
          ],
        ),

        LpReviewSection(
          icon: Icons.photo_library_outlined,
          title: 'Photos & Media'.tr,
          onEdit: () => _goToStep(4),
          children: [
            LpReviewRow(
              'Total Photos'.tr,
              '${c.galleryCount + (c.hasCover ? 1 : 0)}',
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (c.coverImage.isNotEmpty)
                  _reviewThumb(filePath: c.coverImage, isCover: true)
                else if (c.existingCover != null)
                  _reviewThumb(networkUrl: c.existingCover!.url, isCover: true),
                for (final p in c.existingGallery)
                  _reviewThumb(networkUrl: p.url),
                for (final path in c.images) _reviewThumb(filePath: path),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ],
    );
  }

  String get _purposeLabel {
    switch (controller.propertyPurpose.toUpperCase()) {
      case ListPropertyController.purposeSale:
        return 'For Sale'.tr;
      case ListPropertyController.purposeRent:
        return 'For Rent'.tr;
      default:
        return '';
    }
  }

  String get _priceLabel {
    final value = num.tryParse(controller.priceController.text.trim());
    final formatted = value == null
        ? controller.priceController.text
        : NumberFormat.decimalPattern().format(value);

    final bool isRent =
        controller.propertyPurpose.toUpperCase() ==
        ListPropertyController.purposeRent;

    return '${"QAR".tr} $formatted${isRent ? ' / month'.tr : ''}';
  }

  Widget _buildReviewHero() {
    final c = controller;

    final Widget image = c.coverImage.isNotEmpty
        ? Image.file(File(c.coverImage), fit: BoxFit.cover, cacheWidth: 1000)
        : c.existingCover != null
        ? Image.network(
            c.existingCover!.url,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(color: AppColors.sand),
          )
        : Container(
            color: AppColors.sand,
            child: const Icon(
              Icons.image_outlined,
              size: 40,
              color: AppColors.hintGrey,
            ),
          );

    final place = [
      c.areaNameController.text.trim(),
      c.cityController.text.trim(),
    ].where((e) => e.isNotEmpty).join(', ');

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 200,
        child: Stack(
          fit: StackFit.expand,
          children: [
            image,
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xCC000000)],
                  stops: [.35, 1],
                ),
              ),
            ),
            Positioned.directional(
              textDirection: Directionality.of(context),
              start: 16,
              end: 16,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_purposeLabel.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _purposeLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    c.propertyNameController.text.isEmpty
                        ? '-'
                        : c.propertyNameController.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _priceLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (place.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        place,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionalRow(String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return LpReviewRow(label, value);
  }

  Widget _reviewChips(String label, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: LpColors.muted),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: items
                .map(
                  (t) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.pinkChipBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      t.tr,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _reviewThumb({
    String? filePath,
    String? networkUrl,
    bool isCover = false,
  }) {
    final Widget image = filePath != null
        ? Image.file(File(filePath), fit: BoxFit.cover, cacheWidth: 240)
        : Image.network(
            networkUrl ?? '',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(color: AppColors.sand),
          );

    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(10), child: image),
          if (isCover)
            PositionedDirectional(
              start: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Cover'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Strips the Quill editor's HTML tags for the plain-text preview
  /// shown on the review step - same approach as the read-only
  /// description preview in Mypropertiesscreen.dart.
  String _plainDescriptionPreview(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

// =================================================================
// PRIVATE PIECES
// =================================================================

/// Fixed "QAR" prefix inside the price field. Prices are always sent in
/// QAR, so there's no currency picker to mislead the user.
class _QarPrefix extends StatelessWidget {
  const _QarPrefix();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 14, end: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'QAR'.tr,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 20, color: LpColors.border),
        ],
      ),
    );
  }
}

class _CountryCodeDropdown extends StatelessWidget {
  final String value;
  final bool enabled;
  final ValueChanged<String> onChanged;

  const _CountryCodeDropdown({
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  // ISO code -> dial code, same set (and same flag source, via
  // country_pickers) used by the login screen's country picker.
  static const Map<String, String> _isoByCode = {
    '+974': 'QA',
    '+971': 'AE',
    '+91': 'IN',
    '+1': 'US',
    '+44': 'GB',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 50),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: enabled ? LpColors.fieldFill : const Color(0xFFF1F0F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LpColors.border),
      ),
      alignment: Alignment.center,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _isoByCode.containsKey(value) ? value : _isoByCode.keys.first,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          borderRadius: BorderRadius.circular(12),
          dropdownColor: Colors.white,
          items: _isoByCode.entries
              .map(
                (entry) => DropdownMenuItem(
                  value: entry.key,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 22,
                        height: 15,
                        child: CountryPickerUtils.getDefaultFlagImage(
                          CountryPickerUtils.getCountryByIsoCode(entry.value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Dial codes are always left-to-right ("+974").
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: enabled ? (v) => onChanged(v ?? value) : null,
        ),
      ),
    );
  }
}

/// Grey placeholder chips shown while option lists load.
class _ChipSkeleton extends StatelessWidget {
  const _ChipSkeleton();

  @override
  Widget build(BuildContext context) {
    const widths = [84.0, 110.0, 70.0, 96.0, 78.0, 120.0];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widths
          .map(
            (w) => Container(
              width: w,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F0F2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _OptionsUnavailable extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _OptionsUnavailable({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return LpBanner(
      tone: LpBannerTone.warning,
      title: message,
      action: TextButton(
        onPressed: onRetry,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(0, 32),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'Retry'.tr,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

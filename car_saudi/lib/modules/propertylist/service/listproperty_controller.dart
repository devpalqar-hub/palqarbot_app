import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:villas_qatar/Core/network/api_endpoints.dart';
import 'package:villas_qatar/Core/network/api_handler.dart';
import 'package:villas_qatar/Core/services/storage_service.dart';
import 'package:villas_qatar/modules/propertylist/model/listing_options_model.dart';
import 'package:villas_qatar/modules/propertylist/model/myproperty_model.dart';
import 'package:villas_qatar/modules/propertylist/model/upload_property_model.dart';
import 'package:villas_qatar/modules/propertylist/service/myproperties_listcontroller.dart';

import 'package:villas_qatar/Core/utils/app_toast.dart';
class ListPropertyController extends GetxController {
  //--------------------------------------------------
  // STEP
  //--------------------------------------------------

  int currentStep = 0;

  final List<String> steps = [
    "Basic Info".tr,
    "Details".tr,
    "Features".tr,
    "Location".tr,
    "Media".tr,
    "Review".tr,
  ];

  ListPropertyController() {
    debugPrint("CONTROLLER CREATED");
    debugPrint("Steps = ${steps.length}");
  }
  //--------------------------------------------------
  // LOADING
  //--------------------------------------------------

  bool isLoading = false;
  bool isSubmitting = false;
  bool isUploadingImages = false;
  final List<UploadedPropertyPhoto> uploadedPhotos = [];

  String error = "";

  //--------------------------------------------------
  // OWNER
  //--------------------------------------------------

  final fullNameController = TextEditingController();

  final phoneController = TextEditingController();

  final emailController = TextEditingController();

  final descriptionController = TextEditingController();

  String countryCode = "+974";

  bool whatsappVerified = true;
  String selectedTypeId = "";
  String selectedMunicipalityId = "";
  bool priceNegotiable = false;

  //--------------------------------------------------
  // PROPERTY
  //--------------------------------------------------

  String propertyType = "";

  String propertyPurpose = "";

  String propertyCategory = "";

  final bedroomsController = TextEditingController();

  final bathroomsController = TextEditingController();

  final areaController = TextEditingController();

  final priceController = TextEditingController();

  //--------------------------------------------------
  // LOCATION
  //--------------------------------------------------

  final addressController = TextEditingController();

  final cityController = TextEditingController();

  final areaNameController = TextEditingController();

  final buildingController = TextEditingController();

  final landmarkController = TextEditingController();
  final propertyNameController = TextEditingController();
  final otherFeatureController = TextEditingController();
  final streetController = TextEditingController();
  final livingRoomsController = TextEditingController();

  final parkingSpacesController = TextEditingController();

  final floorNumberController = TextEditingController();

  final totalFloorsController = TextEditingController();
  final yearBuiltController = TextEditingController();
  final latitudeController = TextEditingController();

  final longitudeController = TextEditingController();

  bool showOtpField = false;

  final otpController = TextEditingController();

  double latitude = 0;

  double longitude = 0;

  //--------------------------------------------------
  // OPTIONS FROM API
  //--------------------------------------------------
  List<ListingOptionItem> amenities = [];

  List<ListingOptionItem> nearbyTags = [];

  List<FurnishingOption> furnishingOptions = [];

  final Set<String> selectedAmenities = {};

  final Set<String> selectedNearbyTags = {};

  final Set<String> selectedFurnishing = {};

  //--------------------------------------------------
  // MEDIA
  //--------------------------------------------------

  final List<String> images = [];
  final List<Photo> existingPhotos = [];

  String video = "";
  bool phoneChecked = false;

  //--------------------------------------------------
  // INIT
  //--------------------------------------------------
  //--------------------------------------------------
  // STEP NAVIGATION
  //--------------------------------------------------
  String coverImage = "";

  /// Message for whichever required field is missing on the current
  /// step, set by [validateCurrentStep]. Null once everything's filled.
  String? stepError;

  /// Key of the first invalid field on the current step (see the
  /// `errorField == '...'` checks in the view). Lets the UI outline the
  /// field and scroll to it.
  String? errorField;

  static const String purposeSale = "SALE";
  static const String purposeRent = "RENT";

  bool get hasCover => coverImage.isNotEmpty || existingPhotos.isNotEmpty;

  /// Already-uploaded photo shown in the cover slot (edit mode) while no
  /// new cover has been picked.
  Photo? get existingCover =>
      coverImage.isEmpty && existingPhotos.isNotEmpty
      ? existingPhotos.first
      : null;

  /// Already-uploaded photos that belong in the gallery grid, i.e.
  /// everything except the one occupying the cover slot.
  List<Photo> get existingGallery => coverImage.isEmpty
      ? existingPhotos.skip(1).toList()
      : List<Photo>.from(existingPhotos);

  int get galleryCount => images.length + existingGallery.length;

  void setCoverImage(String path) {
    // Picking a new cover replaces the current (existing) one.
    if (coverImage.isEmpty && existingPhotos.isNotEmpty) {
      existingPhotos.removeAt(0);
    }
    coverImage = path;
    update();
  }

  void removeCover() {
    if (coverImage.isNotEmpty) {
      coverImage = "";
    } else if (existingPhotos.isNotEmpty) {
      existingPhotos.removeAt(0);
    }
    update();
  }

  void removeExistingPhoto(Photo photo) {
    existingPhotos.remove(photo);
    update();
  }

  void setPriceNegotiable(bool value) {
    priceNegotiable = value;
    update();
  }

  String _plainText(String html) =>
      html.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll('&nbsp;', ' ').trim();

  /// Checks the required fields for [currentStep] (mirrors the
  /// `required` markers on each step's fields in the UI) and reports the
  /// first thing that's missing, in on-screen order. Called before
  /// [nextStep] so the wizard can't be advanced past blank required fields.
  bool validateCurrentStep() {
    stepError = null;
    errorField = null;

    void fail(String field, String message) {
      if (stepError != null) return;
      errorField = field;
      stepError = message;
    }

    switch (currentStep) {
      case 0: // Basic Info
        if (fullNameController.text.trim().isEmpty) {
          fail('fullName', "Please enter your full name".tr);
        } else if (phoneController.text.trim().isEmpty) {
          fail('phone', "Please enter your contact number".tr);
        }
        break;

      case 1: // Details
        if (propertyType.isEmpty) {
          fail('propertyType', "Please select a property type".tr);
        } else if (propertyPurpose.isEmpty) {
          fail('purpose', "Please select Sale or Rent".tr);
        } else if (propertyNameController.text.trim().isEmpty) {
          fail('propertyName', "Please enter the property name".tr);
        } else if (_plainText(descriptionController.text).isEmpty) {
          fail('description', "Please enter a property description".tr);
        } else if (priceController.text.trim().isEmpty) {
          fail('price', "Please enter the price".tr);
        } else if (bedroomsController.text.trim().isEmpty) {
          fail('bedrooms', "Please enter the number of bedrooms".tr);
        } else if (bathroomsController.text.trim().isEmpty) {
          fail('bathrooms', "Please enter the number of bathrooms".tr);
        } else if (areaController.text.trim().isEmpty) {
          fail('area', "Please enter the area".tr);
        }
        break;

      case 2: // Features — nothing marked required
        break;

      case 3: // Location
        if (latitudeController.text.trim().isEmpty ||
            longitudeController.text.trim().isEmpty) {
          fail('location', "Please select the property location on the map".tr);
        } else if (addressController.text.trim().isEmpty) {
          fail('address', "Please enter the address".tr);
        } else if (areaNameController.text.trim().isEmpty) {
          fail('areaName', "Please enter the area".tr);
        } else if (selectedMunicipalityId.isEmpty) {
          fail('municipality', "Please select a municipality".tr);
        }
        break;

      case 4: // Media
        if (!hasCover) {
          fail('cover', "Please add a cover image".tr);
        } else if (galleryCount == 0) {
          fail('photos', "Please add at least one property photo".tr);
        }
        break;
    }

    if (stepError != null) {
      AppToast.show(msg: stepError!);
      update();
      return false;
    }

    return true;
  }

  void nextStep() {
    debugPrint("Current Step Before: $currentStep");
    debugPrint("Steps Length: ${steps.length}");

    if (!validateCurrentStep()) {
      debugPrint("Step $currentStep failed validation: $stepError");
      return;
    }

    if (currentStep < steps.length - 1) {
      currentStep++;
      debugPrint("Current Step After: $currentStep");
      update();
    } else {
      debugPrint("Already last step");
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      currentStep--;
      stepError = null;
      errorField = null;
      update();
    }
  }

  void goToStep(int index) {
    currentStep = index;
    stepError = null;
    errorField = null;
    update();
  }

  void clearError() {
    if (errorField == null) return;
    stepError = null;
    errorField = null;
    update();
  }

  //--------------------------------------------------
  // PROPERTY
  //--------------------------------------------------

  void setPropertyType(String value) {
    propertyType = value;
    update();
  }

  void setPropertyPurpose(String value) {
    propertyPurpose = value;
    update();
  }

  void setPropertyCategory(String value) {
    propertyCategory = value;
    update();
  }

  //--------------------------------------------------
  // COUNTRY CODE
  //--------------------------------------------------

  void setCountryCode(String value) {
    countryCode = value;
    update();
  }

  void setWhatsappVerified(bool value) {
    whatsappVerified = value;
    update();
  }

  //--------------------------------------------------
  // LOCATION
  //--------------------------------------------------
  void setLatitude(double value) {
    latitude = value;
    latitudeController.text = value == 0 ? "" : value.toString();
    update();
  }

  void setLongitude(double value) {
    longitude = value;
    longitudeController.text = value == 0 ? "" : value.toString();
    update();
  }
  //--------------------------------------------------
  // MEDIA
  //--------------------------------------------------

  void addImage(String path) {
    images.add(path);
    update();
  }

  void removeImage(int index) {
    images.removeAt(index);
    update();
  }

  void setVideo(String path) {
    video = path;
    update();
  }

  //--------------------------------------------------
  // SAVE DRAFT
  //--------------------------------------------------

  void saveDraft() {
    AppToast.show(
      msg: "Draft saved successfully".tr,
    );
  }

  void toggleAmenity(String id) {
    if (selectedAmenities.contains(id)) {
      selectedAmenities.remove(id);
    } else {
      selectedAmenities.add(id);
    }

    update();
  }

  void toggleNearbyTag(String id) {
    if (selectedNearbyTags.contains(id)) {
      selectedNearbyTags.remove(id);
    } else {
      selectedNearbyTags.add(id);
    }

    update();
  }

  void toggleFurnishing(String id) {
    if (selectedFurnishing.contains(id)) {
      selectedFurnishing.clear();
    } else {
      selectedFurnishing
        ..clear()
        ..add(id);
    }

    update();
  }
  //--------------------------------------------------
  // SUBMIT
  //--------------------------------------------------

  //--------------------------------------------------
  // CLEAR
  //--------------------------------------------------

  /// Puts the wizard back to a blank state. The controller is registered
  /// once and outlives the screen, so this runs every time the screen is
  /// opened — otherwise the previous listing's data (and step) would show
  /// up again. Loaded option lists (amenities etc.) are intentionally kept.
  void resetForm() {
    for (final c in [
      fullNameController,
      phoneController,
      emailController,
      descriptionController,
      propertyNameController,
      bedroomsController,
      bathroomsController,
      livingRoomsController,
      parkingSpacesController,
      areaController,
      priceController,
      yearBuiltController,
      floorNumberController,
      totalFloorsController,
      otherFeatureController,
      addressController,
      streetController,
      cityController,
      areaNameController,
      buildingController,
      landmarkController,
      latitudeController,
      longitudeController,
      otpController,
    ]) {
      c.clear();
    }

    countryCode = "+974";
    phoneChecked = false;
    whatsappVerified = true;
    showOtpField = false;

    propertyType = "";
    selectedTypeId = "";
    propertyPurpose = "";
    propertyCategory = "";
    priceNegotiable = false;
    selectedMunicipalityId = "";

    latitude = 0;
    longitude = 0;

    selectedAmenities.clear();
    selectedNearbyTags.clear();
    selectedFurnishing.clear();

    images.clear();
    coverImage = "";
    existingPhotos.clear();
    video = "";

    currentStep = 0;
    stepError = null;
    errorField = null;

    update();
  }

  /// Lets the user edit the number again after it has been checked.
  void resetPhoneVerification() {
    phoneChecked = false;
    whatsappVerified = true;
    showOtpField = false;
    otpController.clear();
    update();
  }

  /// Coordinates can be typed or filled by GPS/search, both of which only
  /// touch the text controllers — read them back before submitting.
  void _syncCoordinates() {
    latitude = double.tryParse(latitudeController.text.trim()) ?? latitude;
    longitude = double.tryParse(longitudeController.text.trim()) ?? longitude;
  }

  //--------------------------------------------------
  // DISPOSE
  //--------------------------------------------------

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    descriptionController.dispose();

    bedroomsController.dispose();
    bathroomsController.dispose();
    areaController.dispose();
    priceController.dispose();

    addressController.dispose();
    cityController.dispose();
    areaNameController.dispose();
    buildingController.dispose();
    landmarkController.dispose();
    otherFeatureController.dispose();
    streetController.dispose();
    livingRoomsController.dispose();
    parkingSpacesController.dispose();
    floorNumberController.dispose();
    totalFloorsController.dispose();
    yearBuiltController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();

    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();

    fetchListingOptions();
  }

  //--------------------------------------------------
  // API
  //--------------------------------------------------
  Future<void> fetchListingOptions() async {
    try {
      isLoading = true;
      error = "";
      update();

      final response = await ApiHandler.get(ApiEndpoints.listingOptions);

      final model = ListingOptionsModel.fromJson(
        Map<String, dynamic>.from(response),
      );

      amenities = model.amenities;
      nearbyTags = model.nearbyTags;
      furnishingOptions = model.furnishingOptions;

      debugPrint("Amenities: ${amenities.map((e) => e.title).toList()}");

      debugPrint("Nearby Tags: ${nearbyTags.map((e) => e.title).toList()}");

      debugPrint(
        "Furnishing: ${furnishingOptions.map((e) => e.title).toList()}",
      );
    } catch (e, stackTrace) {
      error = e.toString().replaceFirst("Exception: ", "");

      debugPrint("FETCH LISTING OPTIONS ERROR: $e");

      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<bool> addProperty() async {
    if (isSubmitting) {
      return false;
    }

    try {
      isSubmitting = true;
      error = "";
      update();

      final uploadedImageUrls = await uploadAllPropertyImages();

      final expectedImageCount =
          images.length + (coverImage.isNotEmpty ? 1 : 0);

      if (uploadedImageUrls.length != expectedImageCount) {
        throw Exception("Some images could not be uploaded.".tr);
      }
      _syncCoordinates();

      final body = {
        "propertyName": propertyNameController.text.trim(),
        "description": descriptionController.text.trim(),
        "purpose": propertyPurpose,
        "typeId": selectedTypeId.toString(),
        "latitude": latitude,
        "longitude": longitude,
        "bedrooms": int.tryParse(bedroomsController.text.trim()) ?? 0,
        "bathrooms": int.tryParse(bathroomsController.text.trim()) ?? 0,
        "area": double.tryParse(areaController.text.trim()) ?? 0.0,

        "livingRooms": int.tryParse(livingRoomsController.text.trim()) ?? 0,
        "parkingSpaces": int.tryParse(parkingSpacesController.text.trim()) ?? 0,
        "floorNumber": int.tryParse(floorNumberController.text.trim()) ?? 0,
        "totalFloors": int.tryParse(totalFloorsController.text.trim()) ?? 0,
        "yearBuilt": yearBuiltController.text.trim().isEmpty
            ? null
            : int.tryParse(yearBuiltController.text.trim()),

        // String ID
        "furnishingId": selectedFurnishing.isEmpty
            ? null
            : selectedFurnishing.first.toString(),

        "extraProperties": {},

        "price": num.tryParse(priceController.text.trim()) ?? 0,
        "priceNegotiable": priceNegotiable,

        "addressLine1": addressController.text.trim(),
        "addressLine2": streetController.text.trim(),
        "areaName": areaNameController.text.trim(),

        // String ID
        "municipalityId": selectedMunicipalityId.toString(),

        "contactPhone": "$countryCode${phoneController.text.trim()}",
        "contactWhatsapp": "$countryCode${phoneController.text.trim()}",
        "contactVerified": whatsappVerified,

        "amenities": selectedAmenities.toList(),
        "nearbyTags": selectedNearbyTags.toList(),

        "otherFeatures": otherFeatureController.text.trim(),

        "photos": uploadedImageUrls,
      };

      // ==========================================================
      // LOG REQUEST
      // ==========================================================

      debugPrint("==============================================");
      debugPrint("POST URL : ${ApiHandler.baseUrl}${ApiEndpoints.propertyAdd}");
      debugPrint("REQUEST BODY");
      debugPrint(const JsonEncoder.withIndent('  ').convert(body));
      debugPrint("==============================================");

      // ==========================================================
      // API CALL
      // ==========================================================

      final response = await ApiHandler.post(
        ApiEndpoints.propertyAdd,
        body: body,
      );

      // ==========================================================
      // LOG RESPONSE
      // ==========================================================

      debugPrint("============== RESPONSE ==============");

      if (response is Map || response is List) {
        debugPrint(const JsonEncoder.withIndent('  ').convert(response));
      } else {
        debugPrint(response.toString());
      }

      debugPrint("======================================");

      AppToast.show(
        msg: "Property listed successfully.".tr,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      // Refresh "My Properties" list so the newly added property shows
      // up immediately instead of the screen being stuck on its old
      // (stale) state until the app is restarted.
      if (Get.isRegistered<MyPropertyController>()) {
        await Get.find<MyPropertyController>().refreshProperties();
      }

      return true;
    } catch (e, stackTrace) {
      debugPrint("============== ERROR ==============");
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      debugPrint("===================================");

      error = e.toString().replaceFirst("Exception: ", "");

      AppToast.show(
        msg: error,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );

      return false;
    } finally {
      isSubmitting = false;
      update();
    }
  }

  

  Future<String?> uploadPropertyImage(File image) async {
    try {
      final token = StorageService.getToken();

      final request = http.MultipartRequest(
        "POST",
        Uri.parse("${ApiHandler.baseUrl}/api/upload"),
      );

      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      // field name from Swagger = file
      request.files.add(await http.MultipartFile.fromPath("file", image.path));

      debugPrint("========== PROPERTY IMAGE UPLOAD ==========");
      debugPrint("URL: ${request.url}");
      debugPrint("FILE: ${image.path}");

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        return data["url"]?.toString();
      }

      final error = jsonDecode(response.body);

      throw Exception(error["message"] ?? "Image upload failed".tr);
    } catch (e) {
      debugPrint("PROPERTY IMAGE UPLOAD ERROR: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> uploadAllPropertyImages() async {
    final List<Map<String, dynamic>> photos = [];

    /// -------------------------------
    /// Upload Cover Image (sortOrder = 0)
    /// -------------------------------
    if (coverImage.isNotEmpty) {
      final coverUrl = await uploadPropertyImage(File(coverImage));

      if (coverUrl == null || coverUrl.isEmpty) {
        throw Exception("Failed to upload cover image".tr);
      }

      photos.add({"url": coverUrl, "sortOrder": 0, "caption": ""});

      debugPrint("COVER IMAGE UPLOADED: $coverUrl");
    }

    /// -------------------------------
    /// Upload Gallery Images
    /// -------------------------------
    for (int i = 0; i < images.length; i++) {
      final imageUrl = await uploadPropertyImage(File(images[i]));

      if (imageUrl == null || imageUrl.isEmpty) {
        throw Exception("${"Failed to upload image".tr} ${i + 1}");
      }

      photos.add({"url": imageUrl, "sortOrder": i + 1, "caption": ""});

      debugPrint("IMAGE ${i + 1}/${images.length} UPLOADED: $imageUrl");
    }

    return photos;
  }

  Future<bool> updateProperty(
    String listingId) async {
    try {
      isSubmitting = true;
      error = "";
      update();

      // Final photo order: new cover (if one was picked), then the photos
      // already on the listing, then newly added gallery photos. The
      // backend treats sortOrder 0 as the cover, so renumber from 0.
      final hasNewCover = coverImage.isNotEmpty;

      final List<Map<String, dynamic>> uploaded =
          (images.isNotEmpty || hasNewCover)
          ? await uploadAllPropertyImages()
          : <Map<String, dynamic>>[];

      final ordered = <Map<String, dynamic>>[
        if (hasNewCover && uploaded.isNotEmpty) uploaded.first,
        ...existingPhotos.map<Map<String, dynamic>>(
          (e) => <String, dynamic>{"url": e.url, "caption": e.caption},
        ),
        ...uploaded.skip(hasNewCover ? 1 : 0),
      ];

      final photoList = <Map<String, dynamic>>[
        for (int i = 0; i < ordered.length; i++)
          <String, dynamic>{
            "url": ordered[i]["url"],
            "sortOrder": i,
            "caption": ordered[i]["caption"] ?? "",
          },
      ];

      _syncCoordinates();

      final body = {
        "propertyName": propertyNameController.text.trim(),
        "description": descriptionController.text.trim(),
        "purpose": propertyPurpose,
        "typeId": selectedTypeId,

        "latitude": latitude,
        "longitude": longitude,

        "bedrooms": int.tryParse(bedroomsController.text.trim()) ?? 0,
        "bathrooms": int.tryParse(bathroomsController.text.trim()) ?? 0,
        "area": double.tryParse(areaController.text.trim()) ?? 0,

        "livingRooms": int.tryParse(livingRoomsController.text.trim()) ?? 0,
        "parkingSpaces": int.tryParse(parkingSpacesController.text.trim()) ?? 0,
        "floorNumber": int.tryParse(floorNumberController.text.trim()) ?? 0,
        "totalFloors": int.tryParse(totalFloorsController.text.trim()) ?? 0,

        "yearBuilt": yearBuiltController.text.trim().isEmpty
            ? null
            : int.tryParse(yearBuiltController.text.trim()),

        "furnishingId": selectedFurnishing.isEmpty
            ? null
            : selectedFurnishing.first,

        "extraProperties": {},

        "price": num.tryParse(priceController.text.trim()) ?? 0,
        "priceNegotiable": priceNegotiable,

        "addressLine1": addressController.text.trim(),
        "addressLine2": streetController.text.trim(),
        "areaName": areaNameController.text.trim(),
        "municipalityId": selectedMunicipalityId,

        "contactPhone": "$countryCode${phoneController.text.trim()}",
        "contactWhatsapp": "$countryCode${phoneController.text.trim()}",

        "amenities": selectedAmenities.toList(),
        "nearbyTags": selectedNearbyTags.toList(),

        "otherFeatures": otherFeatureController.text.trim(),

        // Existing + newly uploaded photos
        "photos": photoList,
      };

      debugPrint(const JsonEncoder.withIndent("  ").convert(body));
      await ApiHandler.patch("/api/listings/$listingId", body: body);


      if (Get.isRegistered<MyPropertyController>()) {
        await Get.find<MyPropertyController>().refreshProperties();
      }


      return true;
    } catch (e) {
      error = e.toString();

      AppToast.show(msg: error);

      return false;
    } finally {
      isSubmitting = false;
      update();
    }
  }




  /// The API stores the number with its dial code ("+97455..."), while the
  /// form keeps them apart and re-joins them on submit.
  void _applyContactPhone(String full) {
    const knownCodes = ['+974', '+971', '+91', '+44', '+1'];
    final phone = full.trim();

    for (final code in knownCodes) {
      if (phone.startsWith(code)) {
        countryCode = code;
        phoneController.text = phone.substring(code.length);
        return;
      }
    }
    phoneController.text = phone;
  }

  void loadProperty(Property property) {
    // Step 1
    fullNameController.text = property.createdBy.name;
    _applyContactPhone(property.contactPhone);
    emailController.text = property.createdBy.email;
    descriptionController.text = property.description;

    // Step 2
    propertyNameController.text = property.propertyName;

    propertyType = property.type.title;
    selectedTypeId = property.type.id;

    propertyPurpose = property.purpose;

    bedroomsController.text = property.bedrooms.toString();
    bathroomsController.text = property.bathrooms.toString();
    livingRoomsController.text = property.livingRooms.toString();
    parkingSpacesController.text = property.parkingSpaces.toString();

    areaController.text = property.area.toString();
    priceController.text = property.price.toString();

    yearBuiltController.text = property.yearBuilt?.toString() ?? "";

    floorNumberController.text = property.floorNumber.toString();

    totalFloorsController.text = property.totalFloors.toString();

    // Step 3
    selectedFurnishing.clear();
    selectedFurnishing.add(property.furnishing.id);

    selectedAmenities
      ..clear()
      ..addAll(property.amenities.map((e) => e.id));

    selectedNearbyTags
      ..clear()
      ..addAll(property.nearbyTags.map((e) => e.id));

    otherFeatureController.text = property.otherFeatures;

    // Step 4
    addressController.text = property.addressLine1;
    streetController.text = property.addressLine2;
    areaNameController.text = property.areaName;

    cityController.text = property.municipality.name;
    selectedMunicipalityId = property.municipality.id;

    latitudeController.text = property.latitude.toString();
    longitudeController.text = property.longitude.toString();

    latitude = property.latitude;
    longitude = property.longitude;

    priceNegotiable = property.priceNegotiable;
    existingPhotos
      ..clear()
      ..addAll(property.sortedPhotos);
    update();
  }



Future<bool> checkPhone() async {
  try {
    isLoading = true;
    update();

    final response = await ApiHandler.post(
      ApiEndpoints.verifyPhoneCheck,
      body: {
        "phone": "$countryCode${phoneController.text.trim()}",
      },
    );

    whatsappVerified = response["verified"] == true;
    phoneChecked = true;
    showOtpField = false;

    update();
    return true;
  } catch (e) {
    AppToast.show(
      msg: e.toString().replaceFirst("Exception: ", ""),
    );
    return false;
  } finally {
    isLoading = false;
    update();
  }
}

Future<bool> sendOtp() async {
  try {
    isLoading = true;
    update();

    final response = await ApiHandler.post(
      ApiEndpoints.verifyPhoneSendOtp,
      body: {
        "phone": "$countryCode${phoneController.text.trim()}",
      },
    );

    showOtpField = true;

    AppToast.show(
      msg: response["message"] ?? "OTP sent successfully".tr,
    );

    update();
    return true;
  } catch (e) {
    AppToast.show(
      msg: e.toString().replaceFirst("Exception: ", ""),
    );
    return false;
  } finally {
    isLoading = false;
    update();
  }
}

Future<bool> verifyOtp() async {
  try {
    isLoading = true;
    update();

    final response = await ApiHandler.post(
      ApiEndpoints.verifyPhoneVerifyOtp,
      body: {
        "phone": "$countryCode${phoneController.text.trim()}",
        "otp": otpController.text.trim(),
      },
    );

    debugPrint("VERIFY OTP RESPONSE : $response");

    whatsappVerified = true;
    phoneChecked = true;
    showOtpField = false;
    otpController.clear();

    AppToast.show(
      msg: response["message"] ?? "Phone verified successfully".tr,
    );

    update();
    return true;
  } catch (e) {
    AppToast.show(
      msg: e.toString().replaceFirst("Exception: ", ""),
    );
    return false;
  } finally {
    isLoading = false;
    update();
  }
}
}
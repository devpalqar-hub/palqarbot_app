import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:villas_qatar/Core/utils/auth_guard.dart';
import 'package:villas_qatar/modules/chats/views/chatlistscreen.dart';
import 'package:villas_qatar/modules/home/views/home_screen.dart';
import 'package:villas_qatar/modules/propertylist/views/Mypropertiesscreen.dart';
import 'package:villas_qatar/modules/searchscreen/service/searchlist_screen.dart';
import 'package:villas_qatar/modules/searchscreen/view/search_screen.dart';
import 'package:villas_qatar/modules/settings/view/setting_screen.dart';

/// App shell. Home is the only screen that lives here — there is no bottom
/// navigation bar. Every other destination (Search, My Properties, Chats,
/// Profile) opens as a regular pushed screen on top of Home, so the back
/// button always returns to Home.
class MainScreen extends StatefulWidget {
  /// Screen to open on top of Home right after it appears:
  /// 0 = none (just Home), 1 = Search, 2 = My Properties, 3 = Chats,
  /// 4 = Profile.
  final int initialIndex;

  final String? initialSearch;
  final String? initialType;
  final String? initialPurpose;
  final String? initialCategory;

  /// Municipality to pre-filter the search by — used when a popular place
  /// is tapped on Home. Maps to the API's `municipalityId` query parameter.
  final String? initialLocationId;

  const MainScreen({
    super.key,
    this.initialIndex = 0,
    this.initialSearch,
    this.initialType,
    this.initialPurpose,
    this.initialCategory,
    this.initialLocationId,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  PropertySearchController get _searchController =>
      Get.isRegistered<PropertySearchController>()
      ? Get.find<PropertySearchController>()
      : Get.put(PropertySearchController(), permanent: true);

  @override
  void initState() {
    super.initState();

    /// Get or create ONE search controller
    final controller = _searchController;

    /// Apply initial SEARCH if provided
    if (widget.initialSearch != null &&
        widget.initialSearch!.trim().isNotEmpty) {
      controller.filter.search = widget.initialSearch!.trim();

      controller.searchTextController.text = widget.initialSearch!.trim();
    }

    /// Apply initial PROPERTY TYPE if provided
    if (widget.initialType != null && widget.initialType!.trim().isNotEmpty) {
      controller.filter.type = widget.initialType!.trim();
    }

    /// Apply initial BUY / RENT
    if (widget.initialPurpose != null &&
        widget.initialPurpose!.trim().isNotEmpty) {
      controller.filter.purpose = widget.initialPurpose!.trim().toUpperCase();
    }

    /// Apply initial category if needed
    if (widget.initialCategory != null &&
        widget.initialCategory!.trim().isNotEmpty) {
      controller.filter.type = widget.initialCategory!.trim();
    }

    /// Apply initial MUNICIPALITY if provided
    if (widget.initialLocationId != null &&
        widget.initialLocationId!.trim().isNotEmpty) {
      controller.filter.locationId = widget.initialLocationId!.trim();
    }

    /// Opened straight onto another screen (e.g. after listing a property):
    /// show Home first so there is something to go back to, then push it.
    if (widget.initialIndex != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        if (widget.initialIndex == 1) {
          controller.fetchProperties();
        }

        _openScreen(widget.initialIndex);
      });
    }
  }

  void _openScreen(int index) {
    switch (index) {
      case 1:
        Get.to(() => SearchScreen());
        break;
      case 2:
        if (!AuthGuard.requireLogin(
          message: "Please login to manage your properties.".tr,
        )) {
          return;
        }
        Get.to(() => const MyPropertiesScreen());
        break;
      case 3:
        if (!AuthGuard.requireLogin(
          message: "Please login to access your chats.".tr,
        )) {
          return;
        }
        Get.to(() => ChatListScreen());
        break;
      case 4:
        Get.to(() => SettingsScreen());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreen(
      onSearch: _handleHomeSearch,
      onCategorySelected: _handleCategorySearch,
      onPurposeSelected: _handlePurposeSearch,
      onOpenSearch: _handleOpenSearch,
    );
  }

  /// "See all" / popular place: open Search, optionally scoped to a
  /// municipality.
  void _handleOpenSearch({String? locationId}) {
    final controller = _searchController;

    if (locationId != null && locationId.trim().isNotEmpty) {
      controller.filter.locationId = locationId.trim();
    }

    controller.fetchProperties();

    _openScreen(1);
  }

  void _handleCategorySearch(String type) {
    final controller = _searchController;

    // Clear previous property-name search
    controller.filter.search = "";
    controller.searchTextController.clear();

    // Set selected category/type
    controller.filter.type = type;

    controller.update();

    // Fetch filtered properties
    controller.fetchProperties();

    _openScreen(1);
  }

  void _handleHomeSearch(
    String propertyName,
    String purpose, {
    double? latitude,
    double? longitude,
  }) {
    debugPrint("MAIN RECEIVED SEARCH: $propertyName ($purpose)");

    final controller = _searchController;

    controller.searchTextController.text = propertyName;

    // Apply the query and the Rent/Sale toggle together in one fetch,
    // so the Search screen (and its filter chips) opens already matching
    // what was picked on the home banner. Coordinates carry over when the
    // query came from picking a place out of the search autocomplete.
    controller.applyFilters(
      search: propertyName,
      purpose: purpose,
      latitude: latitude,
      longitude: longitude,
    );

    _openScreen(1);
  }

  void _handlePurposeSearch(String purpose) {
    debugPrint("PURPOSE CLICKED: $purpose");

    final controller = _searchController;

    /// Clear previous property-name search
    controller.filter.search = "";
    controller.searchTextController.clear();

    /// Clear previous category
    controller.filter.type = "";

    /// Set BUY or RENT
    /// BUY  = SALE
    /// RENT = RENT
    controller.filter.purpose = purpose;

    /// Rebuild SearchFilterCard
    controller.update();

    /// Fetch filtered properties
    controller.fetchProperties();

    _openScreen(1);
  }
}

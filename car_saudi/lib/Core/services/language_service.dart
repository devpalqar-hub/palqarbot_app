import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageService extends GetxService {
  final Rx<Locale> locale =
      const Locale('en', 'US').obs;

  void changeLanguage(String code) {
    if (code == 'ar') {
      locale.value = const Locale('ar', 'QA');
    } else {
      locale.value = const Locale('en', 'US');
    }

    Get.updateLocale(locale.value);
  }

  bool get isArabic =>
      locale.value.languageCode == 'ar';
}
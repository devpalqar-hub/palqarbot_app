import 'package:get/get.dart';

class AppFonts {
  static const String english = 'Manrope';
  static const String arabic = 'Tajawal';

  static String get currentFont =>
      Get.locale?.languageCode == 'ar' ? arabic : english;
}

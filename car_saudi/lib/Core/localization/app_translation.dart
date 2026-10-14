import 'package:get/get.dart';
import 'package:villas_qatar/Core/localization/ar_QA.dart';
import 'package:villas_qatar/Core/localization/en_US.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'ar_QA': arQA,
      };
}
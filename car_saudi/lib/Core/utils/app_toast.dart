import 'package:flutter/painting.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:villas_qatar/Core/utils/message_localizer.dart';

/// Drop-in replacement for [Fluttertoast.showToast] that runs the message
/// through [MessageLocalizer], so every toast — including errors returned by
/// the server — appears in the selected language.
class AppToast {
  AppToast._();

  static Future<bool?> show({
    required String msg,
    Toast? toastLength,
    int timeInSecForIosWeb = 1,
    double? fontSize,
    String? fontAsset,
    ToastGravity? gravity,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return Fluttertoast.showToast(
      msg: MessageLocalizer.localize(msg),
      toastLength: toastLength,
      timeInSecForIosWeb: timeInSecForIosWeb,
      fontSize: fontSize,
      fontAsset: fontAsset,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }
}

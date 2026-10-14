import 'package:get/get.dart';

import 'package:villas_qatar/Core/localization/ar_QA.dart';

/// Translates free-text messages that arrive from the backend or Firebase
/// (validation errors, "already linked" conflicts, success notes...) so they
/// follow the app language instead of always showing in English.
///
/// Lookup order: exact key in the Arabic map (case/punctuation-insensitive),
/// then generic sentence patterns ("X must be at least N characters"), and
/// finally the original text, so unknown messages are never lost.
class MessageLocalizer {
  MessageLocalizer._();

  static Map<String, String>? _index;

  static bool get _isArabic => (Get.locale?.languageCode ?? '') == 'ar';

  static String _norm(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'^exception:\s*'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(RegExp(r'[.!\s]+$'), '')
      .trim();

  static Map<String, String> _buildIndex() {
    final Map<String, String> map = {};
    arQA.forEach((k, v) => map[_norm(k)] = v);
    return map;
  }

  /// Field names that commonly appear inside validation messages.
  static const Map<String, String> _fields = {
    'name': 'الاسم',
    'full name': 'الاسم الكامل',
    'first name': 'الاسم الأول',
    'last name': 'اسم العائلة',
    'email': 'البريد الإلكتروني',
    'email address': 'البريد الإلكتروني',
    'password': 'كلمة المرور',
    'phone': 'رقم الهاتف',
    'phone number': 'رقم الهاتف',
    'mobile number': 'رقم الجوال',
    'otp': 'رمز التحقق',
    'code': 'الرمز',
    'property name': 'اسم العقار',
    'title': 'العنوان',
    'description': 'الوصف',
    'price': 'السعر',
    'area': 'المساحة',
    'address': 'العنوان',
    'location': 'الموقع',
    'city': 'المدينة',
    'country': 'الدولة',
    'message': 'الرسالة',
    'subject': 'الموضوع',
    'reason': 'السبب',
    'bedrooms': 'عدد غرف النوم',
    'bathrooms': 'عدد الحمامات',
    'photos': 'الصور',
    'images': 'الصور',
    'listing': 'العقار',
    'property': 'العقار',
    'user': 'المستخدم',
    'account': 'الحساب',
    'ticket': 'التذكرة',
    'offer': 'العرض',
    'visit': 'الزيارة',
    'invoice': 'الفاتورة',
    'plan': 'الباقة',
    'dealer': 'الوكيل',
    'token': 'الرمز',
  };

  static String _field(String raw) {
    final String key = raw.trim().toLowerCase();
    return _fields[key] ?? raw.trim();
  }

  static const Map<String, String> _pastVerbs = {
    'verified': 'تم التحقق من',
    'updated': 'تم تحديث',
    'created': 'تم إنشاء',
    'deleted': 'تم حذف',
    'removed': 'تمت إزالة',
    'sent': 'تم إرسال',
    'saved': 'تم حفظ',
    'submitted': 'تم إرسال',
    'added': 'تمت إضافة',
    'cancelled': 'تم إلغاء',
    'canceled': 'تم إلغاء',
  };

  static String? _byPattern(String n) {
    RegExpMatch? m;

    m = RegExp(r'^(.+?) must be at least (\d+) characters?( long)?$').firstMatch(n);
    if (m != null) {
      return '${_field(m[1]!)} يجب ألا يقل عن ${m[2]} أحرف';
    }

    m = RegExp(
      r'^(.+?) must be (?:at most|no more than|less than|under) (\d+) characters?( long)?$',
    ).firstMatch(n);
    if (m != null) {
      return '${_field(m[1]!)} يجب ألا يزيد عن ${m[2]} حرفاً';
    }

    m = RegExp(r'^(.+?) must be exactly (\d+) (?:characters|digits)( long)?$').firstMatch(n);
    if (m != null) {
      return '${_field(m[1]!)} يجب أن يتكون من ${m[2]} أرقام';
    }

    m = RegExp(r'^(.+?) (?:is|are) required$').firstMatch(n);
    if (m != null) return '${_field(m[1]!)} مطلوب';

    m = RegExp(r'^please (?:enter|provide) (?:a |an |your )?(?:valid )?(.+)$').firstMatch(n);
    if (m != null) return 'يرجى إدخال ${_field(m[1]!)} صحيح';

    m = RegExp(r'^(.+?) (?:is|are) invalid$').firstMatch(n) ??
        RegExp(r'^invalid (.+)$').firstMatch(n);
    if (m != null) return '${_field(m[1]!)} غير صالح';

    m = RegExp(r'^(.+?) already exists$').firstMatch(n);
    if (m != null) return '${_field(m[1]!)} موجود بالفعل';

    m = RegExp(r'^(.+?) not found$').firstMatch(n);
    if (m != null) return '${_field(m[1]!)} غير موجود';

    m = RegExp(r'^(.+?) (verified|updated|created|deleted|removed|sent|saved|submitted|added|cancelled|canceled) successfully$')
        .firstMatch(n);
    if (m != null) {
      return '${_pastVerbs[m[2]]!} ${_field(m[1]!)} بنجاح';
    }

    return null;
  }

  /// Returns [raw] in the current app language when a translation is known.
  static String localize(String? raw) {
    if (raw == null) return '';

    String text = raw.replaceFirst(RegExp(r'^Exception:\s*'), '').trim();

    if (!_isArabic || text.isEmpty) return text;

    final String n = _norm(text);

    _index ??= _buildIndex();

    return _index![n] ?? _byPattern(n) ?? text;
  }
}

extension MessageLocalizerX on String {
  /// Localizes a backend / Firebase message for display.
  String get trMsg => MessageLocalizer.localize(this);
}

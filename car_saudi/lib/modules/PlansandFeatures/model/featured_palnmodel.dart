import 'package:get/get.dart';
class FeaturedPlanModel {
  final String id;
  final String name;
  final String location;
  final String duration;
  final int durationDays;
  final num price;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FeaturedPlanModel({
    required this.id,
    required this.name,
    required this.location,
    required this.duration,
    required this.durationDays,
    required this.price,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory FeaturedPlanModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return FeaturedPlanModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      durationDays:
          (json['durationDays'] as num?)?.toInt() ?? 0,
      price: json['price'] as num? ?? 0,
      isActive: json['isActive'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(
              json['createdAt'].toString(),
            )
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(
              json['updatedAt'].toString(),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'duration': duration,
      'durationDays': durationDays,
      'price': price,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// UI helpers

  String get formattedPrice {
    if (price % 1 == 0) {
      return '${'QAR'.tr} ${price.toInt()}';
    }

    return '${'QAR'.tr} ${price.toStringAsFixed(2)}';
  }

  String get formattedDuration {
    if (durationDays == 1) {
      return '1 Day'.tr;
    }

    return '$durationDays ${'Days'.tr}';
  }

  bool get isHomePage {
    return location.toUpperCase() == 'HOME_PAGE';
  }
}
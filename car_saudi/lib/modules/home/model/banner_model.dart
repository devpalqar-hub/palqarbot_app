class BannerModel {
  final String id;
  final String title;
  final String imageUrl;
  final String linkUrl;
  final int position;
  final bool isFeatured;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.linkUrl,
    required this.position,
    required this.isFeatured,
    required this.isActive,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  /// The API serves both photos and videos through [imageUrl]; a video is
  /// recognised by its file extension (query strings are ignored).
  bool get isVideo {
    final String path = (Uri.tryParse(imageUrl.trim())?.path ?? '')
        .toLowerCase();

    return path.endsWith('.mp4') ||
        path.endsWith('.mov') ||
        path.endsWith('.m4v') ||
        path.endsWith('.webm');
  }

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      linkUrl: json['linkUrl']?.toString() ?? '',

      position: json['position'] is int
          ? json['position']
          : int.tryParse(json['position']?.toString() ?? '') ?? 0,

      isFeatured: json['isFeatured'] == true,
      isActive: json['isActive'] == true,

      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,

      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,

      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,

      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'linkUrl': linkUrl,
      'position': position,
      'isFeatured': isFeatured,
      'isActive': isActive,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

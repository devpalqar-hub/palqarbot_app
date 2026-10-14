class UploadedPropertyPhoto {
  final String url;
  final String key;
  final int sortOrder;
  final String caption;

  UploadedPropertyPhoto({
    required this.url,
    required this.key,
    required this.sortOrder,
    this.caption = "",
  });

  Map<String, dynamic> toJson() {
    return {
      "url": url,
      "sortOrder": sortOrder,
      "caption": caption,
    };
  }
}
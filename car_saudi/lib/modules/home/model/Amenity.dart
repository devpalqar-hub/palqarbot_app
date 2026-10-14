class Amenity {
  final String? id;
  final String? title;
  final String? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Amenity({this.id, this.title, this.image, this.createdAt, this.updatedAt});

  factory Amenity.fromJson(Map<String, dynamic> json) {
    return Amenity(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }
}

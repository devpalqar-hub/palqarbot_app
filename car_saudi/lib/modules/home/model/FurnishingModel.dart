class Furnishing {
  final String? id;
  final String? title;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Furnishing({this.id, this.title, this.createdAt, this.updatedAt});

  factory Furnishing.fromJson(Map<String, dynamic> json) {
    return Furnishing(
      id: json['id'],
      title: json['title'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }
}

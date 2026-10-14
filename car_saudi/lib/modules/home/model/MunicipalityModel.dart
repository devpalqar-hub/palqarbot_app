class Municipality {
  final String? id;
  final String? name;
  final String? image;
  final double? latitude;
  final double? longitude;

  Municipality({this.id, this.name, this.image, this.latitude, this.longitude});

  factory Municipality.fromJson(Map<String, dynamic> json) {
    return Municipality(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}

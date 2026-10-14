/// Single entry from GET /api/search/autocomplete?q=... — either a place
/// (with coordinates) or an existing property (with a slug to open directly).
enum AutocompleteResultType { place, property }

class AutocompleteResult {
  final AutocompleteResultType type;
  final String name;
  final double? latitude;
  final double? longitude;
  final String? slug;

  const AutocompleteResult({
    required this.type,
    required this.name,
    this.latitude,
    this.longitude,
    this.slug,
  });

  factory AutocompleteResult.fromJson(Map<String, dynamic> json) {
    if (json['type']?.toString() == 'property') {
      return AutocompleteResult(
        type: AutocompleteResultType.property,
        name: json['propertyName']?.toString() ?? '',
        slug: json['slug']?.toString(),
      );
    }

    final location = json['location'];
    final Map<String, dynamic>? locationMap = location is Map
        ? Map<String, dynamic>.from(location)
        : null;

    return AutocompleteResult(
      type: AutocompleteResultType.place,
      name: json['name']?.toString() ?? '',
      latitude: (locationMap?['latitude'] as num?)?.toDouble(),
      longitude: (locationMap?['longitude'] as num?)?.toDouble(),
    );
  }
}

import 'package:latlong2/latlong.dart';

/// Model class representing a campus building with its location and information
class CampusBuilding {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String description;
  final String icon;

  CampusBuilding({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.description,
    required this.icon,
  });

  /// Create a CampusBuilding from JSON
  factory CampusBuilding.fromJson(String id, Map<String, dynamic> json) {
    return CampusBuilding(
      id: id,
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      description: json['description'] as String,
      icon: json['icon'] as String,
    );
  }

  /// Convert to LatLng for flutter_map
  LatLng toLatLng() {
    return LatLng(lat, lng);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lng': lng,
      'description': description,
      'icon': icon,
    };
  }

  @override
  String toString() {
    return 'CampusBuilding(id: $id, name: $name, location: ($lat, $lng))';
  }
}

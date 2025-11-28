import 'package:latlong2/latlong.dart';

//model class representing a campus building with its location and information
class CampusBuilding {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String description;
  final String icon;
  final double height; // Building height in meters for 3D effects

  CampusBuilding({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.description,
    required this.icon,
    this.height = 15.0, // Default height ~4 floors
  });

  //create a campus building from json
  factory CampusBuilding.fromJson(String id, Map<String, dynamic> json) {
    return CampusBuilding(
      id: id,
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      description: json['description'] as String,
      icon: json['icon'] as String,
      height: json['height'] != null
          ? (json['height'] as num).toDouble()
          : 15.0,
    );
  }

  //convert to latlng for flutter_map
  LatLng toLatLng() {
    return LatLng(lat, lng);
  }

  //convert to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lng': lng,
      'description': description,
      'icon': icon,
      'height': height,
    };
  }

  @override
  String toString() {
    return 'CampusBuilding(id: $id, name: $name, location: ($lat, $lng), height: ${height}m)';
  }
}

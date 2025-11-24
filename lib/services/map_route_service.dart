import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/campus_building.dart';
import '../models/map_config.dart';

//service for managing routes and navigation between buildings
class MapRouteService {
  //generate a simple straight-line route between two buildings
  //this is used as a fallback or for quick preview
  List<LatLng> generateRoute(CampusBuilding from, CampusBuilding to) {
    return [from.toLatLng(), to.toLatLng()];
  }

  //fetch a realistic walking route using OSRM API
  Future<List<LatLng>> fetchRoute(
    CampusBuilding from,
    CampusBuilding to,
  ) async {
    try {
      final start = from.toLatLng();
      final end = to.toLatLng();

      //OSRM Public API (Walking profile)
      final url = Uri.parse(
        'http://router.project-osrm.org/route/v1/foot/'
        '${start.longitude},${start.latitude};'
        '${end.longitude},${end.latitude}'
        '?overview=full&geometries=geojson',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          final geometry = data['routes'][0]['geometry'];
          final coordinates = geometry['coordinates'] as List;

          return coordinates.map((coord) {
            //GeoJSON is [lng, lat]
            return LatLng(
              (coord[1] as num).toDouble(),
              (coord[0] as num).toDouble(),
            );
          }).toList();
        }
      }

      //fallback to straight line if API fails or no route found
      return generateRoute(from, to);
    } catch (e) {
      //fallback on error
      return generateRoute(from, to);
    }
  }

  //calculate estimated walking time in minutes
  int calculateWalkingTime(CampusBuilding from, CampusBuilding to) {
    const Distance distance = Distance();
    final meters = distance.as(
      LengthUnit.Meter,
      from.toLatLng(),
      to.toLatLng(),
    );

    const walkingSpeedMetersPerMinute = 83.33;
    final minutes = (meters / walkingSpeedMetersPerMinute).ceil();

    return minutes < 1 ? 1 : minutes;
  }

  //format distance for display
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  //route color
  int getRouteColor() {
    return MapConfig.routeColorValue;
  }

  //route stroke width
  double getRouteStrokeWidth() {
    return MapConfig.routeStrokeWidth;
  }

  //generate route directions text
  String generateDirections(CampusBuilding from, CampusBuilding to) {
    const Distance distance = Distance();
    final meters = distance.as(
      LengthUnit.Meter,
      from.toLatLng(),
      to.toLatLng(),
    );
    final walkingTime = calculateWalkingTime(from, to);

    return 'Walk from ${from.name} to ${to.name}\n'
        'Distance: ${formatDistance(meters)}\n'
        'Estimated time: $walkingTime min';
  }
}

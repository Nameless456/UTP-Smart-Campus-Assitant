import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import '../models/campus_building.dart';

/// Service to manage campus map data and building information
class CampusMapService {
  static final CampusMapService _instance = CampusMapService._internal();
  factory CampusMapService() => _instance;
  CampusMapService._internal();

  Map<String, CampusBuilding>? _buildings;

  /// Load buildings from JSON asset
  Future<void> loadBuildings() async {
    if (_buildings != null) return; // Already loaded

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/buildings.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      _buildings = {};
      jsonData.forEach((key, value) {
        _buildings![key] = CampusBuilding.fromJson(
          key,
          value as Map<String, dynamic>,
        );
      });
    } catch (e) {
      throw Exception('Failed to load buildings data: $e');
    }
  }

  /// Get all buildings
  List<CampusBuilding> getAllBuildings() {
    if (_buildings == null) {
      throw Exception('Buildings not loaded. Call loadBuildings() first.');
    }
    return _buildings!.values.toList();
  }

  /// Find building by ID
  CampusBuilding? findBuildingById(String id) {
    if (_buildings == null) return null;
    return _buildings![id];
  }

  /// Find building by name (case insensitive)
  CampusBuilding? findBuildingByName(String name) {
    if (_buildings == null) return null;

    final lowercaseName = name.toLowerCase();

    // Try exact match first
    for (var building in _buildings!.values) {
      if (building.name.toLowerCase() == lowercaseName) {
        return building;
      }
    }

    // Try partial match
    for (var building in _buildings!.values) {
      if (building.name.toLowerCase().contains(lowercaseName)) {
        return building;
      }
    }

    return null;
  }

  /// Calculate distance between two buildings (in meters)
  double calculateDistance(CampusBuilding from, CampusBuilding to) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Meter, from.toLatLng(), to.toLatLng());
  }

  /// Get nearest building to a location
  CampusBuilding? getNearestBuilding(LatLng location) {
    if (_buildings == null || _buildings!.isEmpty) return null;

    const Distance distance = Distance();
    CampusBuilding? nearest;
    double minDistance = double.infinity;

    for (var building in _buildings!.values) {
      final dist = distance.as(LengthUnit.Meter, location, building.toLatLng());
      if (dist < minDistance) {
        minDistance = dist;
        nearest = building;
      }
    }

    return nearest;
  }

  /// Search buildings by query
  List<CampusBuilding> searchBuildings(String query) {
    if (_buildings == null) return [];

    final lowercaseQuery = query.toLowerCase();

    return _buildings!.values.where((building) {
      return building.name.toLowerCase().contains(lowercaseQuery) ||
          building.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}

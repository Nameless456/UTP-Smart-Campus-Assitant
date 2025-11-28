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

  //Find building by name (case insensitive) with fuzzy matching
  CampusBuilding? findBuildingByName(String name) {
    if (_buildings == null) return null;

    final lowercaseName = name.toLowerCase();

    // 1. Try exact match
    for (var building in _buildings!.values) {
      if (building.name.toLowerCase() == lowercaseName) {
        return building;
      }
    }

    // 2. Try partial match
    for (var building in _buildings!.values) {
      if (building.name.toLowerCase().contains(lowercaseName)) {
        return building;
      }
    }

    // 3. Try fuzzy match (Levenshtein distance)
    CampusBuilding? bestMatch;
    int minDistance = 1000; // Start with a high number

    for (var building in _buildings!.values) {
      final distance = _levenshtein(building.name.toLowerCase(), lowercaseName);

      // Threshold: Allow up to 3 typos or 40% of the string length
      final threshold = (building.name.length * 0.4).ceil().clamp(3, 10);

      if (distance <= threshold && distance < minDistance) {
        minDistance = distance;
        bestMatch = building;
      }
    }

    return bestMatch;
  }

  /// Calculate Levenshtein distance between two strings
  int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.filled(t.length + 1, 0);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < t.length + 1; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = [
          v1[j] + 1,
          v0[j + 1] + 1,
          v0[j] + cost,
        ].reduce((curr, next) => curr < next ? curr : next);
      }

      for (int j = 0; j < t.length + 1; j++) {
        v0[j] = v1[j];
      }
    }

    return v1[t.length];
  }

  // Calculate distance between two buildings (in meters)
  double calculateDistance(CampusBuilding from, CampusBuilding to) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Meter, from.toLatLng(), to.toLatLng());
  }

  // Get nearest building to a location
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

  // Search buildings by query
  List<CampusBuilding> searchBuildings(String query) {
    if (_buildings == null) return [];

    final lowercaseQuery = query.toLowerCase();

    return _buildings!.values.where((building) {
      return building.name.toLowerCase().contains(lowercaseQuery) ||
          building.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}

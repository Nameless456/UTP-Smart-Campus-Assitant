import 'package:flutter/material.dart';
import '../models/campus_building.dart';
import '../screens/campus_map_screen.dart';
import 'campus_map_service.dart';

/// Service to handle map navigation commands from chatbot
class MapNavigationService {
  final CampusMapService _mapService = CampusMapService();

  /// Parse navigation command and navigate to the building(s)
  /// Supports both single destination and from-to navigation
  Future<bool> handleNavigationCommand(
    BuildContext context,
    String command,
  ) async {
    // Ensure buildings are loaded
    await _mapService.loadBuildings();

    // Try to extract from-to navigation first
    final fromTo = _extractFromToBuildings(command);

    if (fromTo != null) {
      // Two-point navigation
      final fromBuilding = _mapService.findBuildingByName(fromTo['from']!);
      final toBuilding = _mapService.findBuildingByName(fromTo['to']!);

      if (fromBuilding != null && toBuilding != null) {
        // Navigate to map screen with route
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CampusMapScreen(
                initialBuilding: toBuilding,
                fromBuilding: fromBuilding,
              ),
            ),
          );
          return true;
        }
      }
      return false;
    }

    // Single destination navigation (original behavior)
    final buildingName = _extractBuildingName(command);
    if (buildingName == null) return false;

    final building = _mapService.findBuildingByName(buildingName);
    if (building == null) return false;

    // Navigate to map screen with the building
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CampusMapScreen(initialBuilding: building),
        ),
      );
      return true;
    }

    return false;
  }

  /// Extract from-to buildings from natural language command
  /// Returns a map with 'from' and 'to' keys, or null if not a from-to command
  Map<String, String>? _extractFromToBuildings(String command) {
    final lowercaseCommand = command.toLowerCase();

    // Patterns for from-to navigation
    final patterns = [
      // "from X to Y"
      RegExp(
        r'(?:from|starting from)\s+(?:the\s+)?(.+?)\s+(?:to|until|till)\s+(?:the\s+)?(.+)',
        caseSensitive: false,
      ),
      // "navigate/go from X to Y"
      RegExp(
        r'(?:navigate|go|take me|directions)\s+from\s+(?:the\s+)?(.+?)\s+to\s+(?:the\s+)?(.+)',
        caseSensitive: false,
      ),
      // "how to get from X to Y"
      RegExp(
        r'how\s+(?:do i|to)\s+get\s+from\s+(?:the\s+)?(.+?)\s+to\s+(?:the\s+)?(.+)',
        caseSensitive: false,
      ),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(lowercaseCommand);
      if (match != null && match.groupCount >= 2) {
        final from = match.group(1)?.trim();
        final to = match.group(2)?.trim();

        if (from != null && to != null && from.isNotEmpty && to.isNotEmpty) {
          return {'from': from, 'to': to};
        }
      }
    }

    return null;
  }

  /// Extract building name from natural language command
  String? _extractBuildingName(String command) {
    final lowercaseCommand = command.toLowerCase();

    // Common patterns for navigation commands
    final patterns = [
      RegExp(
        r'(?:navigate|go|take me|bring me|show|find|where is|locate)(?: to| me to)?\s+(?:the\s+)?(.+)',
        caseSensitive: false,
      ),
      RegExp(
        r'(?:how do i get to|directions to)\s+(?:the\s+)?(.+)',
        caseSensitive: false,
      ),
      RegExp(r'^(.+?)(?:\s+location|\s+building)?$', caseSensitive: false),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(lowercaseCommand);
      if (match != null && match.groupCount >= 1) {
        return match.group(1)?.trim();
      }
    }

    return command.trim();
  }

  /// Check if a message contains a navigation request
  bool isNavigationRequest(String message) {
    final lowercaseMessage = message.toLowerCase();

    final navigationKeywords = [
      'navigate',
      'go to',
      'take me',
      'bring me',
      'show',
      'where is',
      'how to get',
      'directions',
      'locate',
      'find',
      'location',
    ];

    return navigationKeywords.any(
      (keyword) => lowercaseMessage.contains(keyword),
    );
  }

  /// Get suggested buildings based on partial input
  Future<List<CampusBuilding>> getSuggestions(String query) async {
    await _mapService.loadBuildings();
    return _mapService.searchBuildings(query);
  }

  /// Get navigation response text with distance information
  /// This can be used to provide feedback in the chat
  Future<String?> getNavigationResponse(String command) async {
    await _mapService.loadBuildings();

    // Try from-to navigation first
    final fromTo = _extractFromToBuildings(command);

    if (fromTo != null) {
      final fromBuilding = _mapService.findBuildingByName(fromTo['from']!);
      final toBuilding = _mapService.findBuildingByName(fromTo['to']!);

      if (fromBuilding != null && toBuilding != null) {
        final distance = _mapService.calculateDistance(
          fromBuilding,
          toBuilding,
        );
        final walkingTime = _calculateWalkingTime(distance);
        final distanceText = _formatDistance(distance);

        return '📍 Navigation from **${fromBuilding.name}** to **${toBuilding.name}**\n\n'
            '📏 Distance: $distanceText\n'
            '⏱️ Walking time: ~$walkingTime min\n\n'
            'Opening map with route...';
      }
      return 'Sorry, I couldn\'t find one or both of those buildings.';
    }

    // Single destination
    final buildingName = _extractBuildingName(command);
    if (buildingName != null) {
      final building = _mapService.findBuildingByName(buildingName);
      if (building != null) {
        return '📍 Navigating to **${building.name}**\n\n'
            '${building.description}\n\n'
            'Opening map...';
      }
      return 'Sorry, I couldn\'t find "$buildingName" on campus.';
    }

    return null;
  }

  /// Calculate walking time in minutes (5 km/h average speed)
  int _calculateWalkingTime(double meters) {
    const walkingSpeedMetersPerMinute = 83.33; // 5 km/h
    final minutes = (meters / walkingSpeedMetersPerMinute).ceil();
    return minutes < 1 ? 1 : minutes;
  }

  /// Format distance for display
  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }
}

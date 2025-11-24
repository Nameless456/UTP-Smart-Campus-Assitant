import 'package:flutter/material.dart';
import '../models/campus_building.dart';

/// Custom marker widget for campus buildings
class BuildingMarker extends StatelessWidget {
  final CampusBuilding building;
  final bool isSelected;
  final VoidCallback? onTap;

  const BuildingMarker({
    super.key,
    required this.building,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Colors.green : Colors.red;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Building name label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              building.name,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          // Marker pin
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.location_on,
              color: color,
              size: isSelected ? 48 : 40,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/campus_building.dart';
import '../models/map_config.dart';
import 'building_marker.dart';

/// Reusable campus map widget (light mode only)
class CampusMapWidget extends StatefulWidget {
  final CampusBuilding? highlightedBuilding;
  final List<CampusBuilding> buildings;
  final List<LatLng>? routePoints;
  final Function(CampusBuilding)? onBuildingTap;

  const CampusMapWidget({
    super.key,
    this.highlightedBuilding,
    required this.buildings,
    this.routePoints,
    this.onBuildingTap,
  });

  @override
  State<CampusMapWidget> createState() => _CampusMapWidgetState();
}

class _CampusMapWidgetState extends State<CampusMapWidget> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // Animate to highlighted building if provided
    if (widget.highlightedBuilding != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animateToBuilding(widget.highlightedBuilding!);
      });
    }
  }

  void _animateToBuilding(CampusBuilding building) {
    _mapController.move(building.toLatLng(), MapConfig.defaultZoom);
  }

  @override
  Widget build(BuildContext context) {
    // Define UTP campus boundaries

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter:
            widget.highlightedBuilding?.toLatLng() ?? MapConfig.campusCenter,
        initialZoom: MapConfig.defaultZoom,
        minZoom: MapConfig.minZoom,
        maxZoom: MapConfig.maxZoom,
        // Restrict panning to campus boundaries
        // cameraConstraint: CameraConstraint.contain(bounds: campusBounds),
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        // Map tile layer - always use light mode
        TileLayer(
          urlTemplate: MapConfig.lightTileUrl,
          userAgentPackageName: MapConfig.userAgent,
          tileProvider: NetworkTileProvider(),
        ),

        // Route polyline layer
        if (widget.routePoints != null && widget.routePoints!.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: widget.routePoints!,
                strokeWidth: MapConfig.routeStrokeWidth,
                color: Color(MapConfig.routeColorValue),
              ),
            ],
          ),

        // Building markers layer
        MarkerLayer(
          markers: widget.buildings.map((building) {
            final isSelected = building.id == widget.highlightedBuilding?.id;

            return Marker(
              point: building.toLatLng(),
              width: 120,
              height: 85,
              alignment: Alignment.topCenter,
              child: BuildingMarker(
                building: building,
                isSelected: isSelected,
                onTap: () => widget.onBuildingTap?.call(building),
              ),
            );
          }).toList(),
        ),

        // Attribution layer
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(MapConfig.attribution, onTap: () {}),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}

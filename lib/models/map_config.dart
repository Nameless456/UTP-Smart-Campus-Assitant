import 'package:latlong2/latlong.dart';

/// Configuration for the campus map
class MapConfig {
  // UTP Campus center coordinates
  static const LatLng campusCenter = LatLng(4.3852, 100.9745);

  static const double defaultZoom = 16.0;
  static const double minZoom = 13.0;
  static const double maxZoom = 19.0;

  // OpenStreetMap tile URL (no API key needed)
  static const String tileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  // Map attribution
  static const String attribution = '© OpenStreetMap contributors';

  // User agent for tile requests
  static const String userAgent = 'UTP Smart Campus Assistant';

  // Route polyline color
  static const int routeColorValue = 0xFF2196F3; // Blue
  static const double routeStrokeWidth = 4.0;

  // Marker colors
  static const int markerColorValue = 0xFFE53935; // Red
  static const int selectedMarkerColorValue = 0xFF4CAF50; // Green

  MapConfig._();
}

import 'package:latlong2/latlong.dart';

//configuration for the campus map
class MapConfig {
  //UTP Campus center coordinates
  static const LatLng campusCenter = LatLng(4.3852, 100.9745);

  static const double defaultZoom = 16.0;
  static const double minZoom = 13.0;
  static const double maxZoom = 19.0;

  //openstreetmap tile url (no api key needed) - Light mode
  static const String lightTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  //dark mode tile url - CartoDB Dark Matter (no api key needed)
  static const String darkTileUrl =
      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';

  //map attribution
  static const String attribution = '© OpenStreetMap contributors';
  static const String darkAttribution = '© OpenStreetMap contributors © CARTO';

  //user agent for tile requests
  static const String userAgent = 'com.example.flutter_gemini';

  //route polyline color
  static const int routeColorValue = 0xFF2196F3; //blue
  static const double routeStrokeWidth = 4.0;

  //marker colors
  static const int markerColorValue = 0xFFE53935; //red
  static const int selectedMarkerColorValue = 0xFF4CAF50; //green

  MapConfig._();
}

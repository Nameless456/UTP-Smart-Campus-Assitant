import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/campus_building.dart';
import '../services/campus_map_service.dart';
import '../services/map_route_service.dart';
import '../widgets/campus_map_widget.dart';

/// Full-screen campus map page
class CampusMapScreen extends StatefulWidget {
  final CampusBuilding? initialBuilding;
  final CampusBuilding? fromBuilding;

  const CampusMapScreen({super.key, this.initialBuilding, this.fromBuilding});

  @override
  State<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends State<CampusMapScreen> {
  final CampusMapService _mapService = CampusMapService();
  final MapRouteService _routeService = MapRouteService();

  List<CampusBuilding> _buildings = [];
  CampusBuilding? _selectedBuilding;
  CampusBuilding? _routeFrom;
  List<LatLng>? _routePoints;
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedBuilding = widget.initialBuilding;

    // If both from and to buildings are provided, create route automatically
    if (widget.fromBuilding != null && widget.initialBuilding != null) {
      _routeFrom = widget.fromBuilding;
      _createRoute(widget.fromBuilding!, widget.initialBuilding!);
    }

    _loadBuildings();
  }

  Future<void> _loadBuildings() async {
    try {
      await _mapService.loadBuildings();
      setState(() {
        _buildings = _mapService.getAllBuildings();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load buildings: $e')));
      }
    }
  }

  Future<void> _createRoute(CampusBuilding from, CampusBuilding to) async {
    setState(() => _isLoading = true);

    try {
      final points = await _routeService.fetchRoute(from, to);
      if (mounted) {
        setState(() {
          _routePoints = points;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Fallback to straight line
          _routePoints = _routeService.generateRoute(from, to);
        });
      }
    }
  }

  void _onBuildingTap(CampusBuilding building) {
    setState(() {
      if (_routeFrom == null) {
        _selectedBuilding = building;
        _showBuildingInfo(building);
      } else {
        // Create route from _routeFrom to this building
        _createRoute(_routeFrom!, building);
        _selectedBuilding = building;
        _showRouteInfo(_routeFrom!, building);
      }
    });
  }

  void _showBuildingInfo(CampusBuilding building) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    building.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(building.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _routeFrom = building;
                        _routePoints = null;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Tap another building to create a route',
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.directions),
                    label: const Text('Get Directions'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRouteInfo(CampusBuilding from, CampusBuilding to) {
    final directions = _routeService.generateDirections(from, to);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.directions_walk,
                  color: Theme.of(context).primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Route',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(directions, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _routeFrom = null;
                        _routePoints = null;
                      });
                    },
                    child: const Text('Clear Route'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<CampusBuilding> get _filteredBuildings {
    if (_searchQuery.isEmpty) return _buildings;
    return _mapService.searchBuildings(_searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              // Reset to campus center
              setState(() {
                _selectedBuilding = null;
                _routeFrom = null;
                _routePoints = null;
              });
            },
            tooltip: 'Reset View',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search buildings...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Map
                CampusMapWidget(
                  buildings: _filteredBuildings,
                  highlightedBuilding: _selectedBuilding,
                  routePoints: _routePoints,
                  onBuildingTap: _onBuildingTap,
                ),

                // Route indicator
                if (_routeFrom != null && _routePoints == null)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Starting from: ${_routeFrom!.name}\nTap another building to see the route',
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _routeFrom = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: _searchQuery.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                setState(() => _searchQuery = '');
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear Search'),
            ),
    );
  }
}

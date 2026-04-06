import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  // ── Change these to your actual university coordinates ──
  static const LatLng _campusCenter = LatLng(36.7372, 3.0865);

  final List<Map<String, dynamic>> _buildings = [
    {'name': 'Main Library', 'location': LatLng(36.7375, 3.0868), 'icon': Icons.local_library, 'color': Colors.blue},
    {'name': 'Computer Science Dept', 'location': LatLng(36.7370, 3.0860), 'icon': Icons.computer, 'color': Colors.green},
    {'name': 'Cafeteria', 'location': LatLng(36.7368, 3.0872), 'icon': Icons.restaurant, 'color': Colors.orange},
    {'name': 'Administration', 'location': LatLng(36.7378, 3.0855), 'icon': Icons.business, 'color': Colors.red},
    {'name': 'Sports Complex', 'location': LatLng(36.7362, 3.0858), 'icon': Icons.sports_basketball, 'color': Colors.purple},
  ];

  String? _selectedBuilding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              _mapController.move(_campusCenter, 17.0);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _campusCenter,
              initialZoom: 17.0,
              onTap: (_, __) => setState(() => _selectedBuilding = null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.flutter_app',
              ),
              MarkerLayer(
                markers: _buildings.map((b) {
                  return Marker(
                    point: b['location'] as LatLng,
                    width: 60,
                    height: 60,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedBuilding = b['name']),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: b['color'] as Color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              b['icon'] as IconData,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Selected building info card
          if (_selectedBuilding != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        _selectedBuilding!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _selectedBuilding = null),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Legend
          Positioned(
            top: 10,
            right: 10,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildings.map((b) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(b['icon'] as IconData,
                              color: b['color'] as Color, size: 14),
                          const SizedBox(width: 4),
                          Text(b['name'] as String,
                              style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
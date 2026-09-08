import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  
  await Supabase.initialize(
    url: 'https://vqvfonifzptcqfblrrbq.supabase.co',
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZxdmZvbmlmenB0Y3FmYmxycmJxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYxMzg5MzksImV4cCI6MjEwMTcxNDkzOX0.gi4sitvq6d7-wfRMK9nWBNtDjQbdiVRFjU4Go4NBt-A',
  );

  runApp(const OpenPathApp());
}

class OpenPathApp extends StatelessWidget {
  const OpenPathApp({super.key});                                
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenPath B2B',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const SplashScreen(), 
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return; 
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MapScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.alt_route, color: Colors.white, size: 80),
            const SizedBox(height: 20),
            const Text(
              'OpenPath',
              style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              'Logistics & Routing', 
              style: TextStyle(fontSize: 18, color: Colors.blue.shade200),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Marker> obstacles = [];
  bool isRouteVisible = false;

  @override
  void initState() {
    super.initState();
    _fetchBlockers();
  }

  Future<void> _fetchBlockers() async {
    try {
      final data = await Supabase.instance.client.from('blockers').select();
      setState(() {
        for (var row in data) {
          obstacles.add(
  Marker(
    point: LatLng(row['lat'], row['lng']),
    width: 60,
    height: 60,
    child: _getObstacleIcon(row['note']), // ADD THIS LINE
  ),
);
        }
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }
  Widget _getObstacleIcon(String? note) {
  if (note == null) return const Icon(Icons.warning, color: Colors.red, size: 30);
  
  if (note.contains('Construction')) {
    return const Icon(Icons.construction, color: Colors.orange, size: 30);
  } else if (note.contains('Blocked')) {
    return const Icon(Icons.block, color: Colors.deepOrange, size: 30);
  } else if (note.contains('Uneven')) {
    return const Icon(Icons.accessible_forward, color: Colors.blue, size: 30);
  }
  
  return const Icon(Icons.location_on, color: Colors.red, size: 30);
}

  // Your safeRoutePoints list should be right here below this
  final List<LatLng> safeRoutePoints = [
    const LatLng(10.7735, 106.6980),
    const LatLng(10.7745, 106.6992),
    const LatLng(10.7758, 106.7006), 
    const LatLng(10.7766, 106.6996), 
    const LatLng(10.7778, 106.6983),
  ];
  final LatLng currentLocation = const LatLng(10.7760, 106.7015);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenPath Dispatch', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 15),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.shade300, width: 2),
            ),
            child: Row(
              children: [
                Icon(Icons.local_shipping, color: Colors.green.shade900, size: 22),
                const SizedBox(width: 5),
                Text(
                  '12 Active',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900, fontSize: 16),
                ),
              ],
            ),
          )
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: const LatLng(10.7758, 106.7006), 
          initialZoom: 15.5, 
          onTap: (tapPosition, point) {
            _showReportMenu(point); 
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/){z}/{x}/{y}.png',
            userAgentPackageName: 'com.nexuscorp.openpath',
          ),
          if (isRouteVisible)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: safeRoutePoints,
                  color: Colors.blueAccent,
                  strokeWidth: 6.0,
                ),
              ],
            ),
          MarkerLayer(
            markers: obstacles,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton.extended(
              heroTag: 'route_button', 
              onPressed: () {
                setState(() {
                  isRouteVisible = !isRouteVisible;
                });
              },
              backgroundColor: isRouteVisible ? Colors.grey.shade800 : Colors.blueAccent,
              foregroundColor: Colors.white,
              icon: Icon(isRouteVisible ? Icons.visibility_off : Icons.alt_route),
              label: Text(isRouteVisible ? 'Hide Route' : 'Find Safe Route', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            FloatingActionButton(
              heroTag: 'clear_button', 
              onPressed: () {
                setState(() {
                  obstacles.clear();
                  isRouteVisible = false; 
                });
              },
              tooltip: 'Clear All',
              backgroundColor: Colors.red.shade100,
              child: const Icon(Icons.delete_sweep, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportMenu(LatLng point) {
    showModalBottomSheet(
      context: context, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 350,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Report Mobility Barrier',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(sheetContext),
                  )
                ],
              ),
              const SizedBox(height: 10),
              const Text('Identify the type of obstacle you just encountered:'),
              const SizedBox(height: 20),
              _menuOption(sheetContext, point, 'Construction / Roadwork', Icons.construction, Colors.orange),
              const SizedBox(height: 10),
              _menuOption(sheetContext, point, 'Blocked Sidewalk', Icons.block, Colors.deepOrange),
              const SizedBox(height: 10),
              _menuOption(sheetContext, point, 'Uneven Surface / No Ramp', Icons.accessible_forward, Colors.blue),
            ],
          ),
        );
      },
    );
  }

  Widget _menuOption(BuildContext sheetContext, LatLng point, String title, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      tileColor: color.withValues(alpha: 0.05), 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: () async { 
        Navigator.pop(sheetContext); 

        try {
  await Supabase.instance.client.from('blockers').insert({
    'lat': point.latitude,
    'lng': point.longitude,
    'note': title,
  });
  
  // Show a green success popup
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SUCCESS: Blocker saved to the cloud!'),
        backgroundColor: Colors.green,
      ),
    );
  }
} catch (e) {
  // Show a red error popup with the exact database error
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('DB ERROR: $e'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}

        setState(() {
          obstacles.add(
            Marker(
              point: point,
              width: 60,
              height: 60,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque, 
                onTap: () {
                  _showPinDetails(title, icon, color, point); 
                },
                child: Container(
                  color: Colors.transparent, 
                  width: 60,
                  height: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const CircleAvatar(backgroundColor: Colors.white, radius: 20),
                      Icon(icon, color: color, size: 30),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  void _showPinDetails(String title, IconData icon, Color color, LatLng point) {
    showModalBottomSheet(
      context: context, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.1),
                    radius: 25,
                    child: Icon(icon, color: color, size: 30),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Divider(height: 30),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(
                    "${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}", 
                    style: const TextStyle(fontWeight: FontWeight.bold)
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text("Reported by: Delivery Driver"),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Icon(Icons.pending_actions, size: 16, color: Colors.orange),
                  SizedBox(width: 5),
                  Text("Status: Pending Verification", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        );
      }
    );
  }
}
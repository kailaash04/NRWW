import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:nrw/community_forum.dart';
import 'package:nrw/login.dart';
import 'package:nrw/manage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nrw/complaint.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  GoogleMapController? _controller;
  Location location = Location();
  LatLng? _selectedMarkerPosition;

  static const LatLng _initialPosition = LatLng(13.001970, 80.118896);
  static const LatLng _tankPosition = LatLng(13.001861, 80.118875);
  static const LatLng _endPoint = LatLng(13.001972, 80.118994);
  static const LatLng _additionalStart = LatLng(13.001984, 80.118768);

  static const LatLng _additionalConnectionPoint = LatLng(13.001990, 80.118563);
  static const LatLng _additionalEndPoint = LatLng(13.001994, 80.118425);

  static const LatLng _newPoint1 = LatLng(13.001942, 80.119135);
  static const LatLng _newPoint2 = LatLng(13.002021, 80.119214);
  static const LatLng _newPoint3 = LatLng(13.001835, 80.119198);

  final List<LatLng> _tankToFirstTurn = [_tankPosition, _initialPosition];
  final List<LatLng> _firstTurnToSecondTurn = const [_initialPosition, _endPoint];
  final List<LatLng> _secondTurnToThirdTurn = const [_initialPosition, _additionalStart];
  final List<LatLng> _additionalTurnToConnectionPoint = [_additionalStart, _additionalConnectionPoint];
  final List<LatLng> _connectionPointToEnd = [_additionalConnectionPoint, _additionalEndPoint];
  final List<LatLng> _additionalLine = const [_additionalStart, LatLng(13.001861, 80.118763), LatLng(13.001801, 80.118750), LatLng(13.001707, 80.118740)];

  final List<LatLng> _endPointToNewPoint1 = [_endPoint, _newPoint1];
  final List<LatLng> _newPoint1ToNewPoint2 = [_newPoint1, _newPoint2];
  final List<LatLng> _newPoint1ToNewPoint3 = [_newPoint1, _newPoint3];

  double _flowMeterReadingFM1 = 0.0;
  double _flowMeterReadingFM2 = 0.0;
  double _flowMeterReadingFM3 = 0.0;

  Color _lineColor = Colors.blue; 

  @override
  void initState() {
    super.initState();
    _fetchFlowMeterReadings();
    _determineLineColor();
    requestLocationPermission();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> requestLocationPermission() async {
    PermissionStatus permission = await location.requestPermission();
    if (permission == PermissionStatus.denied ||
        permission == PermissionStatus.deniedForever) {
    }
  }

  Future<void> _fetchFlowMeterReadings() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref();

    ref.child('sensor1/volume').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _flowMeterReadingFM1 = double.parse(event.snapshot.value.toString());
          print('Flow Meter 1: $_flowMeterReadingFM1'); 
        });
      } else {
        print('No data available for sensor1/volume'); 
      }
    });

    ref.child('sensor2/volume').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _flowMeterReadingFM2 = double.parse(event.snapshot.value.toString());
          print('Flow Meter 2: $_flowMeterReadingFM2'); 
        });
      } else {
        print('No data available for sensor2/volume'); 
      }
    });

    ref.child('sensor3/volume').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _flowMeterReadingFM3 = double.parse(event.snapshot.value.toString());
          print('Flow Meter 3: $_flowMeterReadingFM3'); 
        });
      } else {
        print('No data available for sensor3/volume'); 
      }
    });
  }

  void _determineLineColor() {
    if (_flowMeterReadingFM1 > _flowMeterReadingFM2) {
      _lineColor = Colors.red;
    } else {
      _lineColor = Colors.blue;
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    _centerMap();
  }

  void _centerMap() {
    if (_controller != null) {
      _controller!.animateCamera(
        CameraUpdate.newCameraPosition(
          const CameraPosition(
            target: _initialPosition,
            zoom: 15,
          ),
        ),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _centerMap();
    }
  }

  void _openGoogleMaps(LatLng position) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not open Google Maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Example'),
        backgroundColor: Colors.cyan[700], 
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_left),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
            
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _initialPosition,
              zoom: 15,
            ),
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            markers: {
              Marker(
                markerId: const MarkerId('tank'),
                position: _tankPosition,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen),
                infoWindow: const InfoWindow(
                  title: 'Tank',
                  snippet: 'This is the tank location',
                ),
                onTap: () {
                  setState(() {
                    _selectedMarkerPosition = _tankPosition;
                  });
                },
              ),
              Marker(
                markerId: const MarkerId('FM1'),
                position: _initialPosition,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue),
                infoWindow: InfoWindow(
                  title: 'FM1',
                  snippet: 'Flow meter reading: ${_flowMeterReadingFM1} L/m',
                ),
                onTap: () {
                  setState(() {
                    _selectedMarkerPosition = _initialPosition;
                  });
                },
              ),
              Marker(
                markerId: const MarkerId('FM2'),
                position: _additionalStart,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue),
                infoWindow: InfoWindow(
                  title: 'FM2',
                  snippet: 'Flow meter reading: ${_flowMeterReadingFM2} L/m',
                ),
                onTap: () {
                  setState(() {
                    _selectedMarkerPosition = _additionalStart;
                  });
                },
              ),
              Marker(
                markerId: const MarkerId('FM3'),
                position: const LatLng(13.001861, 80.118763),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue),
                infoWindow: InfoWindow(
                  title: 'FM3',
                  snippet: 'Flow meter reading: ${_flowMeterReadingFM3} L/m',
                ),
                onTap: () {
                  setState(() {
                    _selectedMarkerPosition = const LatLng(13.001861, 80.118763);
                  });
                },
              ),
            },
            polylines: {
              Polyline(
                polylineId: const PolylineId('route1'),
                points: _tankToFirstTurn,
                color: Colors.blue,
                width: 5,
              ),
              Polyline(
                polylineId: const PolylineId('route2'),
                points: _firstTurnToSecondTurn,
                color: Colors.blue,
                width: 5,
              ),
              Polyline(
                polylineId: const PolylineId('route3'),
                points: _secondTurnToThirdTurn,
                color: _lineColor,
                width: 5,
              ),
              Polyline(
                polylineId: const PolylineId('additionalRoute'),
                points: _additionalTurnToConnectionPoint,
                color: Colors.blue,
                width: 5,
              ),
              Polyline(
                polylineId: const PolylineId('connectionToEnd'),
                points: _connectionPointToEnd,
                color: Colors.blue,
                width: 5,
              ),
              Polyline(
                polylineId: const PolylineId('additionalLine'),
                points: _additionalLine,
                color: Colors.blue,
                width: 5,
              ),
              Polyline(
                polylineId: const PolylineId('newLine1'),
                points: _endPointToNewPoint1,
                color: Colors.blue,
                width: 5,
              ),
              Polyline(
                polylineId: const PolylineId('newLine2'),
                points: _newPoint1ToNewPoint2,
                color: Colors.blue,
                width: 5,
              ),
              Polyline(
                polylineId: const PolylineId('newLine3'),
                points: _newPoint1ToNewPoint3,
                color: Colors.blue,
                width: 5,
              ),
            },
          ),
          if (_selectedMarkerPosition != null)
            Positioned(
              top: 60.0,
              right: 16.0,
              child: GestureDetector(
                onTap: () {
                  _openGoogleMaps(_selectedMarkerPosition!);
                },
                child: Image.network(
                  'https://lh3.googleusercontent.com/9tLfTpdILdHDAvGrRm7GdbjWdpbWSMOa0csoQ8pUba9tLP8tq7M4Quks1xuMQAVnAxVfryiDXRzZ-KDnkPv8Sm4g_YFom1ltQHjQ6Q',
                  width: 50,
                  height: 50,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromARGB(255, 149, 205, 250),
        selectedItemColor: const Color.fromARGB(255, 17, 114, 218),
        unselectedItemColor: const Color.fromARGB(222, 255, 251, 251),
        currentIndex: 2,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_search),
            label: 'management',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: 'Complaint',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CommunityForumPage()),
            );
            
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ManagePage()),
            );
            
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MapScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ComplaintPage()),
            );
          }
        },
      ),
    );
  }
}

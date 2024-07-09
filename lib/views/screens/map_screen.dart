import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_map_tutorial/services/google_map_services.dart';
import 'package:google_map_tutorial/services/location_services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _googleMapController;
  late final LatLng _currentLocation;
  bool _isFetchingAddress = false;
  LatLng _userCurrentPosition = const LatLng(10.0, 1.0);
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};
  List<LatLng> _positions = [];

  void _onMapCreate(GoogleMapController googleMapController) {
    _googleMapController = googleMapController;
  }

  @override
  void initState() {
    super.initState();
    _isFetchingAddress = true;
    LocationService.getCurrentLocation().then(
          (curLocation) {
        if (curLocation != null) {
          setState(() {
            _currentLocation = curLocation;
            _isFetchingAddress = false;
          });
        }
      },
    );
  }

  void _onAddTapped() async {
    _markers.add(
      Marker(
        markerId: MarkerId(_markers.length.toString()),
        position: _userCurrentPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );
    _positions.add(_userCurrentPosition);

    if (_positions.length >= 2) {
      try {
        final points = await GoogleMapServices.fetchPolylinePoints(
          from: _positions[_positions.length - 2],
          to: _positions[_positions.length - 1],
        );

        if (points.isNotEmpty) {
          setState(() {
            _polyLines.add(
              Polyline(
                polylineId: PolylineId(
                  DateTime.now().microsecondsSinceEpoch.toString(),
                ),
                color: Colors.blue,
                width: 5,
                points: points,
              ),
            );
          });
        }
      } catch (e) {
        print('Error fetching polyline points: $e');
        // Optionally, show a dialog or a Snackbar to inform the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No route found between the selected points.')),
        );
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google map tutorial')),
      body: _isFetchingAddress
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          GoogleMap(
            mapType: MapType.terrain,
            initialCameraPosition:
            CameraPosition(target: _currentLocation, zoom: 15),
            onMapCreated: _onMapCreate,
            onCameraMove: (CameraPosition position) {
              _userCurrentPosition = position.target;
            },
            markers: {
              Marker(
                markerId: MarkerId(
                    DateTime.now().microsecondsSinceEpoch.toString()),
                icon: BitmapDescriptor.defaultMarker,
                position: _currentLocation,
                infoWindow: const InfoWindow(
                  title: 'Current Location',
                  snippet: 'This is your current location',
                ),
              ),
              ..._markers,
            },
            polylines: _polyLines,
          ),
          const Align(
            child: Icon(CupertinoIcons.location_solid),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddTapped,
        child: const Icon(Icons.add),
      ),
    );
  }
}

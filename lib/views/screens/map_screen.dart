import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _googleMapController;
  final LatLng _latLng = const LatLng(10.0, 1.0);

  void _onMapCreate(GoogleMapController googleMapController) {
    _googleMapController = googleMapController;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Google map tutorial')),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.terrain,
            initialCameraPosition: CameraPosition(target: _latLng, zoom: 10),
            onMapCreated: _onMapCreate,
            markers: {
              Marker(
                markerId: MarkerId(
                  DateTime.now().microsecondsSinceEpoch.toString(),
                ),
                icon: BitmapDescriptor.defaultMarker,
                position: _latLng,
infoWindow:const InfoWindow(title: 'text', snippet: 'welcome')
              )
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_map_tutorial/services/google_map_services.dart';
import 'package:google_map_tutorial/utils/app_constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:location/location.dart' as location;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _googleMapController;
  late LatLng _currentLocation;
  bool _isFetchingAddress = false;
  LatLng _userCurrentPosition = const LatLng(10.0, 1.0);
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};
  final List<LatLng> _positions = [];
  final TextEditingController _textEditingController = TextEditingController();
  MapType _mapType = MapType.terrain;

  late location.Location _locationService;

  void _onMapCreate(GoogleMapController googleMapController) {
    _googleMapController = googleMapController;
  }

  @override
  void initState() {
    super.initState();
    _locationService = location.Location();
    _isFetchingAddress = true;
    _initializeLocation();
    _listenToLocationChanges();
  }

  Future<void> _initializeLocation() async {
    bool serviceEnabled;
    location.PermissionStatus permissionGranted;
    location.LocationData locationData;

    serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == location.PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != location.PermissionStatus.granted) {
        return;
      }
    }

    locationData = await _locationService.getLocation();
    setState(() {
      _currentLocation =
          LatLng(locationData.latitude!, locationData.longitude!);
      _isFetchingAddress = false;
    });
  }

  void _listenToLocationChanges() {
    _locationService.onLocationChanged
        .listen((location.LocationData currentLocation) {
      setState(() {
        _currentLocation =
            LatLng(currentLocation.latitude!, currentLocation.longitude!);
        _googleMapController.animateCamera(
          CameraUpdate.newLatLng(_currentLocation),
        );
      });
    });
  }

  Future<void> _drawPolylineTo(LatLng destination) async {
    try {
      final List<LatLng> points = await GoogleMapServices.fetchPolylinePoints(
        from: _currentLocation,
        to: destination,
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('No route found between the selected points.')));
      }
    }
  }

  void _onAddTapped() {
    _markers.add(
      Marker(
        markerId: MarkerId(_markers.length.toString()),
        position: _userCurrentPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );
    _positions.add(_userCurrentPosition);

    if (_positions.length >= 2) {
      _drawPolylineTo(_positions[_positions.length - 1]);
    }
    setState(() {});
  }

  void _onMapTypeChanged() {
    setState(() {
      _mapType = _mapType == MapType.terrain ? MapType.hybrid : MapType.terrain;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GooglePlacesAutoCompleteTextFormField(
          textEditingController: _textEditingController,
          googleAPIKey: dotenv.get(AppConstants.mapApi),
          debounceTime: 400,
          isLatLngRequired: true,
          getPlaceDetailWithLatLng: (prediction) {
            if (prediction.lng != null && prediction.lat != null) {
              LatLng destination = LatLng(
                  double.parse(prediction.lat!), double.parse(prediction.lng!));
              _drawPolylineTo(destination);
              _googleMapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: destination,
                    zoom: 10,
                  ),
                ),
              );
              setState(() {
                _userCurrentPosition = destination;
              });
            }
          },
          itmClick: (prediction) {
            _textEditingController.text = prediction.description!;
            _textEditingController.selection = TextSelection.fromPosition(
              TextPosition(offset: prediction.description!.length),
            );
          },
        ),
      ),
      body: _isFetchingAddress
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapType: _mapType,
                  trafficEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation,
                    zoom: 15,
                  ),
                  onMapCreated: _onMapCreate,
                  onCameraMove: (CameraPosition position) {
                    _userCurrentPosition = position.target;
                  },
                  markers: {
                    Marker(
                      markerId: MarkerId(
                        DateTime.now().microsecondsSinceEpoch.toString(),
                      ),
                      icon: BitmapDescriptor.defaultMarker,
                      position: _userCurrentPosition,
                    ),
                    ..._markers,
                  },
                  polylines: _polyLines,
                ),
                // const Align(
                //   child: Icon(
                //     CupertinoIcons.location_solid,
                //     color: Colors.amberAccent,
                //     size: 50,
                //   ),
                // )
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 200,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              onPressed: _onMapTypeChanged,
              child: const Icon(Icons.map_outlined),
            ),
            FloatingActionButton(
              onPressed: _onAddTapped,
              child: const Icon(Icons.location_on),
            ),
          ],
        ),
      ),
    );
  }
}

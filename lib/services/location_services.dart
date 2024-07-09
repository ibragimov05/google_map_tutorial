import 'package:location/location.dart';

class LocationService {
  static bool _isServiceEnabled = false;
  static LocationData? currentLocation;
  static final Location _location = Location();
  static PermissionStatus _permissionStatus = PermissionStatus.denied;

  LocationService._();

  static Future<void> init() async {
    if (await _checkService() && await _checkPermission()) {
      await getCurrentLocation();
    }
  }

  static Future<bool> _checkService() async {
    _isServiceEnabled = await _location.serviceEnabled();
    if (!_isServiceEnabled) {
      _isServiceEnabled = await _location.requestService();
    }
    return _isServiceEnabled;
  }

  static Future<bool> _checkPermission() async {
    _permissionStatus = await _location.hasPermission();
    if (_permissionStatus == PermissionStatus.denied) {
      _permissionStatus = await _location.requestPermission();
    }
    return _permissionStatus == PermissionStatus.granted;
  }

  static Future<void> getCurrentLocation() async {
    if (_isServiceEnabled && _permissionStatus == PermissionStatus.granted) {
      currentLocation = await _location.getLocation();
    }
  }
}

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_map_tutorial/utils/app_constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapServices {
  static Future<List<LatLng>> fetchPolylinePoints({
    required LatLng from,
    required LatLng to,
  }) async {
    final PolylinePoints polylinePoints = PolylinePoints();
    final result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: dotenv.get(AppConstants.mapApi),
      request: PolylineRequest(
        origin: PointLatLng(from.latitude, from.longitude),
        destination: PointLatLng(to.latitude, to.longitude),
        mode: TravelMode.walking,
      ),
    );
    if (result.points.isNotEmpty) {
      return result.points.map((e) => LatLng(e.latitude, e.longitude)).toList();
    }
    return [];
  }
}

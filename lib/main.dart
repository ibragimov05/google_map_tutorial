import 'package:flutter/material.dart';
import 'package:google_map_tutorial/services/location_services.dart';
import 'package:google_map_tutorial/views/screens/map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocationService.init();
  runApp(GoogleMapApp());
}

class GoogleMapApp extends StatelessWidget {
  const GoogleMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
          centerTitle: false,
        ),
      ),
      home: MapScreen(),
    );
  }
}

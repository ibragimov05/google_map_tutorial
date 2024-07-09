import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_map_tutorial/services/location_services.dart';
import 'package:google_map_tutorial/views/screens/map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocationService.init();
  await dotenv.load(fileName: '.env');
  runApp(const GoogleMapApp());
}

class GoogleMapApp extends StatelessWidget {
  const GoogleMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.amberAccent,
          centerTitle: false,
        ),
      ),
      home: const MapScreen(),
    );
  }
}

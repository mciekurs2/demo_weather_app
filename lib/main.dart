import 'package:flutter/material.dart';
import 'package:weather_app/prefs.dart';
import 'package:weather_app/styles.dart';
import 'package:weather_app/pages/current_weather_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Init globla prefs service
  await Prefs.init();
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Styles.darkTheme,
      home: const CurrentWeatherPage(),
    );
  }
}

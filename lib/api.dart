import 'package:dio/dio.dart';
import 'package:weather_app/models/cities.dart';
import 'package:weather_app/models/current_weather.dart';

class Api {
  Api._();
  static final Api client = Api._();

  // Open weather map dio
  final Dio openWeatherMap = Dio(
    BaseOptions(
      baseUrl: 'https://api.openweathermap.org',
      queryParameters: {
        'appid': '751a0f0b464b39aa6fdb832e3486d0ca',
        'units': 'metric'
      },
    ),
  );

  Future<List<City>?> citiesByName(String cityName) async {
    final res = await openWeatherMap
        .get('/geo/1.0/direct', queryParameters: {'q': cityName, 'limit': 5});
    List? rawList = res.data as List?;
    return rawList?.map((e) => City.toJson(e)).toList();
  }

  Future<CurrentWeather> currentWeatherByCoord(double lat, double lon) async {
    final res = await openWeatherMap
        .get('/data/2.5/weather', queryParameters: {'lat': lat, 'lon': lon});
    return CurrentWeather.toJson(res.data);
  }
}

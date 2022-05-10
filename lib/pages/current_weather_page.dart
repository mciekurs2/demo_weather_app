import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/api.dart';
import 'package:weather_app/models/current_weather.dart';
import 'package:weather_app/pages/search_by_name_page.dart';
import 'package:weather_app/prefs.dart';
import 'package:weather_app/utils.dart';

class CurrentWeatherPage extends StatefulWidget {
  const CurrentWeatherPage({Key? key}) : super(key: key);

  @override
  State<CurrentWeatherPage> createState() => _CurrentWeatherPageState();
}

class _CurrentWeatherPageState extends State<CurrentWeatherPage> {
  bool _searchByCurrentLocation = false;
  double? _lastLat, _lastLon;
  Future<CurrentWeather>? _currentWeatherFuture;

  @override
  void initState() {
    super.initState();
    _searchByCurrentLocation =
        Prefs.instance?.getBool('search_by_current_location') ?? false;
    _lastLat = Prefs.instance?.getDouble('last_lat');
    _lastLon = Prefs.instance?.getDouble('last_lon');

    if (_lastLat != null && _lastLon != null) {
      if (_searchByCurrentLocation) {
        _getCurrentWeatherByLocation();
      } else {
        _getCurrentWeather();
      }
    }
  }

  Future<void> _findCityIdByName() async {
    List<double?>? latLon = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const SearchPageNamePage()));
    if (latLon != null && latLon[0] != null && latLon[1] != null) {
      if (_searchByCurrentLocation) _updateLocationSearchToggle(false);
      Prefs.instance?.setDouble('last_lat', latLon[0]!);
      Prefs.instance?.setDouble('last_lon', latLon[1]!);
      _lastLat = latLon[0]!;
      _lastLon = latLon[1]!;
      setState(() {
        _getCurrentWeather();
      });
    }
  }

  void _getCurrentWeather() {
    _currentWeatherFuture =
        Api.client.currentWeatherByCoord(_lastLat!, _lastLon!);
  }

  Future<CurrentWeather> _getWeatherByLocationFuture() async {
    Position? position;
    bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      Utils.showMessage(context, 'Location service not enabled');
      return Future.error('Location service not enabled');
    } else {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Utils.showMessage(context, 'Location permission is denied');
          return Future.error('Location permission is denied');
        } else if (permission == LocationPermission.deniedForever) {
          Utils.showMessage(
              context, 'Location permission is permanently denied');
          return Future.error('Location permission is permanently denied');
        } else {
          position = await Geolocator.getCurrentPosition();
        }
      } else if (permission == LocationPermission.deniedForever) {
        Utils.showMessage(context, 'Location permission is permanently denied');
        return Future.error('Location permission is permanently denied');
      } else {
        position = await Geolocator.getCurrentPosition();
      }
    }

    _updatePosition(position.latitude, position.longitude);
    _updateLocationSearchToggle(true);

    return Api.client.currentWeatherByCoord(_lastLat!, _lastLon!);
  }

  void _getCurrentWeatherByLocation() async {
    _currentWeatherFuture = _getWeatherByLocationFuture();
  }

  void _updatePosition(double? lat, double? lon) {
    if (lat != null && lon != null) {
      Prefs.instance?.setDouble('last_lat', lat);
      Prefs.instance?.setDouble('last_lon', lon);
      _lastLat = lat;
      _lastLon = lon;
    }
  }

  void _updateLocationSearchToggle(bool enable) {
    Prefs.instance?.setBool('search_by_current_location', enable);
    _searchByCurrentLocation = enable;
  }

  Future<void> _toggleLocationSearch() async {
    setState(() {
      if (_searchByCurrentLocation) {
        _updateLocationSearchToggle(false);
      } else {
        _updateLocationSearchToggle(true);
        _getCurrentWeatherByLocation();
      }
    });
  }

  Future<void> _refreshWeatherData() async {
    setState(() {
      if (_searchByCurrentLocation) {
        _getCurrentWeatherByLocation();
      } else {
        _getCurrentWeather();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current weather'),
        actions: [
          IconButton(
            onPressed: _refreshWeatherData,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _toggleLocationSearch,
            icon: Icon(Icons.location_on_outlined,
                color: _searchByCurrentLocation ? Colors.green : null),
          ),
          IconButton(
            onPressed: _findCityIdByName,
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_lastLat != null && _lastLon != null) {
            setState(() {
              _getCurrentWeather();
            });
            await _currentWeatherFuture;
          } else {
            return Future.value();
          }
        },
        child: Center(
          child: FutureBuilder<CurrentWeather>(
            future: _currentWeatherFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else {
                if (snapshot.hasData) {
                  CurrentWeather weather = snapshot.data!;
                  bool imageFound =
                      weather.weather != null && weather.weather!.isNotEmpty;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.translate(
                        offset: const Offset(0, 10),
                        child: Text(
                          weather.name ?? '-',
                          style: const TextStyle(fontSize: 42, height: 0),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (imageFound)
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: Image.network(
                                Utils.iconUrl(weather.weather!.first.icon),
                              ),
                            ),
                          Text(
                            '${weather.main?.temp ?? '-'} °C',
                            style: const TextStyle(fontSize: 42),
                          ),
                        ],
                      ),
                      Transform.translate(
                        offset: const Offset(0, -15),
                        child: Text(
                          '( ${weather.main?.tempMin ?? '-'} / ${weather.main?.tempMax ?? '-'} Feels like ${weather.main?.feelsLike ?? '-'} )',
                        ),
                      )
                    ],
                  );
                } else if (snapshot.hasError) {
                  return const Text('Error loading weather data');
                }
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RawChip(
                      onPressed: _findCityIdByName,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.search_rounded),
                          SizedBox(width: 4.0),
                          Text('Search location'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    RawChip(
                      onPressed: _getCurrentWeatherByLocation,
                      padding: EdgeInsets.zero,
                      label: const Icon(Icons.location_on_outlined),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/api.dart';
import 'package:weather_app/constans.dart';
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
        Prefs.instance?.getBool('search_by_current_locatiojn') ?? false;
    _lastLat = Prefs.instance?.getDouble('last_lat');
    _lastLon = Prefs.instance?.getDouble('last_lon');

    if (_lastLat != null && _lastLon != null) _getCurrentWeather();
  }

  Future<void> _findCityIdByName() async {
    List<double?>? latLon = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => SearchPageNamePage()));
    if (latLon != null && latLon[0] != null && latLon[1] != null) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Current weather'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _getCurrentWeather();
              });
            },
            icon: Icon(Icons.refresh),
          ),
          // IconButton(
          //   onPressed: () {},
          //   icon: Icon(Icons.location_on_outlined),
          // ),
          IconButton(
            onPressed: _findCityIdByName,
            icon: Icon(Icons.search_rounded),
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
                return CircularProgressIndicator();
              } else {
                if (snapshot.hasData) {
                  CurrentWeather weather = snapshot.data!;
                  bool imageFound =
                      weather.weather != null && weather.weather!.isNotEmpty;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.translate(
                        offset: Offset(0, 10),
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
                  return Text('Error loading weather data');
                }
                return Text('No location set');
              }
            },
          ),
        ),
      ),
      // appBar: AppBar(),
      // body: CustomScrollView(
      //   slivers: [
      //     SliverAppBar(
      //       expandedHeight: 200,
      //       actions: [
      //         IconButton(
      //           onPressed: () {},
      //           icon: Icon(Icons.location_on_outlined),
      //         ),
      //         IconButton(
      //           onPressed: _findCityIdByName,
      //           icon: Icon(Icons.search_rounded),
      //         ),
      //       ],
      //       flexibleSpace: FlexibleSpaceBar(
      //         titlePadding: EdgeInsets.zero,
      //         centerTitle: true,
      //         title: Column(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           children: <Widget>[
      //             Spacer(flex: 3),
      //             Flexible(
      //               flex: 1,
      //               child: Text(
      //                 "Valmiera",
      //                 textAlign: TextAlign.center,
      //               ),
      //             ),
      //             Spacer(flex: 1),
      //           ],
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:weather_app/api.dart';
import 'package:weather_app/models/cities.dart';
import 'package:weather_app/prefs.dart';

class SearchPageNamePage extends StatefulWidget {
  const SearchPageNamePage({Key? key}) : super(key: key);

  @override
  State<SearchPageNamePage> createState() => _SearchPageNamePageState();
}

class _SearchPageNamePageState extends State<SearchPageNamePage> {
  late TextEditingController _controller;
  Timer? _searchDelayTimer;
  Future<List<City>?>? _searchFuture;
  String? lastCityName;

  @override
  void initState() {
    super.initState();
    lastCityName = Prefs.instance?.getString('last_search_city_bane');
    _controller = TextEditingController(text: lastCityName);
    if (lastCityName != null) {
      setState(() {
        _searchFuture = Api.client.citiesByName(lastCityName!);
      });
    }
  }

  @override
  void dispose() {
    _searchDelayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchValueChange(String value) {
    _searchDelayTimer?.cancel();
    if (value.trim().isEmpty) return;

    _searchDelayTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        Prefs.instance?.setString('last_search_city_bane', value);
        setState(() {
          _searchFuture = Api.client.citiesByName(value);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          autofocus: true,
          controller: _controller,
          onChanged: _onSearchValueChange,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(border: InputBorder.none),
        ),
      ),
      body: Center(
        child: FutureBuilder<List<City>?>(
          future: _searchFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else {
              if (snapshot.hasData) {
                if (snapshot.data?.isNotEmpty ?? false) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      City city = snapshot.data![index];
                      return ListTile(
                        title: Text(city.name ?? '-'),
                        onTap: () {
                          Navigator.of(context).pop([city.lat, city.lon]);
                        },
                        subtitle: Text(
                            '${city.country ?? '-'}, ${city.state ?? '-'}'),
                      );
                    },
                  );
                } else {
                  return const Text('No cities found');
                }
              } else if (snapshot.hasError) {
                return const Text('Error while searching');
              }
              return const Text('Search by typing city name');
            }
          },
        ),
      ),
    );
  }
}

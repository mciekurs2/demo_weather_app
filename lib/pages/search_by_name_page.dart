import 'dart:async';

import 'package:flutter/material.dart';
import 'package:weather_app/api.dart';
import 'package:weather_app/models/cities.dart';

class SearchPageNamePage extends StatefulWidget {
  const SearchPageNamePage({Key? key}) : super(key: key);

  @override
  State<SearchPageNamePage> createState() => _SearchPageNamePageState();
}

class _SearchPageNamePageState extends State<SearchPageNamePage> {
  late TextEditingController _controller;
  Timer? _searchDelayTimer;
  Future<List<City>?>? _searchFuture;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
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
          decoration: InputDecoration(border: InputBorder.none),
        ),
      ),
      body: Center(
        child: FutureBuilder<List<City>?>(
          future: _searchFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
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
                  return Text('No cities found');
                }
              } else if (snapshot.hasError) {
                return Text('Error while searching');
              }
              return Text('Search by typing city name');
            }
          },
        ),
      ),
    );
  }
}

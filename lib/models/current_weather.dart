class CurrentWeather {
  Main? main;
  List<Weather>? weather;
  String? name;

  CurrentWeather({
    this.main,
    this.weather,
    this.name,
  });

  CurrentWeather.toJson(json) {
    if (json['main'] != null) {
      main = Main.fromJson(json['main']);
    }
    if (json['weather'] != null) {
      weather = [];
      for (var v in json['weather']) {
        weather!.add(Weather.fromJson(v));
      }
    }
    name = json['name'];
  }
}

class Main {
  double? temp;
  double? tempMin;
  double? tempMax;
  double? feelsLike;

  Main({
    this.temp,
    this.tempMin,
    this.tempMax,
    this.feelsLike,
  });

  Main.fromJson(json) {
    temp = json['temp'];
    tempMin = json['temp_min'];
    tempMax = json['temp_max'];
    feelsLike = json['feels_like'];
  }
}

class Weather {
  String? main;
  String? icon;

  Weather({
    this.main,
    this.icon,
  });

  Weather.fromJson(json) {
    main = json['main'];
    icon = json['icon'];
  }
}

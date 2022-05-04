class City {
  String? name;
  String? country;
  String? state;
  double? lat;
  double? lon;

  City({
    this.name,
    this.country,
    this.state,
    this.lat,
    this.lon,
  });

  City.toJson(json) {
    name = json['name'];
    country = json['country'];
    state = json['state'];
    lat = json['lat'];
    lon = json['lon'];
  }
}

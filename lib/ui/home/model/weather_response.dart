import 'package:weather_forecast_pk/core/app_utils.dart';
import 'package:weather_forecast_pk/ui/home/model/weather_data.dart';

class WeatherResponse {
  Coord? coord;
  List<Weather>? weather;
  String? base;
  Main? main;
  int? visibility;
  Wind? wind;
  Clouds? clouds;
  int? dt;
  Sys? sys;
  int? timezone;
  int? id;
  String? name;
  int? cod;

  WeatherResponse(
      {this.coord,
      this.weather,
      this.base,
      this.main,
      this.visibility,
      this.wind,
      this.clouds,
      this.dt,
      this.sys,
      this.timezone,
      this.id,
      this.name,
      this.cod});

  WeatherResponse.fromJson(dynamic json) {
    coord = json["coord"] != null ? Coord.fromJson(json["coord"]) : null;
    if (json["weather"] != null) {
      weather = [];
      json["weather"].forEach((v) {
        weather?.add(Weather.fromJson(v));
      });
    }
    base = json["base"];
    main = json["main"] != null ? Main.fromJson(json["main"]) : null;
    visibility = json["visibility"];
    wind = json["wind"] != null ? Wind.fromJson(json["wind"]) : null;
    clouds = json["clouds"] != null ? Clouds.fromJson(json["clouds"]) : null;
    dt = json["dt"];
    sys = json["sys"] != null ? Sys.fromJson(json["sys"]) : null;
    timezone = json["timezone"];
    id = json["id"];
    name = json["name"];
    cod = json["cod"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    if (coord != null) {
      map["coord"] = coord?.toJson();
    }
    if (weather != null) {
      map["weather"] = weather?.map((v) => v.toJson()).toList();
    }
    map["base"] = base;
    if (main != null) {
      map["main"] = main?.toJson();
    }
    map["visibility"] = visibility;
    if (wind != null) {
      map["wind"] = wind?.toJson();
    }
    if (clouds != null) {
      map["clouds"] = clouds?.toJson();
    }
    map["dt"] = dt;
    if (sys != null) {
      map["sys"] = sys?.toJson();
    }
    map["timezone"] = timezone;
    map["id"] = id;
    map["name"] = name;
    map["cod"] = cod;
    return map;
  }

  WeatherData toWeatherData() {
    return WeatherData(
        dateTime: unixTimestampToDateTimeString(dt),
        temperature: main!.temp?.round().toString() ?? '0',
        cityAndCountry: "$name, ${sys!.country}",
        weatherConditionIconUrl:
            "https://openweathermap.org/img/wn/${weather![0].icon}@2x.png",
        weatherConditionIconDescription: weather![0].description ?? '',
        humidity: "${main!.humidity}%",
        pressure: "${main!.pressure} mBar",
        visibility: "${(visibility ?? 0) / 1000.0} KM",
        wind: "${wind?.speed ?? 0} m/s",
        feelsLike: "${main!.feelsLike?.round() ?? 0}°C",
        sunrise: unixTimestampToTimeString(sys!.sunrise),
        sunset: unixTimestampToTimeString(sys!.sunset));
  }
}

class Sys {
  int? type;
  int? id;
  String? country;
  int? sunrise;
  int? sunset;

  Sys({this.type, this.id, this.country, this.sunrise, this.sunset});

  Sys.fromJson(dynamic json) {
    type = json["type"];
    id = json["id"];
    country = json["country"];
    sunrise = json["sunrise"];
    sunset = json["sunset"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["type"] = type;
    map["id"] = id;
    map["country"] = country;
    map["sunrise"] = sunrise;
    map["sunset"] = sunset;
    return map;
  }
}

class Clouds {
  int? all;

  Clouds({this.all});

  Clouds.fromJson(dynamic json) {
    all = json["all"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["all"] = all;
    return map;
  }
}

class Wind {
  num? speed;
  int? deg;
  double? gust;

  Wind({this.speed, this.deg, this.gust});

  Wind.fromJson(dynamic json) {
    speed = json["speed"];
    deg = json["deg"];
    gust = (json["gust"] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["speed"] = speed;
    map["deg"] = deg;
    map["gust"] = gust;
    return map;
  }
}

class Main {
  double? temp;
  double? feelsLike;
  double? tempMin;
  double? tempMax;
  int? pressure;
  int? humidity;
  int? seaLevel;
  int? grndLevel;

  Main(
      {this.temp,
      this.feelsLike,
      this.tempMin,
      this.tempMax,
      this.pressure,
      this.humidity,
      this.seaLevel,
      this.grndLevel});

  Main.fromJson(dynamic json) {
    temp = (json["temp"] as num?)?.toDouble();
    feelsLike = (json["feels_like"] as num?)?.toDouble();
    tempMin = (json["temp_min"] as num?)?.toDouble();
    tempMax = (json["temp_max"] as num?)?.toDouble();
    pressure = json["pressure"];
    humidity = json["humidity"];
    seaLevel = json["sea_level"];
    grndLevel = json["grnd_level"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["temp"] = temp;
    map["feels_like"] = feelsLike;
    map["temp_min"] = tempMin;
    map["temp_max"] = tempMax;
    map["pressure"] = pressure;
    map["humidity"] = humidity;
    map["sea_level"] = seaLevel;
    map["grnd_level"] = grndLevel;
    return map;
  }
}

class Weather {
  int? id;
  String? main;
  String? description;
  String? icon;

  Weather({this.id, this.main, this.description, this.icon});

  Weather.fromJson(dynamic json) {
    id = json["id"];
    main = json["main"];
    description = json["description"];
    icon = json["icon"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["main"] = main;
    map["description"] = description;
    map["icon"] = icon;
    return map;
  }
}

class Coord {
  double? lon;
  double? lat;

  Coord({this.lon, this.lat});

  Coord.fromJson(dynamic json) {
    lon = (json["lon"] as num?)?.toDouble();
    lat = (json["lat"] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["lon"] = lon;
    map["lat"] = lat;
    return map;
  }
}

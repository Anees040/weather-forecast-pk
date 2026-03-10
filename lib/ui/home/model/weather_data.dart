class WeatherData {
  String dateTime;
  String temperature;
  double tempRaw;
  double feelsLikeRaw;
  double tempMinRaw;
  double tempMaxRaw;
  String cityAndCountry;
  String weatherConditionIconUrl;
  String weatherConditionIconDescription;
  String weatherMain;
  String humidity;
  String pressure;
  String visibility;
  String wind;
  double windDegree;
  String feelsLike;
  String sunrise;
  String sunset;

  WeatherData({
    required this.dateTime,
    required this.temperature,
    required this.tempRaw,
    required this.feelsLikeRaw,
    required this.tempMinRaw,
    required this.tempMaxRaw,
    required this.cityAndCountry,
    required this.weatherConditionIconUrl,
    required this.weatherConditionIconDescription,
    required this.weatherMain,
    required this.humidity,
    required this.pressure,
    required this.visibility,
    required this.wind,
    required this.windDegree,
    required this.feelsLike,
    required this.sunrise,
    required this.sunset,
  });
}

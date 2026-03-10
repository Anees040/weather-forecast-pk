class WeatherData {
  String dateTime;
  String temperature;
  double tempRaw;
  double feelsLikeRaw;
  String cityAndCountry;
  String weatherConditionIconUrl;
  String weatherConditionIconDescription;
  String humidity;
  String pressure;
  String visibility;
  String wind;
  String feelsLike;
  String sunrise;
  String sunset;

  WeatherData({
    required this.dateTime,
    required this.temperature,
    required this.tempRaw,
    required this.feelsLikeRaw,
    required this.cityAndCountry,
    required this.weatherConditionIconUrl,
    required this.weatherConditionIconDescription,
    required this.humidity,
    required this.pressure,
    required this.visibility,
    required this.wind,
    required this.feelsLike,
    required this.sunrise,
    required this.sunset,
  });
}

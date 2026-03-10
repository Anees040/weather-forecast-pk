import 'package:weather_forecast_pk/ui/home/model/forecast_day.dart';
import 'package:weather_forecast_pk/ui/home/model/weather_data.dart';

abstract class WeatherApi {
  Future<WeatherData>? getWeatherInfo(int? cityId);
  Future<List<ForecastDay>> getForecast(int? cityId);
}

import 'package:weather_forecast_pk/config/build_config.dart';
import 'package:weather_forecast_pk/network/WeatherApi.dart';
import 'package:weather_forecast_pk/network/dio_client.dart';
import 'package:weather_forecast_pk/ui/home/model/forecast_day.dart';
import 'package:weather_forecast_pk/ui/home/model/forecast_response.dart';
import 'package:weather_forecast_pk/ui/home/model/hourly_forecast.dart';
import 'package:weather_forecast_pk/ui/home/model/weather_data.dart';
import 'package:weather_forecast_pk/ui/home/model/weather_response.dart';

class WeatherApiImpl extends WeatherApi {
  var logger = BuildConfig.instance.config.logger;

  @override
  Future<WeatherData>? getWeatherInfo(int? cityId) {
    return _getWeather(cityId);
  }

  @override
  Future<List<ForecastDay>> getForecast(int? cityId) async {
    try {
      var dioClient = DioClient().client;
      var response = await dioClient.get(
        '/forecast',
        queryParameters: {'id': cityId},
      );
      return ForecastResponse().toDailyForecast(response.data);
    } catch (e) {
      logger.e("Forecast error: $e");
      return [];
    }
  }

  @override
  Future<List<HourlyForecast>> getHourlyForecast(int? cityId) async {
    try {
      var dioClient = DioClient().client;
      var response = await dioClient.get(
        '/forecast',
        queryParameters: {'id': cityId},
      );
      return ForecastResponse().toHourlyForecast(response.data);
    } catch (e) {
      logger.e("Hourly forecast error: $e");
      return [];
    }
  }

  Future<WeatherData> _getWeather(int? cityId) async {
    try {
      var dioClient = DioClient().client;
      var response = await dioClient.get(
        '/weather',
        queryParameters: {'id': cityId},
      );

      logger.i("Response body JSON:\n$response");

      WeatherResponse weatherResponse = WeatherResponse.fromJson(response.data);
      WeatherData weatherData = weatherResponse.toWeatherData();
      return weatherData;
    } catch (e) {
      throw e;
    }
  }
}

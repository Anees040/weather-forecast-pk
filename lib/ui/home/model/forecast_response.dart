import 'package:intl/intl.dart';
import 'package:weather_forecast_pk/ui/home/model/forecast_day.dart';
import 'package:weather_forecast_pk/ui/home/model/hourly_forecast.dart';

class ForecastResponse {
  List<ForecastDay> toDailyForecast(dynamic json) {
    final List<dynamic> list = json['list'] ?? [];
    final Map<String, _DayAccumulator> dayMap = {};

    for (var item in list) {
      final dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      final dayKey = DateFormat('yyyy-MM-dd').format(dt);
      final pop = (item['pop'] as num?)?.toDouble() ?? 0.0;

      if (!dayMap.containsKey(dayKey)) {
        dayMap[dayKey] = _DayAccumulator(
          day: DateFormat('EEE, MMM d').format(dt),
          tempMin: double.infinity,
          tempMax: double.negativeInfinity,
          icon: item['weather'][0]['icon'] ?? '01d',
          description: item['weather'][0]['description'] ?? '',
          humidity: item['main']['humidity'] ?? 0,
          windSpeed: (item['wind']['speed'] as num?)?.toDouble() ?? 0.0,
          maxPop: pop,
        );
      }

      final temp = (item['main']['temp'] as num?)?.toDouble() ?? 0.0;
      final acc = dayMap[dayKey]!;
      if (temp < acc.tempMin) acc.tempMin = temp;
      if (temp > acc.tempMax) acc.tempMax = temp;
      if (pop > acc.maxPop) acc.maxPop = pop;
    }

    // Skip today, take next 5 days
    final keys = dayMap.keys.toList();
    if (keys.length > 1) keys.removeAt(0);
    final result = keys.take(5).map((key) {
      final acc = dayMap[key]!;
      return ForecastDay(
        day: acc.day,
        tempMin: acc.tempMin,
        tempMax: acc.tempMax,
        icon: acc.icon,
        description: acc.description,
        humidity: acc.humidity,
        windSpeed: acc.windSpeed,
        pop: (acc.maxPop * 100).roundToDouble(),
      );
    }).toList();

    return result;
  }

  List<HourlyForecast> toHourlyForecast(dynamic json) {
    final List<dynamic> list = json['list'] ?? [];
    // Take next 24 entries (3-hour intervals = ~72 hours, but show 24 entries)
    return list.take(24).map((item) {
      return HourlyForecast(
        time: DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000),
        temp: (item['main']['temp'] as num?)?.toDouble() ?? 0.0,
        icon: item['weather'][0]['icon'] ?? '01d',
        description: item['weather'][0]['description'] ?? '',
        humidity: item['main']['humidity'] ?? 0,
        windSpeed: (item['wind']['speed'] as num?)?.toDouble() ?? 0.0,
        pop: (item['pop'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();
  }
}

class _DayAccumulator {
  String day;
  double tempMin;
  double tempMax;
  String icon;
  String description;
  int humidity;
  double windSpeed;
  double maxPop;

  _DayAccumulator({
    required this.day,
    required this.tempMin,
    required this.tempMax,
    required this.icon,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.maxPop,
  });
}

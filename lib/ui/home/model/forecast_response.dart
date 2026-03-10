import 'package:intl/intl.dart';
import 'package:weather_forecast_pk/ui/home/model/forecast_day.dart';

class ForecastResponse {
  List<ForecastDay> toDailyForecast(dynamic json) {
    final List<dynamic> list = json['list'] ?? [];
    final Map<String, _DayAccumulator> dayMap = {};

    for (var item in list) {
      final dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      final dayKey = DateFormat('yyyy-MM-dd').format(dt);

      if (!dayMap.containsKey(dayKey)) {
        dayMap[dayKey] = _DayAccumulator(
          day: DateFormat('EEE, MMM d').format(dt),
          tempMin: double.infinity,
          tempMax: double.negativeInfinity,
          icon: item['weather'][0]['icon'] ?? '01d',
          description: item['weather'][0]['description'] ?? '',
          humidity: item['main']['humidity'] ?? 0,
          windSpeed: (item['wind']['speed'] as num?)?.toDouble() ?? 0.0,
        );
      }

      final temp = (item['main']['temp'] as num?)?.toDouble() ?? 0.0;
      final acc = dayMap[dayKey]!;
      if (temp < acc.tempMin) acc.tempMin = temp;
      if (temp > acc.tempMax) acc.tempMax = temp;
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
      );
    }).toList();

    return result;
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

  _DayAccumulator({
    required this.day,
    required this.tempMin,
    required this.tempMax,
    required this.icon,
    required this.description,
    required this.humidity,
    required this.windSpeed,
  });
}

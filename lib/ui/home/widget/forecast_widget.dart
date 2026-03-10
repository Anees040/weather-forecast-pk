import 'package:flutter/material.dart';
import 'package:weather_forecast_pk/core/app_utils.dart';
import 'package:weather_forecast_pk/ui/home/model/forecast_day.dart';

class ForecastWidget extends StatelessWidget {
  final List<ForecastDay> forecast;
  final bool isCelsius;

  const ForecastWidget({
    Key? key,
    required this.forecast,
    required this.isCelsius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (forecast.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              const Icon(Icons.calendar_today,
                  color: Color(0xFF64FFDA), size: 16),
              const SizedBox(width: 6),
              Text(
                '5-Day Forecast',
                style: TextStyle(
                  color: Colors.white.withAlpha(200),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        ...forecast.map((day) => _buildDayRow(day)),
      ],
    );
  }

  Widget _buildDayRow(ForecastDay day) {
    final minTemp = isCelsius
        ? day.tempMin.round()
        : celsiusToFahrenheit(day.tempMin).round();
    final maxTemp = isCelsius
        ? day.tempMax.round()
        : celsiusToFahrenheit(day.tempMax).round();
    final unit = isCelsius ? '°C' : '°F';

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Day name
          SizedBox(
            width: 90,
            child: Text(
              day.day,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          // Icon
          Image.network(
            'https://openweathermap.org/img/wn/${day.icon}.png',
            width: 32,
            height: 32,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.cloud, color: Colors.white54, size: 24),
          ),
          const SizedBox(width: 8),
          // Description
          Expanded(
            child: Text(
              _capitalize(day.description),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withAlpha(160),
                fontSize: 12,
              ),
            ),
          ),
          // Min/Max temps
          Text(
            '$minTemp / $maxTemp$unit',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

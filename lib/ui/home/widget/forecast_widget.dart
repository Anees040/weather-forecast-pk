import 'package:flutter/material.dart';
import 'package:weather_forecast_pk/core/app_utils.dart';
import 'package:weather_forecast_pk/ui/home/model/forecast_day.dart';

class ForecastWidget extends StatelessWidget {
  final List<ForecastDay> forecast;
  final bool isCelsius;
  final bool isDark;
  final Color accent;

  const ForecastWidget({
    Key? key,
    required this.forecast,
    required this.isCelsius,
    required this.isDark,
    required this.accent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (forecast.isEmpty) return const SizedBox.shrink();

    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: accent, size: 16),
              const SizedBox(width: 6),
              Text(
                '5-Day Forecast',
                style: TextStyle(
                  color: textColor.withAlpha(200),
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
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? Colors.white.withAlpha(160) : const Color(0xFF6A6A7A);
    final cardColor = isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(8);
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
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Day name
          SizedBox(
            width: 90,
            child: Text(
              day.day,
              style: TextStyle(color: textColor, fontSize: 12),
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
                color: subColor,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${day.pop.round()}%',
                style: TextStyle(
                  color: day.pop > 40 ? accent : subColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'rain',
                style: TextStyle(
                  color: subColor,
                  fontSize: 9,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          // Min/Max temps
          Text(
            '$minTemp / $maxTemp$unit',
            style: TextStyle(
              color: textColor,
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

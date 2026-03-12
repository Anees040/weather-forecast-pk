import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_forecast_pk/core/app_utils.dart';
import 'package:weather_forecast_pk/ui/home/model/hourly_forecast.dart';

class HourlyForecastWidget extends StatelessWidget {
  final List<HourlyForecast> hourly;
  final bool isCelsius;
  final bool isDark;
  final Color accent;

  const HourlyForecastWidget({
    Key? key,
    required this.hourly,
    required this.isCelsius,
    required this.isDark,
    required this.accent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (hourly.isEmpty) return const SizedBox.shrink();
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? Colors.white.withAlpha(140) : const Color(0xFF6A6A7A);
    final cardColor = isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Icon(Icons.access_time_rounded, color: accent, size: 16),
              const SizedBox(width: 6),
              Text(
                'Hourly Forecast',
                style: TextStyle(
                  color: textColor.withAlpha(200),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: hourly.length,
            itemBuilder: (context, index) {
              final h = hourly[index];
              final temp = isCelsius
                  ? h.temp.round()
                  : celsiusToFahrenheit(h.temp).round();
              final unit = isCelsius ? '°' : '°';
              final rainPercent = (h.pop * 100).round();

              return Container(
                width: 72,
                margin: EdgeInsets.only(right: index < hourly.length - 1 ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(h.time),
                      style: TextStyle(color: subColor, fontSize: 11),
                    ),
                    Image.network(
                      'https://openweathermap.org/img/wn/${h.icon}.png',
                      width: 32,
                      height: 32,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.cloud, color: subColor, size: 24),
                    ),
                    Text(
                      '$temp$unit',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (rainPercent > 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.water_drop, color: accent, size: 10),
                          const SizedBox(width: 2),
                          Text(
                            '$rainPercent%',
                            style: TextStyle(color: accent, fontSize: 10),
                          ),
                        ],
                      )
                    else
                      const SizedBox(height: 14),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

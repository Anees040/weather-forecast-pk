import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_forecast_pk/ui/home/model/hourly_forecast.dart';

class RainProbabilityWidget extends StatelessWidget {
  final List<HourlyForecast> hourly;
  final bool isDark;
  final Color accent;

  const RainProbabilityWidget({
    Key? key,
    required this.hourly,
    required this.isDark,
    required this.accent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (hourly.isEmpty) return const SizedBox.shrink();

    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? Colors.white.withAlpha(140) : const Color(0xFF6A6A7A);
    final cardColor = isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(8);

    // Take first 8 entries for the chart
    final items = hourly.take(8).toList();
    final hasRain = items.any((h) => h.pop > 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop_outlined, color: accent, size: 16),
              const SizedBox(width: 6),
              Text(
                'Rain Probability',
                style: TextStyle(
                  color: textColor.withAlpha(200),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!hasRain)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No rain expected in the next 24 hours',
                  style: TextStyle(color: subColor, fontSize: 13),
                ),
              ),
            )
          else
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: items.map((h) {
                  final pct = (h.pop * 100).round();
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '$pct%',
                            style: TextStyle(
                              color: pct > 50 ? accent : subColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: (h.pop).clamp(0.05, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: accent.withAlpha(
                                        (50 + h.pop * 180).round().clamp(50, 230)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            DateFormat('HH').format(h.time),
                            style: TextStyle(color: subColor, fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

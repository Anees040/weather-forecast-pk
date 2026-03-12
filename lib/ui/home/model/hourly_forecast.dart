class HourlyForecast {
  final DateTime time;
  final double temp;
  final String icon;
  final String description;
  final int humidity;
  final double windSpeed;
  final double pop; // probability of precipitation (0.0 - 1.0)

  HourlyForecast({
    required this.time,
    required this.temp,
    required this.icon,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.pop,
  });
}

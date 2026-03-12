class ForecastDay {
  final String day;
  final double tempMin;
  final double tempMax;
  final String icon;
  final String description;
  final int humidity;
  final double windSpeed;
  final double pop; // probability of precipitation (0-100%)

  ForecastDay({
    required this.day,
    required this.tempMin,
    required this.tempMax,
    required this.icon,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.pop,
  });
}

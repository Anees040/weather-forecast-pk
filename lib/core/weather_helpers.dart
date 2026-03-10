import 'package:flutter/material.dart';

/// Returns a gradient based on the weather condition string from OpenWeatherMap.
LinearGradient getWeatherGradient(String? weatherMain) {
  switch (weatherMain?.toLowerCase()) {
    case 'clear':
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
      );
    case 'clouds':
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF373B44), Color(0xFF4286f4), Color(0xFF373B44)],
      );
    case 'rain':
    case 'drizzle':
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0C0C1D), Color(0xFF1A2980), Color(0xFF26D0CE)],
      );
    case 'thunderstorm':
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
      );
    case 'snow':
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE6DADA), Color(0xFF274046), Color(0xFF1B1B2F)],
      );
    case 'mist':
    case 'smoke':
    case 'haze':
    case 'dust':
    case 'fog':
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF232526), Color(0xFF414345), Color(0xFF232526)],
      );
    default:
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
      );
  }
}

/// Returns a weather severity label/badge based on temp and conditions.
String? getWeatherAlert(double tempCelsius, String? weatherMain) {
  if (tempCelsius >= 45) return '🔴 Extreme Heat';
  if (tempCelsius >= 40) return '🟠 Very Hot';
  if (tempCelsius <= -10) return '🔵 Extreme Cold';
  if (tempCelsius <= 0) return '🟣 Freezing';
  if (weatherMain?.toLowerCase() == 'thunderstorm') return '⚡ Thunderstorm Alert';
  if (weatherMain?.toLowerCase() == 'snow') return '❄️ Snowfall Alert';
  return null;
}

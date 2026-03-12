import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, system }

class AppThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _accentColorKey = 'accent_color_index';
  static const String _fontScaleKey = 'font_scale';
  static const String _useAnimationsKey = 'use_animations';

  AppThemeMode _themeMode = AppThemeMode.dark;
  int _accentColorIndex = 0;
  double _fontScale = 1.0;
  bool _useAnimations = true;

  AppThemeMode get themeMode => _themeMode;
  int get accentColorIndex => _accentColorIndex;
  double get fontScale => _fontScale;
  bool get useAnimations => _useAnimations;

  static const List<Color> accentColors = [
    Color(0xFF5B9BD5), // Calm blue (default)
    Color(0xFF7CB342), // Soft green
    Color(0xFFFF8A65), // Warm coral
    Color(0xFFAB47BC), // Gentle purple
    Color(0xFF26C6DA), // Teal
    Color(0xFFFFCA28), // Amber
    Color(0xFFEF5350), // Rose
    Color(0xFF78909C), // Blue grey
  ];

  static const List<String> accentColorNames = [
    'Calm Blue',
    'Soft Green',
    'Warm Coral',
    'Gentle Purple',
    'Teal',
    'Amber',
    'Rose',
    'Blue Grey',
  ];

  Color get accent => accentColors[_accentColorIndex];

  bool isDark(BuildContext context) {
    if (_themeMode == AppThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return _themeMode == AppThemeMode.dark;
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = AppThemeMode.values[prefs.getInt(_themeModeKey) ?? 1];
    _accentColorIndex = prefs.getInt(_accentColorKey) ?? 0;
    _fontScale = prefs.getDouble(_fontScaleKey) ?? 1.0;
    _useAnimations = prefs.getBool(_useAnimationsKey) ?? true;
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
    notifyListeners();
  }

  Future<void> setAccentColor(int index) async {
    _accentColorIndex = index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentColorKey, index);
    notifyListeners();
  }

  Future<void> setFontScale(double scale) async {
    _fontScale = scale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontScaleKey, scale);
    notifyListeners();
  }

  Future<void> setUseAnimations(bool value) async {
    _useAnimations = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useAnimationsKey, value);
    notifyListeners();
  }

  ThemeData buildTheme(BuildContext context) {
    final dark = isDark(context);
    return dark ? _buildDarkTheme() : _buildLightTheme();
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121218),
      colorScheme: ColorScheme.dark(
        primary: accent,
        secondary: accent,
        surface: const Color(0xFF1E1E2A),
      ),
      cardColor: const Color(0xFF1E1E2A),
      dividerColor: Colors.white.withAlpha(15),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF121218),
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20 * _fontScale,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(fontSize: 32 * _fontScale, fontWeight: FontWeight.w300, color: Colors.white),
        headlineMedium: TextStyle(fontSize: 24 * _fontScale, fontWeight: FontWeight.w400, color: Colors.white),
        titleLarge: TextStyle(fontSize: 18 * _fontScale, fontWeight: FontWeight.w600, color: Colors.white),
        titleMedium: TextStyle(fontSize: 15 * _fontScale, fontWeight: FontWeight.w500, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 15 * _fontScale, color: Colors.white.withAlpha(220)),
        bodyMedium: TextStyle(fontSize: 13 * _fontScale, color: Colors.white.withAlpha(180)),
        bodySmall: TextStyle(fontSize: 11 * _fontScale, color: Colors.white.withAlpha(140)),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      colorScheme: ColorScheme.light(
        primary: accent,
        secondary: accent,
        surface: Colors.white,
      ),
      cardColor: Colors.white,
      dividerColor: Colors.black.withAlpha(15),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFF5F7FA),
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        titleTextStyle: TextStyle(
          color: const Color(0xFF1A1A2E),
          fontSize: 20 * _fontScale,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(fontSize: 32 * _fontScale, fontWeight: FontWeight.w300, color: const Color(0xFF1A1A2E)),
        headlineMedium: TextStyle(fontSize: 24 * _fontScale, fontWeight: FontWeight.w400, color: const Color(0xFF1A1A2E)),
        titleLarge: TextStyle(fontSize: 18 * _fontScale, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E)),
        titleMedium: TextStyle(fontSize: 15 * _fontScale, fontWeight: FontWeight.w500, color: const Color(0xFF1A1A2E)),
        bodyLarge: TextStyle(fontSize: 15 * _fontScale, color: const Color(0xFF2D2D3A)),
        bodyMedium: TextStyle(fontSize: 13 * _fontScale, color: const Color(0xFF4A4A5A)),
        bodySmall: TextStyle(fontSize: 11 * _fontScale, color: const Color(0xFF6A6A7A)),
      ),
    );
  }

  // Dynamic weather-based gradients for dark and light modes
  LinearGradient getBackgroundGradient(BuildContext context, String? weatherMain) {
    final dark = isDark(context);
    if (dark) {
      return _getDarkGradient(weatherMain);
    } else {
      return _getLightGradient(weatherMain);
    }
  }

  LinearGradient _getDarkGradient(String? weatherMain) {
    switch (weatherMain?.toLowerCase()) {
      case 'clear':
        return const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF0D1321), Color(0xFF1D2D44), Color(0xFF3E5C76)],
        );
      case 'clouds':
        return const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A2E), Color(0xFF2D2D44), Color(0xFF3D3D55)],
        );
      case 'rain':
      case 'drizzle':
        return const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF0B0E17), Color(0xFF1B2838), Color(0xFF2C3E50)],
        );
      case 'thunderstorm':
        return const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0A14), Color(0xFF1A1A30), Color(0xFF2A2040)],
        );
      case 'snow':
        return const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF1C2331), Color(0xFF2C3E50), Color(0xFF3D566E)],
        );
      case 'mist':
      case 'haze':
      case 'fog':
        return const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1D23), Color(0xFF2C3038), Color(0xFF3E434D)],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF121218), Color(0xFF1A1A28), Color(0xFF222236)],
        );
    }
  }

  LinearGradient _getLightGradient(String? weatherMain) {
    switch (weatherMain?.toLowerCase()) {
      case 'clear':
        return const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFFE8F4FD), Color(0xFFD6EEFB), Color(0xFFBDE0F7)],
        );
      case 'clouds':
        return const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFFE8ECF1), Color(0xFFDDE3EA), Color(0xFFD0D8E3)],
        );
      case 'rain':
      case 'drizzle':
        return const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFFDDE5EE), Color(0xFFC8D6E5), Color(0xFFB0C4D8)],
        );
      case 'thunderstorm':
        return const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFFDCD9E6), Color(0xFFC4BFD6), Color(0xFFADA7C4)],
        );
      case 'snow':
        return const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFFF0F4F8), Color(0xFFE4EAF0), Color(0xFFD8E2EB)],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFFF5F7FA), Color(0xFFEBEFF4), Color(0xFFE1E7EE)],
        );
    }
  }
}

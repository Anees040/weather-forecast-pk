import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:weather_forecast_pk/config/build_config.dart';
import 'package:weather_forecast_pk/core/app_utils.dart';
import 'package:weather_forecast_pk/core/favorites_manager.dart';
import 'package:weather_forecast_pk/core/theme_provider.dart';
import 'package:weather_forecast_pk/core/weather_helpers.dart';
import 'package:weather_forecast_pk/network/WeatherApi.dart';
import 'package:weather_forecast_pk/network/WeatherApiImpl.dart';
import 'package:weather_forecast_pk/ui/home/model/City.dart';
import 'package:weather_forecast_pk/ui/home/model/forecast_day.dart';
import 'package:weather_forecast_pk/ui/home/model/hourly_forecast.dart';
import 'package:weather_forecast_pk/ui/home/model/weather_data.dart';
import 'package:weather_forecast_pk/ui/home/widget/city_search_delegate.dart';
import 'package:weather_forecast_pk/ui/home/widget/forecast_widget.dart';
import 'package:weather_forecast_pk/ui/home/widget/hourly_forecast_widget.dart';
import 'package:weather_forecast_pk/ui/home/widget/rain_probability_widget.dart';
import 'package:weather_forecast_pk/ui/home/widget/wind_compass_widget.dart';
import 'package:weather_forecast_pk/ui/settings/settings_screen.dart';

class HomePage extends StatefulWidget {
  final String title;
  final AppThemeProvider themeProvider;

  HomePage({Key? key, required this.title, required this.themeProvider}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final logger = BuildConfig.instance.config.logger;
  List<City> cityList = [];
  City? selectedCity;
  bool isLoading = false;
  bool isCelsius = true;
  WeatherData? weather;
  List<ForecastDay> forecast = [];
  List<HourlyForecast> hourlyForecast = [];
  List<int> favoriteCityIds = [];
  DateTime? lastUpdated;
  late WeatherApi weatherApi;

  AppThemeProvider get tp => widget.themeProvider;

  @override
  void initState() {
    super.initState();
    readCityList();
    weatherApi = WeatherApiImpl();
    _loadFavorites();
    tp.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    tp.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadFavorites() async {
    final favs = await FavoritesManager.getFavorites();
    setState(() {
      favoriteCityIds = favs;
    });
  }

  Future<void> _toggleFavorite() async {
    if (selectedCity == null) return;
    await FavoritesManager.toggleFavorite(selectedCity!.id);
    await _loadFavorites();
  }

  void _shareWeather() {
    if (weather == null) return;
    final temp = isCelsius
        ? '${weather!.tempRaw.round()}°C'
        : '${celsiusToFahrenheit(weather!.tempRaw).round()}°F';
    final text = '🌤 Weather in ${weather!.cityAndCountry}\n'
        '🌡 Temperature: $temp\n'
        '💧 Humidity: ${weather!.humidity}\n'
        '💨 Wind: ${weather!.wind}\n'
        '🌅 Sunrise: ${weather!.sunrise}\n'
        '🌇 Sunset: ${weather!.sunset}\n'
        '${weather!.weatherConditionIconDescription}\n\n'
        'Sent from Weather Forecast PK app';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = tp.isDark(context);
    final accent = tp.accent;
    final bgGradient = tp.getBackgroundGradient(context, weather?.weatherMain);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? Colors.white.withAlpha(140) : const Color(0xFF6A6A7A);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  _buildHeader(constraints, isDark, accent, textColor, subColor),
                  _buildCitySelector(constraints, isDark, accent, textColor, subColor),
                  Expanded(
                    child: isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                                color: accent, strokeWidth: 2.5))
                        : weather != null
                            ? RefreshIndicator(
                                color: accent,
                                backgroundColor: isDark
                                    ? const Color(0xFF1E1E2A)
                                    : Colors.white,
                                onRefresh: _refreshWeather,
                                child: _buildWeatherContent(
                                    constraints, isDark, accent, textColor, subColor),
                              )
                            : _buildEmptyState(isDark, accent, subColor),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _refreshWeather() async {
    if (selectedCity == null) return;
    await _fetchWeather();
  }

  Widget _buildHeader(BoxConstraints constraints, bool isDark, Color accent,
      Color textColor, Color subColor) {
    final isSmall = constraints.maxWidth < 360;
    return Padding(
      padding: EdgeInsets.fromLTRB(isSmall ? 12 : 20, 12, isSmall ? 12 : 20, 4),
      child: Row(
        children: [
          Icon(Icons.cloud_outlined, color: accent, size: 26),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Weather Forecast',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: isSmall ? 18 : 21,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: textColor.withAlpha(isDark ? 15 : 10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PK',
                  style: TextStyle(
                    color: subColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Text('\u{1F1F5}\u{1F1F0}', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
          const Spacer(),
          if (weather != null)
            _headerButton(
              icon: Icons.share_outlined,
              onTap: _shareWeather,
              isDark: isDark,
              textColor: textColor,
            ),
          if (selectedCity != null)
            _headerButton(
              icon: favoriteCityIds.contains(selectedCity!.id)
                  ? Icons.star
                  : Icons.star_border,
              onTap: _toggleFavorite,
              isDark: isDark,
              textColor: textColor,
              iconColor: favoriteCityIds.contains(selectedCity!.id)
                  ? const Color(0xFFFFD700)
                  : null,
            ),
          GestureDetector(
            onTap: () {
              setState(() {
                isCelsius = !isCelsius;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: accent.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accent.withAlpha(80)),
              ),
              child: Text(
                isCelsius ? '°C' : '°F',
                style: TextStyle(
                  color: accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          _headerButton(
            icon: Icons.settings_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(themeProvider: tp),
                ),
              );
            },
            isDark: isDark,
            textColor: textColor,
          ),
        ],
      ),
    );
  }

  Widget _headerButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    required Color textColor,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
          color: textColor.withAlpha(isDark ? 12 : 10),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: iconColor ?? (isDark ? Colors.white70 : const Color(0xFF5A5A6A)),
          size: 18,
        ),
      ),
    );
  }

  Widget _buildCitySelector(BoxConstraints constraints, bool isDark,
      Color accent, Color textColor, Color subColor) {
    final isSmall = constraints.maxWidth < 360;
    final hPad = isSmall ? 12.0 : 20.0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
      child: GestureDetector(
        onTap: () async {
          final result = await showSearch<City?>(
            context: context,
            delegate: CitySearchDelegate(
              cities: cityList,
              favoriteCityIds: favoriteCityIds,
              isDark: isDark,
              accent: accent,
            ),
          );
          if (result != null) {
            setState(() {
              selectedCity = result;
            });
            // Auto-search: fetch weather immediately on city selection
            _fetchWeather();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: textColor.withAlpha(isDark ? 18 : 10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.location_on_outlined,
                  color: accent, size: isSmall ? 18 : 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  selectedCity?.name ?? 'Tap to select a city...',
                  style: TextStyle(
                    color: selectedCity != null ? textColor : subColor,
                    fontSize: isSmall ? 14 : 15,
                  ),
                ),
              ),
              Icon(Icons.search, color: subColor, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, Color accent, Color subColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wb_sunny_outlined,
              size: 64, color: accent.withAlpha(60)),
          const SizedBox(height: 16),
          Text(
            'Select a city to see weather',
            style: TextStyle(
              color: subColor,
              fontSize: 15,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherContent(BoxConstraints constraints, bool isDark,
      Color accent, Color textColor, Color subColor) {
    final isSmall = constraints.maxWidth < 360;
    final hPad = isSmall ? 12.0 : 20.0;
    final alert = getWeatherAlert(weather!.tempRaw, weather!.weatherMain);
    final cardColor = textColor.withAlpha(isDark ? 14 : 10);

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics()),
      children: [
        const SizedBox(height: 8),
        if (alert != null) _buildAlertBadge(alert, isDark),
        if (alert != null) const SizedBox(height: 10),
        _buildMainCard(constraints, isDark, accent, textColor, subColor),
        const SizedBox(height: 10),
        _buildMinMaxRow(constraints, isDark, accent, textColor, subColor, cardColor),
        const SizedBox(height: 14),
        // Hourly Forecast
        if (hourlyForecast.isNotEmpty)
          HourlyForecastWidget(
            hourly: hourlyForecast,
            isCelsius: isCelsius,
            isDark: isDark,
            accent: accent,
          ),
        if (hourlyForecast.isNotEmpty) const SizedBox(height: 14),
        // Rain Probability
        if (hourlyForecast.isNotEmpty)
          RainProbabilityWidget(
            hourly: hourlyForecast,
            isDark: isDark,
            accent: accent,
          ),
        if (hourlyForecast.isNotEmpty) const SizedBox(height: 14),
        _buildDetailsRow(constraints, isDark, accent, textColor, subColor, cardColor),
        const SizedBox(height: 14),
        _buildInfoCard(constraints, isDark, accent, textColor, subColor, cardColor),
        const SizedBox(height: 14),
        WindCompassWidget(
          windDegree: weather!.windDegree,
          windSpeed: weather!.wind,
          isDark: isDark,
          accent: accent,
        ),
        const SizedBox(height: 14),
        ForecastWidget(
          forecast: forecast,
          isCelsius: isCelsius,
          isDark: isDark,
          accent: accent,
        ),
        const SizedBox(height: 10),
        if (lastUpdated != null) _buildLastUpdated(isDark, accent, subColor),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAlertBadge(String alert, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(isDark ? 40 : 25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Colors.redAccent, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              alert,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF2D2D3A),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinMaxRow(BoxConstraints constraints, bool isDark, Color accent,
      Color textColor, Color subColor, Color cardColor) {
    final minTemp = isCelsius
        ? weather!.tempMinRaw.round()
        : celsiusToFahrenheit(weather!.tempMinRaw).round();
    final maxTemp = isCelsius
        ? weather!.tempMaxRaw.round()
        : celsiusToFahrenheit(weather!.tempMaxRaw).round();
    final unit = isCelsius ? '°C' : '°F';

    return Row(
      children: [
        Expanded(
          child: _tile(Icons.arrow_downward, 'Min Temp', '$minTemp$unit',
              isDark, accent, textColor, subColor, cardColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _tile(Icons.arrow_upward, 'Max Temp', '$maxTemp$unit',
              isDark, accent, textColor, subColor, cardColor),
        ),
      ],
    );
  }

  Widget _buildLastUpdated(bool isDark, Color accent, Color subColor) {
    final timeStr =
        '${lastUpdated!.hour.toString().padLeft(2, '0')}:${lastUpdated!.minute.toString().padLeft(2, '0')}';
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time, color: subColor, size: 13),
            const SizedBox(width: 4),
            Text(
              'Last updated at $timeStr',
              style: TextStyle(color: subColor, fontSize: 11),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _refreshWeather,
              child: Icon(Icons.refresh, color: accent.withAlpha(150), size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard(BoxConstraints constraints, bool isDark, Color accent,
      Color textColor, Color subColor) {
    final isSmall = constraints.maxWidth < 360;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 16 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [Colors.white.withAlpha(20), Colors.white.withAlpha(8)]
              : [Colors.black.withAlpha(8), Colors.black.withAlpha(4)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            weather!.cityAndCountry,
            style: TextStyle(
              color: textColor,
              fontSize: isSmall ? 15 : 17,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            weather!.dateTime,
            style: TextStyle(color: subColor, fontSize: 12),
          ),
          SizedBox(height: isSmall ? 12 : 20),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCelsius
                      ? weather!.tempRaw.round().toString()
                      : celsiusToFahrenheit(weather!.tempRaw).round().toString(),
                  style: TextStyle(
                    color: textColor,
                    fontSize: isSmall ? 64 : 80,
                    fontWeight: FontWeight.w200,
                    height: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    isCelsius ? '\u00b0C' : '\u00b0F',
                    style: TextStyle(
                      color: accent,
                      fontSize: isSmall ? 22 : 28,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                weather!.weatherConditionIconUrl,
                width: 44,
                height: 44,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.cloud, color: subColor, size: 36),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _capitalize(weather!.weatherConditionIconDescription),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: textColor.withAlpha(220), fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isCelsius
                ? 'Feels like ${weather!.feelsLikeRaw.round()}°C'
                : 'Feels like ${celsiusToFahrenheit(weather!.feelsLikeRaw).round()}°F',
            style: TextStyle(color: subColor, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsRow(BoxConstraints constraints, bool isDark, Color accent,
      Color textColor, Color subColor, Color cardColor) {
    return Row(
      children: [
        Expanded(
            child: _tile(Icons.water_drop_outlined, 'Humidity',
                weather!.humidity, isDark, accent, textColor, subColor, cardColor)),
        const SizedBox(width: 10),
        Expanded(
            child: _tile(Icons.compress, 'Pressure', weather!.pressure,
                isDark, accent, textColor, subColor, cardColor)),
      ],
    );
  }

  Widget _tile(IconData icon, String label, String value, bool isDark,
      Color accent, Color textColor, Color subColor, Color cardColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: subColor, fontSize: 11)),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BoxConstraints constraints, bool isDark, Color accent,
      Color textColor, Color subColor, Color cardColor) {
    final dividerColor = isDark ? Colors.white.withAlpha(25) : Colors.black.withAlpha(15);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _infoRow(
            Icons.visibility_outlined, 'Visibility', weather!.visibility,
            Icons.air, 'Wind', weather!.wind,
            accent, textColor, subColor, dividerColor,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: dividerColor, height: 1, thickness: 1),
          ),
          _infoRow(
            Icons.wb_twilight, 'Sunrise', weather!.sunrise,
            Icons.nights_stay_outlined, 'Sunset', weather!.sunset,
            accent, textColor, subColor, dividerColor,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    IconData icon1, String label1, String value1,
    IconData icon2, String label2, String value2,
    Color accent, Color textColor, Color subColor, Color dividerColor,
  ) {
    return Row(
      children: [
        Expanded(child: _infoItem(icon1, label1, value1, accent, textColor, subColor)),
        Container(width: 1, height: 36, color: dividerColor),
        Expanded(child: _infoItem(icon2, label2, value2, accent, textColor, subColor)),
      ],
    );
  }

  Widget _infoItem(IconData icon, String label, String value, Color accent,
      Color textColor, Color subColor) {
    return Column(
      children: [
        Icon(icon, color: accent, size: 20),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(color: subColor, fontSize: 11)),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(value,
              style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  void readCityList() async {
    String response = await rootBundle.loadString('assets/city_list.json');
    final data = await json.decode(response) as List<dynamic>;
    setState(() {
      cityList = data.map((city) => City.fromJson(city)).toList();
      selectedCity = cityList[0];
    });
  }

  Future<void> _fetchWeather() async {
    setState(() {
      isLoading = true;
    });
    try {
      var weatherTemp = await weatherApi.getWeatherInfo(selectedCity?.id);
      var forecastTemp = await weatherApi.getForecast(selectedCity?.id);
      List<HourlyForecast> hourlyTemp = [];
      try {
        hourlyTemp = await weatherApi.getHourlyForecast(selectedCity?.id);
      } catch (_) {
        // Hourly data is optional, don't fail the whole request
      }
      setState(() {
        weather = weatherTemp;
        forecast = forecastTemp;
        hourlyForecast = hourlyTemp;
        lastUpdated = DateTime.now();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      String errorMsg = 'Failed to fetch weather data';
      if (e.toString().contains('401')) {
        errorMsg =
            'API key not activated yet. New keys can take up to 2 hours. Please wait and retry.';
      } else if (e.toString().contains('SocketException') ||
          e.toString().contains('connection')) {
        errorMsg = 'No internet connection. Please check your network.';
      }
      showSnackBar(context, errorMsg, type: SnackBarType.ERROR);
      logger.e(e);
    }
  }

  // Legacy method name kept for backward compat
  showWeather() => _fetchWeather();
}

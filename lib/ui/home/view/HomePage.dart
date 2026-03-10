import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:weather_forecast_pk/config/build_config.dart';
import 'package:weather_forecast_pk/core/app_utils.dart';
import 'package:weather_forecast_pk/core/favorites_manager.dart';
import 'package:weather_forecast_pk/core/weather_helpers.dart';
import 'package:weather_forecast_pk/network/WeatherApi.dart';
import 'package:weather_forecast_pk/network/WeatherApiImpl.dart';
import 'package:weather_forecast_pk/ui/home/model/City.dart';
import 'package:weather_forecast_pk/ui/home/model/forecast_day.dart';
import 'package:weather_forecast_pk/ui/home/model/weather_data.dart';
import 'package:weather_forecast_pk/ui/home/widget/city_search_delegate.dart';
import 'package:weather_forecast_pk/ui/home/widget/forecast_widget.dart';
import 'package:weather_forecast_pk/ui/home/widget/wind_compass_widget.dart';

class HomePage extends StatefulWidget {
  final String title;

  HomePage({Key? key, required this.title}) : super(key: key);

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
  List<int> favoriteCityIds = [];
  DateTime? lastUpdated;
  late WeatherApi weatherApi;

  @override
  void initState() {
    super.initState();
    readCityList();
    weatherApi = WeatherApiImpl();
    _loadFavorites();
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
    final bgGradient = weather != null
        ? getWeatherGradient(weather!.weatherMain)
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
          );

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
                  _buildHeader(constraints),
                  _buildCitySelector(constraints),
                  Expanded(
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF64FFDA), strokeWidth: 2.5))
                        : weather != null
                            ? RefreshIndicator(
                                color: const Color(0xFF64FFDA),
                                backgroundColor: const Color(0xFF302B63),
                                onRefresh: _refreshWeather,
                                child: _buildWeatherContent(constraints),
                              )
                            : _buildEmptyState(),
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
    await showWeather();
  }

  Widget _buildHeader(BoxConstraints constraints) {
    final isSmall = constraints.maxWidth < 360;
    return Padding(
      padding: EdgeInsets.fromLTRB(isSmall ? 12 : 20, 12, isSmall ? 12 : 20, 4),
      child: Row(
        children: [
          const Icon(Icons.cloud_outlined, color: Color(0xFF64FFDA), size: 26),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Weather Forecast',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
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
              color: Colors.white.withAlpha(15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PK',
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
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
            GestureDetector(
              onTap: _shareWeather,
              child: Container(
                padding: const EdgeInsets.all(6),
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.share_outlined,
                    color: Colors.white70, size: 18),
              ),
            ),
          if (selectedCity != null)
            GestureDetector(
              onTap: _toggleFavorite,
              child: Container(
                padding: const EdgeInsets.all(6),
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  favoriteCityIds.contains(selectedCity!.id)
                      ? Icons.star
                      : Icons.star_border,
                  color: favoriteCityIds.contains(selectedCity!.id)
                      ? const Color(0xFFFFD700)
                      : Colors.white70,
                  size: 18,
                ),
              ),
            ),
          GestureDetector(
            onTap: () {
              setState(() {
                isCelsius = !isCelsius;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF64FFDA).withAlpha(30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF64FFDA).withAlpha(80)),
              ),
              child: Text(
                isCelsius ? '°C' : '°F',
                style: const TextStyle(
                  color: Color(0xFF64FFDA),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitySelector(BoxConstraints constraints) {
    final isSmall = constraints.maxWidth < 360;
    final hPad = isSmall ? 12.0 : 20.0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(18),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on_outlined,
                color: const Color(0xFF64FFDA), size: isSmall ? 18 : 20),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final result = await showSearch<City?>(
                    context: context,
                    delegate: CitySearchDelegate(
                      cities: cityList,
                      favoriteCityIds: favoriteCityIds,
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      selectedCity = result;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedCity?.name ?? 'Select a city...',
                          style: TextStyle(
                            color: selectedCity != null
                                ? Colors.white
                                : Colors.white54,
                            fontSize: isSmall ? 14 : 15,
                          ),
                        ),
                      ),
                      const Icon(Icons.search, color: Colors.white54, size: 18),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 38,
              child: ElevatedButton(
                onPressed: isLoading ? null : showWeather,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF64FFDA),
                  foregroundColor: const Color(0xFF0F0C29),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: isSmall ? 14 : 20),
                  elevation: 0,
                ),
                child: Text('Search',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: isSmall ? 13 : 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wb_sunny_outlined,
              size: 64, color: Colors.white.withAlpha(50)),
          const SizedBox(height: 16),
          Text(
            'Select a city & tap Search',
            style: TextStyle(
              color: Colors.white.withAlpha(120),
              fontSize: 15,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherContent(BoxConstraints constraints) {
    final isSmall = constraints.maxWidth < 360;
    final hPad = isSmall ? 12.0 : 20.0;
    final alert = getWeatherAlert(weather!.tempRaw, weather!.weatherMain);

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics()),
      children: [
        const SizedBox(height: 8),
        // Weather Alert Badge
        if (alert != null) _buildAlertBadge(alert),
        if (alert != null) const SizedBox(height: 10),
        _buildMainCard(constraints),
        const SizedBox(height: 10),
        // Min/Max Temp Row
        _buildMinMaxRow(constraints),
        const SizedBox(height: 14),
        _buildDetailsRow(constraints),
        const SizedBox(height: 14),
        _buildInfoCard(constraints),
        const SizedBox(height: 14),
        // Wind Compass
        WindCompassWidget(
          windDegree: weather!.windDegree,
          windSpeed: weather!.wind,
        ),
        const SizedBox(height: 14),
        // 5-Day Forecast
        ForecastWidget(forecast: forecast, isCelsius: isCelsius),
        const SizedBox(height: 10),
        // Last Updated
        if (lastUpdated != null) _buildLastUpdated(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAlertBadge(String alert) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(40),
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinMaxRow(BoxConstraints constraints) {
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
          child: _tile(Icons.arrow_downward, 'Min Temp', '$minTemp$unit'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _tile(Icons.arrow_upward, 'Max Temp', '$maxTemp$unit'),
        ),
      ],
    );
  }

  Widget _buildLastUpdated() {
    final timeStr =
        '${lastUpdated!.hour.toString().padLeft(2, '0')}:${lastUpdated!.minute.toString().padLeft(2, '0')}';
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time, color: Colors.white.withAlpha(80), size: 13),
            const SizedBox(width: 4),
            Text(
              'Last updated at $timeStr',
              style: TextStyle(
                color: Colors.white.withAlpha(80),
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _refreshWeather,
              child: Icon(Icons.refresh,
                  color: const Color(0xFF64FFDA).withAlpha(150), size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard(BoxConstraints constraints) {
    final isSmall = constraints.maxWidth < 360;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 16 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withAlpha(20),
            Colors.white.withAlpha(8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // City and date
          Text(
            weather!.cityAndCountry,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmall ? 15 : 17,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            weather!.dateTime,
            style:
                TextStyle(color: Colors.white.withAlpha(140), fontSize: 12),
          ),
          SizedBox(height: isSmall ? 12 : 20),
          // Temperature
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
                    color: Colors.white,
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
                      color: const Color(0xFF64FFDA),
                      fontSize: isSmall ? 22 : 28,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Icon + description
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                weather!.weatherConditionIconUrl,
                width: 44,
                height: 44,
                errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.cloud, color: Colors.white54, size: 36),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _capitalize(weather!.weatherConditionIconDescription),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white.withAlpha(220), fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isCelsius
                ? 'Feels like ${weather!.feelsLikeRaw.round()}°C'
                : 'Feels like ${celsiusToFahrenheit(weather!.feelsLikeRaw).round()}°F',
            style:
                TextStyle(color: Colors.white.withAlpha(130), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsRow(BoxConstraints constraints) {
    return Row(
      children: [
        Expanded(
            child: _tile(Icons.water_drop_outlined, 'Humidity',
                weather!.humidity)),
        const SizedBox(width: 10),
        Expanded(
            child:
                _tile(Icons.compress, 'Pressure', weather!.pressure)),
      ],
    );
  }

  Widget _tile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF64FFDA), size: 22),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withAlpha(150), fontSize: 11)),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BoxConstraints constraints) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _infoRow(
            Icons.visibility_outlined, 'Visibility', weather!.visibility,
            Icons.air, 'Wind', weather!.wind,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(
                color: Colors.white.withAlpha(25), height: 1, thickness: 1),
          ),
          _infoRow(
            Icons.wb_twilight, 'Sunrise', weather!.sunrise,
            Icons.nights_stay_outlined, 'Sunset', weather!.sunset,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    IconData icon1, String label1, String value1,
    IconData icon2, String label2, String value2,
  ) {
    return Row(
      children: [
        Expanded(child: _infoItem(icon1, label1, value1)),
        Container(
            width: 1,
            height: 36,
            color: Colors.white.withAlpha(25)),
        Expanded(child: _infoItem(icon2, label2, value2)),
      ],
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF64FFDA), size: 20),
        const SizedBox(height: 5),
        Text(label,
            style: TextStyle(
                color: Colors.white.withAlpha(140), fontSize: 11)),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(value,
              style: const TextStyle(
                  color: Colors.white,
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

  showWeather() async {
    setState(() {
      isLoading = true;
    });
    try {
      var weatherTemp = await weatherApi.getWeatherInfo(selectedCity?.id);
      var forecastTemp = await weatherApi.getForecast(selectedCity?.id);
      setState(() {
        weather = weatherTemp;
        forecast = forecastTemp;
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
}

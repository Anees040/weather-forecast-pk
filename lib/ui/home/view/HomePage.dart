import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_forecast_pk/config/build_config.dart';
import 'package:weather_forecast_pk/core/app_utils.dart';
import 'package:weather_forecast_pk/network/WeatherApi.dart';
import 'package:weather_forecast_pk/network/WeatherApiImpl.dart';
import 'package:weather_forecast_pk/ui/home/model/City.dart';
import 'package:weather_forecast_pk/ui/home/model/weather_data.dart';

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
  WeatherData? weather;
  late WeatherApi weatherApi;

  @override
  void initState() {
    super.initState();
    readCityList();
    weatherApi = WeatherApiImpl();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
          ),
        ),
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
                            ? _buildWeatherContent(constraints)
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
              child: DropdownButtonHideUnderline(
                child: DropdownButton<City>(
                  value: selectedCity,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF302B63),
                  style: TextStyle(
                      color: Colors.white, fontSize: isSmall ? 14 : 15),
                  icon: const Icon(Icons.expand_more, color: Colors.white54),
                  onChanged: (City? newCity) {
                    setState(() {
                      if (newCity != null) selectedCity = newCity;
                    });
                  },
                  items: cityList.map((City city) {
                    return DropdownMenuItem<City>(
                      value: city,
                      child: Text(city.name),
                    );
                  }).toList(),
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

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 8),
        _buildMainCard(constraints),
        const SizedBox(height: 14),
        _buildDetailsRow(constraints),
        const SizedBox(height: 14),
        _buildInfoCard(constraints),
        const SizedBox(height: 20),
      ],
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
                  weather!.temperature,
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
                    '\u00b0C',
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
            'Feels like ${weather!.feelsLike}',
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
      setState(() {
        weather = weatherTemp;
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

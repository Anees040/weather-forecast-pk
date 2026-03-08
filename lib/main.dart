import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:weather_forecast_pk/config/build_config.dart';
import 'package:weather_forecast_pk/config/env_config.dart';

import 'ui/home/view/HomePage.dart';

Future<void> main() async {
  var logger = Logger();
  WidgetsFlutterBinding.ensureInitialized();
  try {
    EnvConfig config = await getConfig();
    BuildConfig.instantiate(envConfig: config);
    runApp(MyApp());
  } catch (e) {
    logger.e(e);
  }
}

class NoScrollbarBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class MyApp extends StatelessWidget {
  final String appTitle = 'Weather Forecast';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      scrollBehavior: NoScrollbarBehavior(),
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A237E),
      ),
      home: HomePage(title: appTitle),
      debugShowCheckedModeBanner: false,
    );
  }
}

Future<EnvConfig> getConfig() async {
  var logger = Logger();
  try {
    String configString = await rootBundle.loadString('assets/config.json');
    final configJson = await json.decode(configString) as Map<String, dynamic>;

    String baseUrl = configJson['baseUrl'];
    String appId = configJson['appId'];

    if(baseUrl.isEmpty || appId.isEmpty)
      logger.e('Base URL and AppID should not be empty. '
          'Please add your config in assets/config.json');

    return EnvConfig(
      baseUrl: baseUrl,
      appId: appId,
    );
  } catch (e) {
    throw Exception('$e\nLocal configuration NOT found. '
        'Please create assets/config.json with baseUrl and appId fields.');
  }
}

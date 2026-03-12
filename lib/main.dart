import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:weather_forecast_pk/config/build_config.dart';
import 'package:weather_forecast_pk/config/env_config.dart';
import 'package:weather_forecast_pk/core/theme_provider.dart';

import 'ui/home/view/HomePage.dart';
import 'ui/splash/splash_screen.dart';

Future<void> main() async {
  var logger = Logger();
  WidgetsFlutterBinding.ensureInitialized();
  try {
    EnvConfig config = await getConfig();
    BuildConfig.instantiate(envConfig: config);
    final themeProvider = AppThemeProvider();
    await themeProvider.loadPreferences();
    runApp(MyApp(themeProvider: themeProvider));
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

class MyApp extends StatefulWidget {
  final AppThemeProvider themeProvider;

  const MyApp({Key? key, required this.themeProvider}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final String appTitle = 'Weather Forecast';

  @override
  void initState() {
    super.initState();
    widget.themeProvider.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    widget.themeProvider.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      scrollBehavior: NoScrollbarBehavior(),
      theme: widget.themeProvider.buildTheme(context),
      home: SplashScreen(
        themeProvider: widget.themeProvider,
        nextScreen: HomePage(
          title: appTitle,
          themeProvider: widget.themeProvider,
        ),
      ),
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

import 'package:flutter/material.dart';
import 'package:weather_forecast_pk/ui/home/model/City.dart';

class CitySearchDelegate extends SearchDelegate<City?> {
  final List<City> cities;
  final List<int> favoriteCityIds;
  final bool isDark;
  final Color accent;

  CitySearchDelegate({
    required this.cities,
    this.favoriteCityIds = const [],
    required this.isDark,
    required this.accent,
  });

  @override
  String get searchFieldLabel => 'Search city...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final background = isDark ? const Color(0xFF121218) : const Color(0xFFF5F7FA);
    final foreground = isDark ? Colors.white : const Color(0xFF1A1A2E);
    return ThemeData(
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: foreground.withAlpha(140)),
        border: InputBorder.none,
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(color: foreground, fontSize: 18),
      ),
      scaffoldBackgroundColor: background,
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(Icons.clear, color: isDark ? Colors.white54 : const Color(0xFF6A6A7A)),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    final background = isDark ? const Color(0xFF121218) : const Color(0xFFF5F7FA);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subColor = isDark ? Colors.white.withAlpha(120) : const Color(0xFF6A6A7A);
    final filtered = query.isEmpty
        ? cities
        : cities
            .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

    // Sort: favorites first
    filtered.sort((a, b) {
      final aFav = favoriteCityIds.contains(a.id) ? 0 : 1;
      final bFav = favoriteCityIds.contains(b.id) ? 0 : 1;
      if (aFav != bFav) return aFav.compareTo(bFav);
      return a.name.compareTo(b.name);
    });

    return Container(
      color: background,
      child: ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final city = filtered[index];
          final isFav = favoriteCityIds.contains(city.id);
          return ListTile(
            leading: Icon(
              isFav ? Icons.star : Icons.location_city,
              color: isFav ? const Color(0xFFFFD700) : accent,
              size: 20,
            ),
            title: Text(
              city.name,
              style: TextStyle(color: textColor, fontSize: 15),
            ),
            subtitle: Text(
              city.countryCode,
              style: TextStyle(color: subColor, fontSize: 12),
            ),
            onTap: () => close(context, city),
          );
        },
      ),
    );
  }
}

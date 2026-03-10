import 'package:flutter/material.dart';
import 'package:weather_forecast_pk/ui/home/model/City.dart';

class CitySearchDelegate extends SearchDelegate<City?> {
  final List<City> cities;
  final List<int> favoriteCityIds;

  CitySearchDelegate({required this.cities, this.favoriteCityIds = const []});

  @override
  String get searchFieldLabel => 'Search city...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF302B63),
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white54),
        border: InputBorder.none,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white, fontSize: 18),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F0C29),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.white54),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
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
      color: const Color(0xFF0F0C29),
      child: ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final city = filtered[index];
          final isFav = favoriteCityIds.contains(city.id);
          return ListTile(
            leading: Icon(
              isFav ? Icons.star : Icons.location_city,
              color: isFav ? const Color(0xFFFFD700) : const Color(0xFF64FFDA),
              size: 20,
            ),
            title: Text(
              city.name,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            subtitle: Text(
              city.countryCode,
              style: TextStyle(color: Colors.white.withAlpha(120), fontSize: 12),
            ),
            onTap: () => close(context, city),
          );
        },
      ),
    );
  }
}

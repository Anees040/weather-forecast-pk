import 'package:shared_preferences/shared_preferences.dart';

class FavoritesManager {
  static const String _key = 'favorite_city_ids';

  static Future<List<int>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((e) => int.parse(e)).toList();
  }

  static Future<void> toggleFavorite(int cityId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    final idStr = cityId.toString();
    if (list.contains(idStr)) {
      list.remove(idStr);
    } else {
      list.add(idStr);
    }
    await prefs.setStringList(_key, list);
  }

  static Future<bool> isFavorite(int cityId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.contains(cityId.toString());
  }
}

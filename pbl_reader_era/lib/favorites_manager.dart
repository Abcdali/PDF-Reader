import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
class FavoritesManager {
  static const String _favoritesKey = 'favorite_files';
  Set<String> _favoritePaths = {};
  ValueNotifier<Set<String>> favoritesNotifier = ValueNotifier({});
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _favoritePaths = prefs.getStringList(_favoritesKey)?.toSet() ?? {};
    favoritesNotifier.value = _favoritePaths;
  }
  Future<void> toggleFavorite(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    if (_favoritePaths.contains(filePath)) {
      _favoritePaths.remove(filePath);
    } else {
      _favoritePaths.add(filePath);
    }
    await prefs.setStringList(_favoritesKey, _favoritePaths.toList());

    favoritesNotifier.value = Set.from(_favoritePaths);
  }
  bool isFavorite(String filePath) {
    return _favoritePaths.contains(filePath);
  }

  Set<String> get favoritePaths => _favoritePaths;
}

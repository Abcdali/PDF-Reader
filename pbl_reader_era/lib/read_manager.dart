import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ReadManager {
  static const String _readKey = 'Read_files';
  Set<String> _readPaths = {};
  ValueNotifier<Set<String>> readNotifier = ValueNotifier({});
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _readPaths = prefs.getStringList(_readKey)?.toSet() ?? {};
    readNotifier.value = _readPaths;
  }
  Future<void> toggleRead(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    if (_readPaths.contains(filePath)) {
      _readPaths.remove(filePath);
    } else {
      _readPaths.add(filePath);
    }
    await prefs.setStringList(_readKey, _readPaths.toList());

    readNotifier.value = Set.from(_readPaths);
  }
  bool isRead(String filePath) {
    return favoritePaths.contains(filePath);
  }
  Set<String> get favoritePaths => _readPaths;
}

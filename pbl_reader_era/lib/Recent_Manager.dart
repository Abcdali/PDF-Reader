import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentManager {
  static const String _recentKey = 'recent_files';
  Set<String> _recentPaths = {};

  static final ValueNotifier<List<String>> recentNotifier = ValueNotifier([]);

  Set<String> get recentPaths => _recentPaths;

  Future<void> loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    _recentPaths = prefs.getStringList(_recentKey)?.toSet() ?? {};
    recentNotifier.value = _recentPaths.toList().reversed.toList();
  }
  Future<void> saveRecent() async {

  }
  Future<void> toggleRecent(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    if (_recentPaths.contains(filePath)) {
      _recentPaths.remove(filePath);
    } else {
      _recentPaths.add(filePath);
    }
    await prefs.setStringList(_recentKey, _recentPaths.toList());
    recentNotifier.value = _recentPaths.toList().reversed.toList();
  }

  bool isRecent(String filePath) {
    return _recentPaths.contains(filePath);
  }

  // Adds a file to the top of the recent list and limits to 10
  static Future<void> addToRecent(String filePath) async {
    if (!recentNotifier.value.contains(filePath)) {
      recentNotifier.value = [filePath, ...recentNotifier.value];
    } else {
      recentNotifier.value.remove(filePath);
      recentNotifier.value = [filePath, ...recentNotifier.value];
    }

    if (recentNotifier.value.length > 10) {
      recentNotifier.value = recentNotifier.value.sublist(0, 10);
    }

    // Persist the recent files
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentKey, recentNotifier.value);
  }
}

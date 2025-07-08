import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeletedManager {
  static final DeletedManager _instance = DeletedManager._internal();
  factory DeletedManager() => _instance;

  DeletedManager._internal();

  static final ValueNotifier<List<String>> deletedNotifier = ValueNotifier([]);
  static const _key = 'deleted_files';

  Future<void> loadDeleted() async {
    final prefs = await SharedPreferences.getInstance();
    final files = prefs.getStringList(_key) ?? [];
    deletedNotifier.value = files;
  }

  Future<void> addToDeleted(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? [];
    if (!current.contains(filePath)) {
      current.add(filePath);
      await prefs.setStringList(_key, current);
      deletedNotifier.value = List.from(current);
    }
  }

  Future<void> removeFromDeleted(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? [];
    current.remove(filePath);
    await prefs.setStringList(_key, current);
    deletedNotifier.value = List.from(current);
  }

  bool isDeleted(String filePath) {
    return deletedNotifier.value.contains(filePath);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    deletedNotifier.value = [];
  }
}

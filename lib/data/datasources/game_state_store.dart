import 'package:hive_flutter/hive_flutter.dart';

class GameStateStore {
  static const String boxName = 'gameStateBox';
  static Box? _box;

  static Future<void> init() async {
    _box = await Hive.openBox(boxName);
  }

  static Box get box => _box!;

  static Map<String, dynamic>? getSavedGame(String dateKey) {
    final data = _box?.get(dateKey);
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  static Future<void> saveGame(String dateKey, Map<String, dynamic> state) async {
    await _box?.put(dateKey, state);
  }
}

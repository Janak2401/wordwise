import 'package:hive_flutter/hive_flutter.dart';

class SettingsStore {
  static const String boxName = 'settingsBox';
  static Box? _box;

  static Future<void> init() async {
    _box = await Hive.openBox(boxName);
  }

  static Box get box => _box!;

  static bool get soundEnabled => _box?.get('soundEnabled', defaultValue: true) ?? true;
  static bool get hapticEnabled => _box?.get('hapticEnabled', defaultValue: true) ?? true;
  static bool get isDarkMode => _box?.get('isDarkMode', defaultValue: true) ?? true;
  static bool get hasSeenOnboarding => _box?.get('hasSeenOnboarding', defaultValue: false) ?? false;
  static int get preferredWordLength => _box?.get('preferredWordLength', defaultValue: 5) ?? 5;

  static Future<void> setSoundEnabled(bool val) async => await _box?.put('soundEnabled', val);
  static Future<void> setHapticEnabled(bool val) async => await _box?.put('hapticEnabled', val);
  static Future<void> setIsDarkMode(bool val) async => await _box?.put('isDarkMode', val);
  static Future<void> setHasSeenOnboarding(bool val) async => await _box?.put('hasSeenOnboarding', val);
  static Future<void> setPreferredWordLength(int len) async => await _box?.put('preferredWordLength', len);
}

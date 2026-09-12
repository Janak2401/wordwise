import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/settings_store.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(SettingsStore.isDarkMode);

  void toggleTheme() {
    state = !state;
    SettingsStore.setIsDarkMode(state);
  }

  void setTheme(bool isDark) {
    state = isDark;
    SettingsStore.setIsDarkMode(isDark);
  }
}

import 'package:flutter/services.dart';
import '../../data/datasources/settings_store.dart';

/// Haptic feedback that respects the Haptic Feedback setting.
class HapticUtils {
  static bool get _enabled => SettingsStore.hapticEnabled;

  static void light() {
    if (_enabled) HapticFeedback.lightImpact();
  }

  static void medium() {
    if (_enabled) HapticFeedback.mediumImpact();
  }

  static void heavy() {
    if (_enabled) HapticFeedback.heavyImpact();
  }

  static void selection() {
    if (_enabled) HapticFeedback.selectionClick();
  }

  static void vibrate() {
    if (_enabled) HapticFeedback.vibrate();
  }
}

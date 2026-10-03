import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/game_constants.dart';

class StatsStore {
  static const String boxName = 'statsBox';
  static Box? _box;

  static Future<void> init() async {
    _box = await Hive.openBox(boxName);
  }

  static Box get box => _box!;

  static int get totalPlayed => _box?.get('totalPlayed', defaultValue: 0) ?? 0;
  static int get totalWon => _box?.get('totalWon', defaultValue: 0) ?? 0;
  static int get maxStreak => _box?.get('maxStreak', defaultValue: 0) ?? 0;
  static String? get lastPlayedDate => _box?.get('lastPlayedDate');
  static int get _storedStreak => _box?.get('currentStreak', defaultValue: 0) ?? 0;

  /// One slot per guess count, sized to the longest word's guess limit.
  static List<int> get guessDistribution {
    final dist = List<int>.filled(GameConstants.maxGuessesOverall, 0);
    final stored = _box?.get('guessDistribution');
    if (stored is List) {
      for (var i = 0; i < stored.length && i < dist.length; i++) {
        dist[i] = stored[i] as int;
      }
    }
    return dist;
  }

  /// The streak as of [today]. A missed day breaks it straight away, not only at the next win.
  static int currentStreakOn(DateTime today) {
    final last = lastPlayedDate == null ? null : DateTime.tryParse(lastPlayedDate!);
    if (last == null) return 0;
    final gap = GameConstants.dayNumber(today) - GameConstants.dayNumber(last);
    return gap <= 1 ? _storedStreak : 0;
  }

  /// Records the result for [date]. A date that already has a result is ignored.
  static Future<void> recordGameResult({
    required bool won,
    required int guessesUsed,
    required DateTime date,
  }) async {
    final dateStr = GameConstants.dateKey(date);
    if (lastPlayedDate == dateStr) return;

    final newStreak = won ? currentStreakOn(date) + 1 : 0;
    final newMaxStreak = newStreak > maxStreak ? newStreak : maxStreak;

    final dist = guessDistribution;
    if (won && guessesUsed >= 1 && guessesUsed <= dist.length) {
      dist[guessesUsed - 1] += 1;
    }

    await _box?.putAll({
      'totalPlayed': totalPlayed + 1,
      'totalWon': won ? totalWon + 1 : totalWon,
      'currentStreak': newStreak,
      'maxStreak': newMaxStreak,
      'lastPlayedDate': dateStr,
      'guessDistribution': dist,
    });
  }
}

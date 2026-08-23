import 'package:hive_flutter/hive_flutter.dart';

class StatsStore {
  static const String boxName = 'statsBox';
  static Box? _box;

  static Future<void> init() async {
    _box = await Hive.openBox(boxName);
  }

  static Box get box => _box!;

  static int get totalPlayed => _box?.get('totalPlayed', defaultValue: 0) ?? 0;
  static int get totalWon => _box?.get('totalWon', defaultValue: 0) ?? 0;
  static int get currentStreak => _box?.get('currentStreak', defaultValue: 0) ?? 0;
  static int get maxStreak => _box?.get('maxStreak', defaultValue: 0) ?? 0;
  static String? get lastPlayedDate => _box?.get('lastPlayedDate');

  static List<int> get guessDistribution {
    final list = _box?.get('guessDistribution');
    if (list is List) {
      return List<int>.from(list);
    }
    return List<int>.filled(8, 0);
  }

  static Future<void> recordGameResult({
    required bool won,
    required int guessesUsed,
    required String dateStr,
  }) async {
    final played = totalPlayed + 1;
    final wonCount = won ? (totalWon + 1) : totalWon;
    
    int newStreak = currentStreak;
    if (won) {
      if (lastPlayedDate != null) {
        final last = DateTime.tryParse(lastPlayedDate!);
        final current = DateTime.tryParse(dateStr);
        if (last != null && current != null) {
          final diff = current.difference(last).inDays;
          if (diff == 1) {
            newStreak += 1;
          } else if (diff > 1) {
            newStreak = 1;
          }
        } else {
          newStreak = 1;
        }
      } else {
        newStreak = 1;
      }
    } else {
      newStreak = 0;
    }

    final newMaxStreak = newStreak > maxStreak ? newStreak : maxStreak;

    final dist = List<int>.from(guessDistribution);
    if (won && guessesUsed >= 1 && guessesUsed <= dist.length) {
      dist[guessesUsed - 1] += 1;
    }

    await _box?.put('totalPlayed', played);
    await _box?.put('totalWon', wonCount);
    await _box?.put('currentStreak', newStreak);
    await _box?.put('maxStreak', newMaxStreak);
    await _box?.put('lastPlayedDate', dateStr);
    await _box?.put('guessDistribution', dist);
  }
}

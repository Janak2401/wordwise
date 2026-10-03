import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/datasources/stats_store.dart';

class StatsSnapshot {
  final int played;
  final int won;
  final int currentStreak;
  final int maxStreak;
  final List<int> guessDistribution;

  const StatsSnapshot({
    required this.played,
    required this.won,
    required this.currentStreak,
    required this.maxStreak,
    required this.guessDistribution,
  });

  int get winPercent => played > 0 ? (won * 100 ~/ played) : 0;
}

final statsProvider = StateNotifierProvider<StatsNotifier, StatsSnapshot>((ref) {
  return StatsNotifier();
});

class StatsNotifier extends StateNotifier<StatsSnapshot> {
  StatsNotifier() : super(_load());

  static StatsSnapshot _load() {
    return StatsSnapshot(
      played: StatsStore.totalPlayed,
      won: StatsStore.totalWon,
      currentStreak: StatsStore.currentStreakOn(DateTime.now()),
      maxStreak: StatsStore.maxStreak,
      guessDistribution: StatsStore.guessDistribution,
    );
  }

  /// Re-reads stats, e.g. after the date changes so a broken streak shows as 0.
  void reload() => state = _load();

  Future<void> recordGameResult({
    required bool won,
    required int guessesUsed,
    required DateTime date,
  }) async {
    await StatsStore.recordGameResult(won: won, guessesUsed: guessesUsed, date: date);
    reload();
  }
}

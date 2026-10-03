class GameConstants {
  static const List<int> supportedLengths = [5, 6];

  /// Day 0 of the daily word schedule.
  static final DateTime scheduleEpoch = DateTime.utc(2026, 10, 1);

  static int getMaxGuesses(int wordLength) {
    switch (wordLength) {
      case 5:
        return 6;
      case 6:
        return 7;
      default:
        return wordLength + 1;
    }
  }

  /// Most guesses any supported length allows; sizes the guess distribution.
  static int get maxGuessesOverall => getMaxGuesses(supportedLengths.last);

  /// Days since [scheduleEpoch] for the calendar date of [date] (time of day ignored).
  /// Uses UTC internally so daylight-saving shifts never make two adjacent days 0 or 2 apart.
  static int dayNumber(DateTime date) {
    final day = DateTime.utc(date.year, date.month, date.day);
    return day.difference(scheduleEpoch).inDays;
  }

  /// `yyyy-mm-dd` key for the calendar date of [date].
  static String dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

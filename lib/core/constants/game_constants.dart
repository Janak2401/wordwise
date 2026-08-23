class GameConstants {
  static int getMaxGuesses(int wordLength) {
    switch (wordLength) {
      case 5:
        return 6;
      case 6:
        return 7;
      case 7:
        return 8;
      default:
        return wordLength + 1;
    }
  }
}

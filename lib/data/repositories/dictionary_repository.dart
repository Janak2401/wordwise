import 'package:flutter/services.dart';
import '../datasources/dictionary_db.dart';
import '../models/word.dart';
import '../models/bookmarked_word.dart';

class DictionaryRepository {
  final DictionaryDatabase _db = DictionaryDatabase.instance;
  Set<String>? _validGuesses;

  Future<void> _loadValidGuesses() async {
    if (_validGuesses != null) return;
    try {
      final String contents = await rootBundle.loadString('assets/data/valid_guesses.txt');
      _validGuesses = contents.split('\n').map((w) => w.trim().toUpperCase()).where((w) => w.isNotEmpty).toSet();
    } catch (_) {
      _validGuesses = {};
    }
  }

  Future<Word?> getDailyWord(DateTime date, int length) {
    return _db.getDailyWordForDate(date, length);
  }

  Future<void> recordDailyResult({
    required DateTime date,
    required int wordId,
    required int wordLength,
    required bool solved,
    required int guesses,
  }) {
    return _db.recordDailyResult(
      date: date,
      wordId: wordId,
      wordLength: wordLength,
      solved: solved,
      guesses: guesses,
    );
  }

  Future<bool> isValidWord(String word) async {
    await _loadValidGuesses();
    final upperWord = word.toUpperCase();
    if (_validGuesses != null && _validGuesses!.isNotEmpty) {
      if (_validGuesses!.contains(upperWord)) return true;
    }
    return _db.isValidWord(upperWord);
  }

  Future<Word?> getWordDetails(String word) {
    return _db.getWordByExactString(word);
  }

  Future<bool> bookmarkWord(int wordId) {
    return _db.bookmarkWord(wordId);
  }

  Future<bool> removeBookmark(int wordId) {
    return _db.removeBookmark(wordId);
  }

  Future<bool> isBookmarked(int wordId) {
    return _db.isBookmarked(wordId);
  }

  Future<List<BookmarkedWord>> getBookmarkedWords() {
    return _db.getBookmarkedWords();
  }
}

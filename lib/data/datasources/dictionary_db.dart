import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/constants/game_constants.dart';
import '../models/word.dart';
import '../models/bookmarked_word.dart';

class DictionaryDatabase {
  static final DictionaryDatabase instance = DictionaryDatabase._init();
  static Database? _database;

  static const int _schemaVersion = 2;
  static const String _wordsAsset = 'assets/data/words.json';

  DictionaryDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('wordwise_dict.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = '${dbPath.path}/$filePath';

    return await openDatabase(
      path,
      version: _schemaVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL UNIQUE,
        length INTEGER NOT NULL,
        definition TEXT NOT NULL,
        phonetic TEXT,
        part_of_speech TEXT,
        example TEXT,
        synonyms TEXT,
        difficulty INTEGER NOT NULL DEFAULT 1,
        category TEXT,
        schedule_index INTEGER NOT NULL
      )
    ''');

    await db.execute('CREATE UNIQUE INDEX idx_words_schedule ON words(length, schedule_index)');

    await db.execute('''
      CREATE TABLE word_bank (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word_id INTEGER NOT NULL REFERENCES words(id),
        saved_at TEXT NOT NULL,
        notes TEXT,
        UNIQUE(word_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word_id INTEGER NOT NULL REFERENCES words(id),
        played_date TEXT NOT NULL UNIQUE,
        word_length INTEGER NOT NULL,
        solved INTEGER NOT NULL DEFAULT 0,
        guesses INTEGER,
        time_spent INTEGER
      )
    ''');

    await db.execute('CREATE INDEX idx_daily_date ON daily_history(played_date)');

    await _seedWords(db);
  }

  // The app is not published yet, so upgrades rebuild everything from the asset.
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS word_bank');
    await db.execute('DROP TABLE IF EXISTS daily_history');
    await db.execute('DROP TABLE IF EXISTS words');
    await _createDB(db, newVersion);
  }

  /// Loads the curated word lists. Each list's order is its daily play order.
  Future<void> _seedWords(Database db) async {
    final raw = await rootBundle.loadString(_wordsAsset);
    final lists = jsonDecode(raw) as Map<String, dynamic>;
    final batch = db.batch();

    for (final list in lists.values) {
      final entries = list as List<dynamic>;
      for (var i = 0; i < entries.length; i++) {
        final entry = entries[i] as Map<String, dynamic>;
        final word = (entry['word'] as String).trim().toUpperCase();
        batch.insert('words', {
          'word': word,
          'length': word.length,
          'definition': entry['definition'],
          'phonetic': entry['phonetic'],
          'part_of_speech': entry['part_of_speech'],
          'example': entry['example'],
          'synonyms': entry['synonyms'],
          'difficulty': entry['difficulty'] ?? 1,
          'schedule_index': i,
        });
      }
    }

    await batch.commit(noResult: true);
  }

  Future<Word?> getWordById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'words',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Word.fromMap(maps.first);
    }
    return null;
  }

  Future<Word?> getWordByExactString(String wordStr) async {
    final db = await instance.database;
    final maps = await db.query(
      'words',
      where: 'word = ?',
      whereArgs: [wordStr.toUpperCase()],
    );

    if (maps.isNotEmpty) {
      return Word.fromMap(maps.first);
    }
    return null;
  }

  Future<bool> isValidWord(String wordStr) async {
    final db = await instance.database;
    final maps = await db.query(
      'words',
      columns: ['id'],
      where: 'word = ?',
      whereArgs: [wordStr.toUpperCase()],
    );
    return maps.isNotEmpty;
  }

  /// The scheduled word of [length] for [date]. Every device gets the same word on the same day.
  Future<Word?> getDailyWordForDate(DateTime date, int length) async {
    final db = await instance.database;
    final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM words WHERE length = ?', [length]),
        ) ??
        0;
    if (count == 0) return null;

    final index = GameConstants.dayNumber(date) % count;
    final maps = await db.query(
      'words',
      where: 'length = ? AND schedule_index = ?',
      whereArgs: [length, index],
    );

    if (maps.isNotEmpty) {
      return Word.fromMap(maps.first);
    }
    return null;
  }

  /// Stores the finished game for [date]; one row per day.
  Future<void> recordDailyResult({
    required DateTime date,
    required int wordId,
    required int wordLength,
    required bool solved,
    required int guesses,
  }) async {
    final db = await instance.database;
    await db.insert(
      'daily_history',
      {
        'word_id': wordId,
        'played_date': GameConstants.dateKey(date),
        'word_length': wordLength,
        'solved': solved ? 1 : 0,
        'guesses': guesses,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> bookmarkWord(int wordId) async {
    final db = await instance.database;
    try {
      await db.insert(
        'word_bank',
        {
          'word_id': wordId,
          'saved_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeBookmark(int wordId) async {
    final db = await instance.database;
    final count = await db.delete(
      'word_bank',
      where: 'word_id = ?',
      whereArgs: [wordId],
    );
    return count > 0;
  }

  Future<bool> isBookmarked(int wordId) async {
    final db = await instance.database;
    final maps = await db.query(
      'word_bank',
      where: 'word_id = ?',
      whereArgs: [wordId],
    );
    return maps.isNotEmpty;
  }

  Future<List<BookmarkedWord>> getBookmarkedWords() async {
    final db = await instance.database;
    final results = await db.rawQuery('''
      SELECT
        wb.id as bookmark_id,
        wb.word_id,
        wb.saved_at,
        w.id,
        w.word,
        w.length,
        w.definition,
        w.phonetic,
        w.part_of_speech,
        w.example,
        w.synonyms,
        w.difficulty,
        w.category
      FROM word_bank wb
      JOIN words w ON wb.word_id = w.id
      ORDER BY wb.saved_at DESC
    ''');

    return results.map((row) {
      final word = Word.fromMap(row);
      return BookmarkedWord(
        id: row['bookmark_id'] as int,
        wordId: row['word_id'] as int,
        savedAt: DateTime.parse(row['saved_at'] as String),
        word: word,
      );
    }).toList();
  }
}

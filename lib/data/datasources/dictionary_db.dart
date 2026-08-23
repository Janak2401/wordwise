import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/word.dart';
import '../models/bookmarked_word.dart';

class DictionaryDatabase {
  static final DictionaryDatabase instance = DictionaryDatabase._init();
  static Database? _database;

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
      version: 1,
      onCreate: _createDB,
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
        category TEXT
      )
    ''');

    await db.execute('CREATE INDEX idx_words_length ON words(length)');
    await db.execute('CREATE INDEX idx_words_difficulty ON words(difficulty)');

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

    await _seedInitialWords(db);
  }

  Future<void> _seedInitialWords(Database db) async {
    final batch = db.batch();

    final List<Map<String, dynamic>> initialWords = [
      // 5-letter words
      {
        'word': 'ABATE',
        'length': 5,
        'definition': 'Become less intense or widespread',
        'phonetic': '/əˈbeɪt/',
        'part_of_speech': 'verb',
        'example': 'The storm suddenly abated.',
        'synonyms': 'subside, lessen, ease, diminish',
        'difficulty': 2,
        'category': 'gre'
      },
      {
        'word': 'ACUTE',
        'length': 5,
        'definition': 'Having or showing a perceptive insight; sharp',
        'phonetic': '/əˈkjuːt/',
        'part_of_speech': 'adjective',
        'example': 'An acute observer of human behavior.',
        'synonyms': 'sharp, perceptive, shrewd, keen',
        'difficulty': 1,
        'category': 'sat'
      },
      {
        'word': 'ADEPT',
        'length': 5,
        'definition': 'Very skilled or proficient at something',
        'phonetic': '/əˈdɛpt/',
        'part_of_speech': 'adjective',
        'example': 'He is adept at cutting through red tape.',
        'synonyms': 'expert, proficient, accomplished, skillful',
        'difficulty': 1,
        'category': 'sat'
      },
      {
        'word': 'ALOOF',
        'length': 5,
        'definition': 'Not friendly or forthcoming; cool and distant',
        'phonetic': '/əˈluːf/',
        'part_of_speech': 'adjective',
        'example': 'They tried to remain aloof from politics.',
        'synonyms': 'distant, detached, standoffish, remote',
        'difficulty': 2,
        'category': 'literature'
      },
      {
        'word': 'ARDOR',
        'length': 5,
        'definition': 'Enthusiasm or passion',
        'phonetic': '/ˈɑːdər/',
        'part_of_speech': 'noun',
        'example': 'They approached the project with immense ardor.',
        'synonyms': 'passion, fervor, zeal, devotion',
        'difficulty': 2,
        'category': 'literature'
      },
      {
        'word': 'ASTUTE',
        'length': 5,
        'definition': 'Having or showing an ability to accurately assess situations',
        'phonetic': '/əˈstjuːt/',
        'part_of_speech': 'adjective',
        'example': 'An astute business decision.',
        'synonyms': 'shrewd, sharp, clever, intelligent',
        'difficulty': 2,
        'category': 'sat'
      },
      {
        'word': 'BANAL',
        'length': 5,
        'definition': 'So lacking in originality as to be obvious and boring',
        'phonetic': '/bəˈnɑːl/',
        'part_of_speech': 'adjective',
        'example': 'Songs with banal, repeated lyrics.',
        'synonyms': 'trite, hackneyed, clichéd, vapid',
        'difficulty': 3,
        'category': 'gre'
      },
      {
        'word': 'BRAVE',
        'length': 5,
        'definition': 'Ready to face and endure danger or pain; showing courage',
        'phonetic': '/breɪv/',
        'part_of_speech': 'adjective',
        'example': 'A brave soldier in the face of peril.',
        'synonyms': 'courageous, valiant, fearless',
        'difficulty': 1,
        'category': 'general'
      },
      {
        'word': 'CANDID',
        'length': 5,
        'definition': 'Truthful and straightforward; frank',
        'phonetic': '/ˈkændɪd/',
        'part_of_speech': 'adjective',
        'example': 'His candid opinion was welcomed.',
        'synonyms': 'frank, outspoken, honest, direct',
        'difficulty': 1,
        'category': 'sat'
      },
      {
        'word': 'CHASM',
        'length': 5,
        'definition': 'A deep fissure in the earth, rock, or other surface',
        'phonetic': '/ˈkæz(ə)m/',
        'part_of_speech': 'noun',
        'example': 'A chasm opened between the two parties.',
        'synonyms': 'gorge, abyss, rift, crevasse',
        'difficulty': 2,
        'category': 'literature'
      },
      {
        'word': 'DEFT',
        'length': 5,
        'definition': 'Neat-handed and skillful in one’s movements',
        'phonetic': '/dɛft/',
        'part_of_speech': 'adjective',
        'example': 'A deft touch on the keyboard.',
        'synonyms': 'skillful, agile, nimble, slick',
        'difficulty': 2,
        'category': 'sat'
      },
      {
        'word': 'DOGMA',
        'length': 5,
        'definition': 'A principle or set of principles laid down by an authority',
        'phonetic': '/ˈdɒɡmə/',
        'part_of_speech': 'noun',
        'example': 'Rejecting religious dogma.',
        'synonyms': 'doctrine, belief, tenet, creed',
        'difficulty': 2,
        'category': 'gre'
      },
      {
        'word': 'LUCID',
        'length': 5,
        'definition': 'Expressed clearly; easy to understand',
        'phonetic': '/ˈluːsɪd/',
        'part_of_speech': 'adjective',
        'example': 'A lucid account of the theory.',
        'synonyms': 'clear, coherent, intelligible, articulate',
        'difficulty': 2,
        'category': 'gre'
      },
      {
        'word': 'NOVEL',
        'length': 5,
        'definition': 'New or unusual in an interesting way',
        'phonetic': '/ˈnɒv(ə)l/',
        'part_of_speech': 'adjective',
        'example': 'A novel approach to problem solving.',
        'synonyms': 'new, original, innovative, fresh',
        'difficulty': 1,
        'category': 'sat'
      },
      {
        'word': 'TACIT',
        'length': 5,
        'definition': 'Understood or implied without being stated',
        'phonetic': '/ˈtæsɪt/',
        'part_of_speech': 'adjective',
        'example': 'Your silence may be taken to mean tacit agreement.',
        'synonyms': 'implicit, unspoken, unstated, implied',
        'difficulty': 3,
        'category': 'gre'
      },

      // 6-letter words
      {
        'word': 'ARCANE',
        'length': 6,
        'definition': 'Understood by few; mysterious or secret',
        'phonetic': '/ɑːˈkeɪn/',
        'part_of_speech': 'adjective',
        'example': 'Arcane procedures known only to insiders.',
        'synonyms': 'mysterious, esoteric, obscure, secret',
        'difficulty': 3,
        'category': 'gre'
      },
      {
        'word': 'CANDOR',
        'length': 6,
        'definition': 'The quality of being open and honest in expression',
        'phonetic': '/ˈkændər/',
        'part_of_speech': 'noun',
        'example': 'A man of refreshing candor.',
        'synonyms': 'frankness, openness, honesty, sincerity',
        'difficulty': 2,
        'category': 'sat'
      },
      {
        'word': 'COGENT',
        'length': 6,
        'definition': 'Clear, logical, and convincing in argument',
        'phonetic': '/ˈkəʊdʒ(ə)nt/',
        'part_of_speech': 'adjective',
        'example': 'A cogent argument for reform.',
        'synonyms': 'compelling, convincing, persuasive, forceful',
        'difficulty': 3,
        'category': 'gre'
      },
      {
        'word': 'DOCILE',
        'length': 6,
        'definition': 'Ready to accept control or instruction; submissive',
        'phonetic': '/ˈdəʊsaɪl/',
        'part_of_speech': 'adjective',
        'example': 'A docile and obedient pet.',
        'synonyms': 'compliant, obedient, submissive, yielding',
        'difficulty': 2,
        'category': 'sat'
      },
      {
        'word': 'ELUSIVE',
        'length': 6,
        'definition': 'Difficult to find, catch, or achieve',
        'phonetic': '/ɪˈluːsɪv/',
        'part_of_speech': 'adjective',
        'example': 'Success remained elusive for years.',
        'synonyms': 'evasive, slippery, subtle, intangible',
        'difficulty': 2,
        'category': 'sat'
      },
      {
        'word': 'FERVID',
        'length': 6,
        'definition': 'Intensely enthusiastic or passionate',
        'phonetic': '/ˈfəːvɪd/',
        'part_of_speech': 'adjective',
        'example': 'A letter of fervid devotion.',
        'synonyms': 'ardent, passionate, impassioned, vehement',
        'difficulty': 3,
        'category': 'gre'
      },
      {
        'word': 'LUCENT',
        'length': 6,
        'definition': 'Glowing with or giving off light',
        'phonetic': '/ˈluːs(ə)nt/',
        'part_of_speech': 'adjective',
        'example': 'The lucent glow of the full moon.',
        'synonyms': 'shining, luminous, bright, radiant',
        'difficulty': 3,
        'category': 'literature'
      },
      {
        'word': 'NIMBLE',
        'length': 6,
        'definition': 'Quick and light in movement or action; agile',
        'phonetic': '/ˈnɪmb(ə)l/',
        'part_of_speech': 'adjective',
        'example': 'Her nimble fingers quickly finished the knot.',
        'synonyms': 'agile, lithe, sprightly, quick',
        'difficulty': 1,
        'category': 'general'
      },
      {
        'word': 'OPULENT',
        'length': 6,
        'definition': 'Ostentatiously rich and luxurious or lavish',
        'phonetic': '/ˈɒpjʊlənt/',
        'part_of_speech': 'adjective',
        'example': 'The opulent comfort of a luxury hotel.',
        'synonyms': 'luxurious, palatial, lavish, sumptuous',
        'difficulty': 2,
        'category': 'sat'
      },
      {
        'word': 'PRISTINE',
        'length': 6,
        'definition': 'In its original condition; unspoiled and clean',
        'phonetic': '/ˈprɪstiːn/',
        'part_of_speech': 'adjective',
        'example': 'Pristine mountain streams.',
        'synonyms': 'unspoiled, untouched, pure, immaculate',
        'difficulty': 2,
        'category': 'sat'
      },
      {
        'word': 'SUBTLE',
        'length': 6,
        'definition': 'So delicate or precise as to be difficult to analyze',
        'phonetic': '/ˈsʌt(ə)l/',
        'part_of_speech': 'adjective',
        'example': 'Subtle nuances in the music.',
        'synonyms': 'delicate, understated, muted, elusive',
        'difficulty': 1,
        'category': 'general'
      },

      // 7-letter words
      {
        'word': 'ABSTRUSE',
        'length': 7,
        'definition': 'Difficult to understand; obscure',
        'phonetic': '/əbˈstruːs/',
        'part_of_speech': 'adjective',
        'example': 'An abstruse philosophical inquiry.',
        'synonyms': 'obscure, arcane, esoteric, recondite',
        'difficulty': 4,
        'category': 'gre'
      },
      {
        'word': 'ACUMEN',
        'length': 7,
        'definition': 'The ability to make good judgments and quick decisions',
        'phonetic': '/ˈækjʊmən/',
        'part_of_speech': 'noun',
        'example': 'Remarkable business acumen.',
        'synonyms': 'astuteness, shrewdness, acuity, sharpness',
        'difficulty': 3,
        'category': 'sat'
      },
      {
        'word': 'AUDACITY',
        'length': 7,
        'definition': 'The willingness to take bold risks; impudence',
        'phonetic': '/ɔːˈdæsɪti/',
        'part_of_speech': 'noun',
        'example': 'He had the audacity to question the master.',
        'synonyms': 'boldness, daring, impudence, nerve',
        'difficulty': 2,
        'category': 'sat'
      },
      {
        'word': 'EPHEMERAL',
        'length': 7,
        'definition': 'Lasting for a very short time',
        'phonetic': '/ɪˈfɛm(ə)rəl/',
        'part_of_speech': 'adjective',
        'example': 'Fashions are ephemeral, but style endures.',
        'synonyms': 'fleeting, transient, momentary, brief',
        'difficulty': 3,
        'category': 'gre'
      },
      {
        'word': 'LACONIC',
        'length': 7,
        'definition': 'Using or involving the use of a minimum of words',
        'phonetic': '/ləˈkɒnɪk/',
        'part_of_speech': 'adjective',
        'example': 'His laconic reply was simply "No."',
        'synonyms': 'brief, concise, terse, succinct',
        'difficulty': 3,
        'category': 'gre'
      },
      {
        'word': 'LUCIDITY',
        'length': 7,
        'definition': 'Clarity of expression; intelligibility',
        'phonetic': '/luːˈsɪdɪti/',
        'part_of_speech': 'noun',
        'example': 'The lucidity of his lectures drew applause.',
        'synonyms': 'clarity, coherence, intelligibility',
        'difficulty': 2,
        'category': 'sat'
      },
      {
        'word': 'SAGACITY',
        'length': 7,
        'definition': 'The quality of keen mental discernment and good judgment',
        'phonetic': '/səˈɡæsɪti/',
        'part_of_speech': 'noun',
        'example': 'A man of great political sagacity.',
        'synonyms': 'wisdom, insight, intelligence, perception',
        'difficulty': 3,
        'category': 'literature'
      },
    ];

    for (final word in initialWords) {
      final actualWord = (word['word'] as String).trim();
      final actualLength = actualWord.length;
      word['length'] = actualLength;

      batch.insert(
        'words',
        word,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
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

  Future<List<Word>> getWordsByLength(int length) async {
    final db = await instance.database;
    final maps = await db.query(
      'words',
      where: 'length = ?',
      whereArgs: [length],
    );
    return maps.map((e) => Word.fromMap(e)).toList();
  }

  Future<Word?> getDailyWordForDate(DateTime date, {int? preferredLength}) async {
    final db = await instance.database;
    final dateStr = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final historyMaps = await db.query(
      'daily_history',
      where: 'played_date = ?',
      whereArgs: [dateStr],
    );

    if (historyMaps.isNotEmpty) {
      final wordId = historyMaps.first['word_id'] as int;
      return await getWordById(wordId);
    }

    final targetLength = preferredLength ?? ((date.day % 3) + 5);
    final candidates = await getWordsByLength(targetLength);

    if (candidates.isEmpty) {
      final allWords = await db.query('words');
      if (allWords.isNotEmpty) {
        return Word.fromMap(allWords.first);
      }
      return null;
    }

    final seed = date.year * 10000 + date.month * 100 + date.day;
    final selectedIndex = seed % candidates.length;
    final selectedWord = candidates[selectedIndex];

    await db.insert(
      'daily_history',
      {
        'word_id': selectedWord.id,
        'played_date': dateStr,
        'word_length': selectedWord.length,
        'solved': 0,
        'guesses': null,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    return selectedWord;
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

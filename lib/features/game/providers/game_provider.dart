import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../data/models/guess_result.dart';
import '../../../data/models/word.dart';
import '../../../data/repositories/dictionary_repository.dart';
import '../../../data/datasources/settings_store.dart';
import '../../../data/datasources/game_state_store.dart';
import '../../stats/providers/stats_provider.dart';

enum GameStatus { playing, won, lost }

class GameState {
  final Word? targetWord;
  final int wordLength;
  final int maxGuesses;
  final List<List<GuessLetter>> submittedRows;
  final String currentInput;
  final GameStatus status;
  final Map<String, LetterEvaluation> keyEvaluations;
  final bool isShaking;
  final String? message;
  final bool isBookmarked;

  /// Row to play the flip animation on; null when nothing was submitted this session.
  final int? revealRow;

  /// Days since the schedule epoch for the loaded game, shown as the puzzle number.
  final int dayNumber;

  const GameState({
    this.targetWord,
    required this.wordLength,
    required this.maxGuesses,
    required this.submittedRows,
    required this.currentInput,
    required this.status,
    required this.keyEvaluations,
    this.isShaking = false,
    this.message,
    this.isBookmarked = false,
    this.revealRow,
    this.dayNumber = 0,
  });

  /// The length can only be changed before the first guess of the day.
  bool get isLengthLocked => submittedRows.isNotEmpty || status != GameStatus.playing;

  GameState copyWith({
    Word? targetWord,
    int? wordLength,
    int? maxGuesses,
    List<List<GuessLetter>>? submittedRows,
    String? currentInput,
    GameStatus? status,
    Map<String, LetterEvaluation>? keyEvaluations,
    bool? isShaking,
    String? message,
    bool? isBookmarked,
    int? revealRow,
  }) {
    return GameState(
      targetWord: targetWord ?? this.targetWord,
      wordLength: wordLength ?? this.wordLength,
      maxGuesses: maxGuesses ?? this.maxGuesses,
      submittedRows: submittedRows ?? this.submittedRows,
      currentInput: currentInput ?? this.currentInput,
      status: status ?? this.status,
      keyEvaluations: keyEvaluations ?? this.keyEvaluations,
      isShaking: isShaking ?? this.isShaking,
      message: message,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      revealRow: revealRow ?? this.revealRow,
      dayNumber: dayNumber,
    );
  }
}

final dictionaryRepoProvider = Provider<DictionaryRepository>((ref) {
  return DictionaryRepository();
});

final ttsProvider = Provider<FlutterTts>((ref) {
  final tts = FlutterTts();
  tts.setLanguage('en-US');
  tts.setSpeechRate(0.45);
  return tts;
});

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  final repo = ref.watch(dictionaryRepoProvider);
  final tts = ref.watch(ttsProvider);
  final stats = ref.read(statsProvider.notifier);
  return GameNotifier(repo, tts, stats);
});

class GameNotifier extends StateNotifier<GameState> {
  final DictionaryRepository _repo;
  final FlutterTts _tts;
  final StatsNotifier _stats;

  /// Calendar date the loaded game belongs to. Saves and stats use this, not the clock,
  /// so a game started before midnight is still recorded against its own day.
  DateTime _gameDate = _today();

  /// Guards against an older, slower [initGame] overwriting a newer one.
  int _loadToken = 0;

  /// Blocks a second ENTER while the first guess is still being validated.
  bool _submitting = false;

  GameNotifier(this._repo, this._tts, this._stats)
      : super(const GameState(
          wordLength: 5,
          maxGuesses: 6,
          submittedRows: [],
          currentInput: '',
          status: GameStatus.playing,
          keyEvaluations: {},
        )) {
    initGame();
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Loads today's game. A game already in progress keeps its length; otherwise
  /// [length] (or the last chosen length) is used.
  Future<void> initGame({int? length}) async {
    final token = ++_loadToken;
    final today = _today();
    final saved = GameStateStore.getSavedGame(GameConstants.dateKey(today));
    final savedRows = saved?['submittedRows'] as List?;
    final hasProgress = savedRows != null && savedRows.isNotEmpty;

    var wordLength = hasProgress
        ? (saved!['wordLength'] as int? ?? SettingsStore.preferredWordLength)
        : (length ?? SettingsStore.preferredWordLength);
    if (!GameConstants.supportedLengths.contains(wordLength)) {
      wordLength = GameConstants.supportedLengths.first;
    }
    final maxGuesses = GameConstants.getMaxGuesses(wordLength);

    final word = await _repo.getDailyWord(today, wordLength);
    final bookmarked = word != null && await _repo.isBookmarked(word.id);
    if (token != _loadToken) return;

    _gameDate = today;
    final dayNumber = GameConstants.dayNumber(today);

    if (hasProgress && word != null && saved!['targetWordId'] == word.id) {
      final restoredRows = savedRows.map((row) {
        return (row as List).map((cell) {
          final m = cell as Map;
          return GuessLetter(
            char: m['char'] as String,
            evaluation: LetterEvaluation.values.firstWhere(
              (e) => e.name == m['evaluation'],
              orElse: () => LetterEvaluation.absent,
            ),
          );
        }).toList();
      }).toList();

      final restoredKeys = <String, LetterEvaluation>{};
      (saved['keyEvaluations'] as Map?)?.forEach((k, v) {
        restoredKeys[k as String] = LetterEvaluation.values.firstWhere(
          (e) => e.name == v,
          orElse: () => LetterEvaluation.absent,
        );
      });

      final restoredStatus = GameStatus.values.firstWhere(
        (e) => e.name == (saved['status'] as String? ?? 'playing'),
        orElse: () => GameStatus.playing,
      );

      state = GameState(
        targetWord: word,
        wordLength: wordLength,
        maxGuesses: maxGuesses,
        submittedRows: restoredRows,
        currentInput: '',
        status: restoredStatus,
        keyEvaluations: restoredKeys,
        isBookmarked: bookmarked,
        dayNumber: dayNumber,
      );
      return;
    }

    state = GameState(
      targetWord: word,
      wordLength: wordLength,
      maxGuesses: maxGuesses,
      submittedRows: [],
      currentInput: '',
      status: GameStatus.playing,
      keyEvaluations: {},
      isBookmarked: bookmarked,
      dayNumber: dayNumber,
    );
  }

  /// Switches between 5 and 6 letters; only allowed before the first guess.
  Future<void> changeLength(int length) async {
    if (state.isLengthLocked || length == state.wordLength) return;
    if (!GameConstants.supportedLengths.contains(length)) return;
    await SettingsStore.setPreferredWordLength(length);
    await initGame(length: length);
  }

  /// Loads the new day's word if the date has changed since the game was loaded.
  Future<void> refreshIfNewDay() async {
    if (_today() == _gameDate) return;
    await initGame();
    _stats.reload();
  }

  void addLetter(String letter) {
    if (state.status != GameStatus.playing) return;
    if (state.currentInput.length >= state.wordLength) return;

    HapticUtils.selection();
    state = state.copyWith(currentInput: state.currentInput + letter.toUpperCase());
  }

  void removeLetter() {
    if (state.status != GameStatus.playing) return;
    if (state.currentInput.isEmpty) return;

    HapticUtils.selection();
    state = state.copyWith(
      currentInput: state.currentInput.substring(0, state.currentInput.length - 1),
    );
  }

  Future<void> submitGuess() async {
    if (_submitting) return;
    _submitting = true;
    try {
      await _submitGuess();
    } finally {
      _submitting = false;
    }
  }

  Future<void> _submitGuess() async {
    if (state.status != GameStatus.playing) return;
    if (state.currentInput.length < state.wordLength) {
      triggerShake('Not enough letters');
      return;
    }

    final guess = state.currentInput.toUpperCase();
    final target = state.targetWord?.word.toUpperCase() ?? '';

    // Validate word exists in dictionary
    final isValid = await _repo.isValidWord(guess);
    if (!isValid && guess != target) {
      triggerShake('Not in word list');
      return;
    }

    // Evaluate tiles with duplicate handling
    final evaluation = _evaluateGuess(guess, target);
    final newRow = List.generate(
      state.wordLength,
      (i) => GuessLetter(char: guess[i], evaluation: evaluation[i]),
    );

    final updatedRows = [...state.submittedRows, newRow];
    final updatedKeys = Map<String, LetterEvaluation>.from(state.keyEvaluations);

    for (int i = 0; i < guess.length; i++) {
      final char = guess[i];
      final currentEval = updatedKeys[char] ?? LetterEvaluation.empty;
      final newEval = evaluation[i];

      if (newEval == LetterEvaluation.correct) {
        updatedKeys[char] = LetterEvaluation.correct;
      } else if (newEval == LetterEvaluation.wrongPosition &&
          currentEval != LetterEvaluation.correct) {
        updatedKeys[char] = LetterEvaluation.wrongPosition;
      } else if (newEval == LetterEvaluation.absent &&
          currentEval != LetterEvaluation.correct &&
          currentEval != LetterEvaluation.wrongPosition) {
        updatedKeys[char] = LetterEvaluation.absent;
      }
    }

    final isWon = guess == target;
    final isLost = !isWon && updatedRows.length >= state.maxGuesses;

    GameStatus nextStatus = GameStatus.playing;
    if (isWon) {
      nextStatus = GameStatus.won;
      HapticUtils.heavy();
    } else if (isLost) {
      nextStatus = GameStatus.lost;
      HapticUtils.heavy();
    } else {
      HapticUtils.medium();
    }

    state = state.copyWith(
      submittedRows: updatedRows,
      currentInput: '',
      keyEvaluations: updatedKeys,
      status: nextStatus,
      revealRow: updatedRows.length - 1,
    );

    await _persistState();
    if (nextStatus != GameStatus.playing) {
      await _recordResult(isWon, updatedRows.length);
    }
  }

  Future<void> _persistState() async {
    final word = state.targetWord;
    if (word == null) return;

    final serializedRows = state.submittedRows.map((row) {
      return row.map((gl) => {
        'char': gl.char,
        'evaluation': gl.evaluation.name,
      }).toList();
    }).toList();

    final serializedKeys = state.keyEvaluations.map(
      (k, v) => MapEntry(k, v.name),
    );

    await GameStateStore.saveGame(GameConstants.dateKey(_gameDate), {
      'targetWordId': word.id,
      'wordLength': state.wordLength,
      'submittedRows': serializedRows,
      'keyEvaluations': serializedKeys,
      'status': state.status.name,
    });
  }

  List<LetterEvaluation> _evaluateGuess(String guess, String target) {
    final len = guess.length;
    final result = List<LetterEvaluation>.filled(len, LetterEvaluation.absent);
    final targetLetters = target.split('');
    final targetTaken = List<bool>.filled(len, false);

    // Pass 1: exact matches
    for (int i = 0; i < len; i++) {
      if (guess[i] == targetLetters[i]) {
        result[i] = LetterEvaluation.correct;
        targetTaken[i] = true;
      }
    }

    // Pass 2: wrong position
    for (int i = 0; i < len; i++) {
      if (result[i] == LetterEvaluation.correct) continue;

      for (int j = 0; j < len; j++) {
        if (!targetTaken[j] && guess[i] == targetLetters[j]) {
          result[i] = LetterEvaluation.wrongPosition;
          targetTaken[j] = true;
          break;
        }
      }
    }

    return result;
  }

  void triggerShake(String msg) {
    HapticUtils.heavy();
    state = state.copyWith(isShaking: true, message: msg);
    Future.delayed(const Duration(milliseconds: 600), () {
      state = state.copyWith(isShaking: false, message: null);
    });
  }

  Future<void> toggleBookmark() async {
    final word = state.targetWord;
    if (word == null) return;

    if (state.isBookmarked) {
      await _repo.removeBookmark(word.id);
      state = state.copyWith(isBookmarked: false);
    } else {
      await _repo.bookmarkWord(word.id);
      state = state.copyWith(isBookmarked: true);
    }
  }

  /// Re-reads whether today's word is bookmarked, after the Word Bank changes it.
  Future<void> syncBookmark() async {
    final word = state.targetWord;
    if (word == null) return;
    final bookmarked = await _repo.isBookmarked(word.id);
    if (bookmarked != state.isBookmarked) {
      state = state.copyWith(isBookmarked: bookmarked);
    }
  }

  Future<void> speakWord() async {
    final word = state.targetWord?.word;
    if (word != null) {
      await _tts.speak(word.toLowerCase());
    }
  }

  Future<void> _recordResult(bool won, int guessesUsed) async {
    final word = state.targetWord;
    if (word == null) return;
    await _repo.recordDailyResult(
      date: _gameDate,
      wordId: word.id,
      wordLength: word.length,
      solved: won,
      guesses: guessesUsed,
    );
    await _stats.recordGameResult(
      won: won,
      guessesUsed: guessesUsed,
      date: _gameDate,
    );
  }
}

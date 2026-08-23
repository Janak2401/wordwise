import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../data/models/guess_result.dart';
import '../../../data/models/word.dart';
import '../../../data/repositories/dictionary_repository.dart';
import '../../../data/datasources/stats_store.dart';
import '../../../data/datasources/game_state_store.dart';

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
  });

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
  return GameNotifier(repo, tts);
});

class GameNotifier extends StateNotifier<GameState> {
  final DictionaryRepository _repo;
  final FlutterTts _tts;

  GameNotifier(this._repo, this._tts)
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

  Future<void> initGame({int? customLength}) async {
    final now = DateTime.now();
    final word = await _repo.getDailyWord(now, preferredLength: customLength);
    final length = word?.length ?? customLength ?? 5;
    final maxGuesses = GameConstants.getMaxGuesses(length);

    bool bookmarked = false;
    if (word != null) {
      bookmarked = await _repo.isBookmarked(word.id);
    }

    state = GameState(
      targetWord: word,
      wordLength: length,
      maxGuesses: maxGuesses,
      submittedRows: [],
      currentInput: '',
      status: GameStatus.playing,
      keyEvaluations: {},
      isBookmarked: bookmarked,
    );
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
      _recordStats(true, updatedRows.length);
    } else if (isLost) {
      nextStatus = GameStatus.lost;
      HapticUtils.heavy();
      _recordStats(false, updatedRows.length);
    } else {
      HapticUtils.medium();
    }

    state = state.copyWith(
      submittedRows: updatedRows,
      currentInput: '',
      keyEvaluations: updatedKeys,
      status: nextStatus,
    );
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

  Future<void> speakWord() async {
    final word = state.targetWord?.word;
    if (word != null) {
      await _tts.speak(word.toLowerCase());
    }
  }

  void _recordStats(bool won, int guessesUsed) {
    final dateStr = DateTime.now().toIso8601String().substring(0, 10);
    StatsStore.recordGameResult(
      won: won,
      guessesUsed: guessesUsed,
      dateStr: dateStr,
    );
  }
}

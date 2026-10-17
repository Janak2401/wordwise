import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wordwise/core/constants/game_constants.dart';
import 'package:wordwise/core/theme/app_theme.dart';
import 'package:wordwise/data/models/guess_result.dart';
import 'package:wordwise/data/models/word.dart';
import 'package:wordwise/data/repositories/dictionary_repository.dart';
import 'package:wordwise/features/game/providers/game_provider.dart';
import 'package:wordwise/features/game/screens/game_screen.dart';
import 'package:wordwise/features/game/widgets/game_grid.dart';
import 'package:wordwise/features/game/widgets/game_keyboard.dart';
import 'package:wordwise/features/stats/providers/stats_provider.dart';

/// Serves a fixed state instead of loading today's word from the database.
class _FakeGameNotifier extends GameNotifier {
  final GameState fixed;

  _FakeGameNotifier(this.fixed) : super(DictionaryRepository(), FlutterTts(), StatsNotifier());

  @override
  Future<void> initGame({int? length}) async {
    state = fixed;
  }
}

GameState _stateFor(int length, {required bool finished}) {
  final maxGuesses = GameConstants.getMaxGuesses(length);
  final word = 'QUIRKS'.substring(0, length);
  List<GuessLetter> row(LetterEvaluation e) =>
      List.generate(length, (i) => GuessLetter(char: word[i], evaluation: e));

  return GameState(
    targetWord: Word(
      id: 1,
      word: word,
      length: length,
      // Long enough to use both lines of the clue.
      definition: 'A peculiar aspect of a person\'s character or behavior that sets them apart from others',
      partOfSpeech: 'noun',
    ),
    wordLength: length,
    maxGuesses: maxGuesses,
    // Every row filled, so the whole grid is drawn.
    submittedRows: [
      for (var i = 0; i < maxGuesses - 1; i++) row(LetterEvaluation.absent),
      if (finished) row(LetterEvaluation.correct),
    ],
    currentInput: finished ? '' : word,
    status: finished ? GameStatus.won : GameStatus.playing,
    keyEvaluations: const {'Q': LetterEvaluation.correct, 'A': LetterEvaluation.absent},
  );
}

Future<void> _pumpGame(
  WidgetTester tester, {
  required Size screen,
  required GameState state,
  double textScale = 1.0,
}) async {
  // Typical Android status bar (24dp) and gesture bar (48dp) insets.
  const dpr = 2.75;
  tester.view.devicePixelRatio = dpr;
  tester.view.physicalSize = screen * dpr;
  tester.view.padding = const FakeViewPadding(top: 24 * dpr, bottom: 48 * dpr);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [gameProvider.overrideWith((ref) => _FakeGameNotifier(state))],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        // Same structure as MainShell: the game screen above a bottom tab bar.
        home: Scaffold(
          body: const GameScreen(),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.grid_on_rounded), label: 'Game'),
              BottomNavigationBarItem(icon: Icon(Icons.bookmark_rounded), label: 'Word Bank'),
              BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Stats'),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  // Fonts can't be downloaded in tests; fall back to the default font.
  GoogleFonts.config.allowRuntimeFetching = false;

  const screens = {
    'small 360x640': Size(360, 640),
    'medium 393x851': Size(393, 851),
    'large 411x891': Size(411, 891),
    'tablet 800x1280': Size(800, 1280),
  };

  for (final entry in screens.entries) {
    for (final length in GameConstants.supportedLengths) {
      for (final finished in [false, true]) {
        final label = '${entry.key}, $length letters, ${finished ? 'finished' : 'playing'}';

        testWidgets('grid fits above the keyboard: $label', (tester) async {
          await _pumpGame(tester, screen: entry.value, state: _stateFor(length, finished: finished));

          // A RenderFlex overflow is reported as an exception.
          expect(tester.takeException(), isNull);

          final grid = tester.getRect(find.byType(GameGrid));
          final keyboard = tester.getRect(find.byType(GameKeyboard));
          final gridColumn = tester.getRect(
            find.descendant(of: find.byType(GameGrid), matching: find.byType(Column)).first,
          );

          expect(gridColumn.bottom, lessThanOrEqualTo(grid.bottom));
          expect(gridColumn.bottom, lessThanOrEqualTo(keyboard.top));
          expect(keyboard.width, lessThanOrEqualTo(500));

          final tileSize = gridColumn.height / GameConstants.getMaxGuesses(length);
          debugPrint('$label: grid ${gridColumn.size}, tile ~${tileSize.toStringAsFixed(1)}dp, '
              'keyboard top ${keyboard.top.toStringAsFixed(0)}');
        });
      }
    }
  }

  testWidgets('grid keeps its size when the game finishes', (tester) async {
    Future<double> gridHeight(bool finished) async {
      await _pumpGame(tester, screen: const Size(360, 640), state: _stateFor(5, finished: finished));
      return tester
          .getRect(find.descendant(of: find.byType(GameGrid), matching: find.byType(Column)).first)
          .height;
    }

    final playing = await gridHeight(false);
    // A new ProviderScope with a different state replaces the old screen.
    await tester.pumpWidget(const SizedBox());
    final finished = await gridHeight(true);
    expect(finished, playing);
  });

  testWidgets('large system font does not overflow keys or tiles', (tester) async {
    await _pumpGame(
      tester,
      screen: const Size(360, 640),
      state: _stateFor(6, finished: false),
      textScale: 2.0,
    );
    expect(tester.takeException(), isNull);
  });
}

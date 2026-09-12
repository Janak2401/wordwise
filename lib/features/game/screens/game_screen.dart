import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../data/datasources/stats_store.dart';
import '../providers/game_provider.dart';
import '../widgets/game_grid.dart';
import '../widgets/game_keyboard.dart';
import '../widgets/definition_hint.dart';
import '../widgets/post_game_modal.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _modalShown = false;

  void _checkGameStatus(GameState state) {
    if (state.status != GameStatus.playing && !_modalShown) {
      _modalShown = true;
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (!mounted) return;
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => PostGameModal(isWon: state.status == GameStatus.won),
        ).then((_) {
          _modalShown = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final streak = StatsStore.currentStreak;
    final isDark = ref.watch(themeProvider);

    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final surfaceColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final bgColor = isDark ? AppColors.background : AppColors.lightBackground;

    ref.listen<GameState>(gameProvider, (previous, next) {
      _checkGameStatus(next);
    });

    final currentGuessCount = gameState.submittedRows.length + (gameState.currentInput.isNotEmpty ? 1 : 0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'W O R D W I S E',
          style: AppTypography.title.copyWith(color: textPrimary),
        ),
        leading: IconButton(
          icon: Icon(Icons.help_outline_rounded, color: textSecondary),
          onPressed: () => context.push('/how-to-play'),
        ),
        actions: [
          // Length Selector Dropdown (5, 6, 7)
          PopupMenuButton<int>(
            tooltip: 'Word Length',
            initialValue: gameState.wordLength,
            color: surfaceColor,
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${gameState.wordLength}L',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.correct,
                ),
              ),
            ),
            onSelected: (len) {
              if (len != gameState.wordLength) {
                ref.read(gameProvider.notifier).initGame(customLength: len);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 5, child: Text('5 Letters (6 Guesses)', style: TextStyle(color: textPrimary))),
              PopupMenuItem(value: 6, child: Text('6 Letters (7 Guesses)', style: TextStyle(color: textPrimary))),
              PopupMenuItem(value: 7, child: Text('7 Letters (8 Guesses)', style: TextStyle(color: textPrimary))),
            ],
          ),
          // Streak Counter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 2),
                Text(
                  '$streak',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Theme Toggle
          IconButton(
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: textSecondary,
            ),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          // Settings
          IconButton(
            icon: Icon(Icons.settings_outlined, color: textSecondary),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Divider(color: borderColor, height: 1),

            // Definition Clue Hint
            DefinitionHint(
              definition: gameState.targetWord?.definition,
              partOfSpeech: gameState.targetWord?.partOfSpeech,
            ),

            // Toast/Alert Message on invalid word
            if (gameState.message != null)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: textPrimary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  gameState.message!,
                  style: TextStyle(
                    color: bgColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),

            // Dynamic Tile Grid
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GameGrid(
                    wordLength: gameState.wordLength,
                    maxGuesses: gameState.maxGuesses,
                    submittedRows: gameState.submittedRows,
                    currentInput: gameState.currentInput,
                    isShaking: gameState.isShaking,
                  ),
                ),
              ),
            ),

            // Guess Counter
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Text(
                'Guess $currentGuessCount of ${gameState.maxGuesses}',
                style: AppTypography.bodySecondary.copyWith(fontSize: 12, color: textSecondary),
              ),
            ),

            // Virtual Keyboard
            GameKeyboard(
              onLetterPressed: (l) => ref.read(gameProvider.notifier).addLetter(l),
              onEnterPressed: () => ref.read(gameProvider.notifier).submitGuess(),
              onBackspacePressed: () => ref.read(gameProvider.notifier).removeLetter(),
              keyEvaluations: gameState.keyEvaluations,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: surfaceColor,
        selectedItemColor: AppColors.correct,
        unselectedItemColor: textSecondary,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) context.push('/word-bank');
          if (index == 2) context.push('/stats');
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_on_rounded),
            label: 'Game',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_rounded),
            label: 'Word Bank',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}

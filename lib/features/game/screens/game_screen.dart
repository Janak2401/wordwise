import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/theme_provider.dart';
import '../../stats/providers/stats_provider.dart';
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

class _GameScreenState extends ConsumerState<GameScreen> with WidgetsBindingObserver {
  bool _modalShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(gameProvider.notifier).refreshIfNewDay();
    }
  }

  /// Auto-opens results only when a guess just finished the game, not when a finished game is restored.
  void _onGameStateChanged(GameState? previous, GameState next) {
    final justFinished = previous != null &&
        previous.status == GameStatus.playing &&
        next.status != GameStatus.playing &&
        previous.targetWord?.id == next.targetWord?.id;
    if (justFinished) {
      // Let the tile flip finish first.
      Future.delayed(const Duration(milliseconds: 1800), _showResults);
    }
  }

  void _showResults() {
    if (!mounted || _modalShown) return;
    _modalShown = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const PostGameModal(),
    ).then((_) {
      _modalShown = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final streak = ref.watch(statsProvider).currentStreak;
    final isDark = ref.watch(themeProvider);

    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final surfaceColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final bgColor = isDark ? AppColors.background : AppColors.lightBackground;

    ref.listen<GameState>(gameProvider, _onGameStateChanged);

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
          // Length Selector (5, 6): locked after the first guess so only one word is played per day
          PopupMenuButton<int>(
            tooltip: gameState.isLengthLocked ? 'Length locked until tomorrow' : 'Word Length',
            enabled: !gameState.isLengthLocked,
            initialValue: gameState.wordLength,
            color: surfaceColor,
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${gameState.wordLength}L',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: gameState.isLengthLocked ? textSecondary : AppColors.correct,
                    ),
                  ),
                  if (gameState.isLengthLocked) ...[
                    const SizedBox(width: 2),
                    Icon(Icons.lock_rounded, size: 12, color: textSecondary),
                  ],
                ],
              ),
            ),
            onSelected: (len) => ref.read(gameProvider.notifier).changeLength(len),
            itemBuilder: (context) => [
              PopupMenuItem(value: 5, child: Text('5 Letters (6 Guesses)', style: TextStyle(color: textPrimary))),
              PopupMenuItem(value: 6, child: Text('6 Letters (7 Guesses)', style: TextStyle(color: textPrimary))),
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
                    revealRow: gameState.revealRow,
                  ),
                ),
              ),
            ),

            // Guess counter while playing; results button once today's word is done
            if (gameState.status == GameStatus.playing)
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Text(
                  'Guess $currentGuessCount of ${gameState.maxGuesses}',
                  style: AppTypography.bodySecondary.copyWith(fontSize: 12, color: textSecondary),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: TextButton.icon(
                  onPressed: _showResults,
                  icon: const Icon(Icons.insights_rounded, size: 18, color: AppColors.correct),
                  label: const Text(
                    'SEE RESULTS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppColors.correct,
                    ),
                  ),
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

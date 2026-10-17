import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/theme_provider.dart';
import '../../stats/providers/stats_provider.dart';
import '../providers/game_provider.dart';
import '../widgets/game_grid.dart';
import '../widgets/game_keyboard.dart';
import '../widgets/definition_hint.dart';
import '../widgets/post_game_modal.dart';
import '../../../core/theme/app_theme.dart';

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
      // Cover the tab bar instead of opening inside the Game tab.
      useRootNavigator: true,
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
    final palette = AppPalette.of(context);

    final textPrimary = palette.textPrimary;
    final textSecondary = palette.textSecondary;
    final borderColor = palette.border;
    final surfaceColor = palette.surface;
    final bgColor = palette.background;

    ref.listen<GameState>(gameProvider, _onGameStateChanged);

    final currentGuessCount = gameState.submittedRows.length + (gameState.currentInput.isNotEmpty ? 1 : 0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
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
            Expanded(
              // Centered column of limited width so tablets don't stretch the grid and keyboard.
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: AppDimensions.contentMaxWidth),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        // Definition Clue Hint
                        DefinitionHint(
                          definition: gameState.targetWord?.definition,
                          partOfSpeech: gameState.targetWord?.partOfSpeech,
                        ),

                        // Tile grid sized to the space left over, with messages floating on top
                        Expanded(
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: Center(
                                  child: MediaQuery.withClampedTextScaling(
                                    maxScaleFactor: AppDimensions.maxGameTextScale,
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
                              Positioned(
                                top: 4,
                                child: IgnorePointer(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 150),
                                    child: gameState.message == null
                                        ? const SizedBox.shrink()
                                        : Container(
                                            key: ValueKey(gameState.message),
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
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Guess counter while playing; results button once today's word is done.
                        // Fixed height so the grid keeps its size when the game ends.
                        SizedBox(
                          height: AppDimensions.statusStripHeight,
                          child: Center(
                            child: gameState.status == GameStatus.playing
                                ? Text(
                                    'Guess $currentGuessCount of ${gameState.maxGuesses}',
                                    style: AppTypography.bodySecondary.copyWith(fontSize: 12, color: textSecondary),
                                  )
                                : TextButton.icon(
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
                        ),

                        // Virtual Keyboard
                        MediaQuery.withClampedTextScaling(
                          maxScaleFactor: AppDimensions.maxGameTextScale,
                          child: GameKeyboard(
                            onLetterPressed: (l) => ref.read(gameProvider.notifier).addLetter(l),
                            onEnterPressed: () => ref.read(gameProvider.notifier).submitGuess(),
                            onBackspacePressed: () => ref.read(gameProvider.notifier).removeLetter(),
                            keyEvaluations: gameState.keyEvaluations,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

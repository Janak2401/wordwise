import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/share_utils.dart';
import '../../stats/providers/stats_provider.dart';
import '../providers/game_provider.dart';
import 'next_word_countdown.dart';

class PostGameModal extends ConsumerWidget {
  const PostGameModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final word = gameState.targetWord;

    if (word == null) return const SizedBox.shrink();

    final isWon = gameState.status == GameStatus.won;

    final streak = ref.watch(statsProvider).currentStreak;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final surfaceColor = isDark ? AppColors.surface : AppColors.lightBackground;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top drag bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Status
              Center(
                child: Text(
                  isWon ? '✨ MAGNIFICENT!' : 'BETTER LUCK NEXT TIME',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    color: isWon ? AppColors.correct : AppColors.errorRed,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Word Header + Pronunciation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          word.word,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            color: textPrimary,
                          ),
                        ),
                        if (word.phonetic != null)
                          Text(
                            word.phonetic!,
                            style: AppTypography.bodySecondary.copyWith(color: textSecondary),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded, color: AppColors.correct, size: 30),
                    onPressed: () => ref.read(gameProvider.notifier).speakWord(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Part of Speech & Definition
              if (word.partOfSpeech != null)
                Text(
                  word.partOfSpeech!,
                  style: AppTypography.headerItalic.copyWith(color: textSecondary),
                ),
              const SizedBox(height: 4),
              Text(
                word.definition,
                style: AppTypography.bodyRegular.copyWith(color: textPrimary),
              ),

              // Example Sentence
              if (word.example != null && word.example!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  '"${word.example}"',
                  style: AppTypography.bodyItalic.copyWith(color: textSecondary),
                ),
              ],

              // Synonyms
              if (word.synonyms != null && word.synonyms!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Synonyms: ${word.synonyms}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.accentTeal,
                  ),
                ),
              ],

              const SizedBox(height: 24),
              Divider(color: borderColor),
              const SizedBox(height: 16),

              NextWordCountdown(
                labelColor: textSecondary,
                valueColor: textPrimary,
                onElapsed: () {
                  final notifier = ref.read(gameProvider.notifier);
                  Navigator.of(context).maybePop();
                  notifier.refreshIfNewDay();
                },
              ),
              const SizedBox(height: 20),

              // Action Buttons: Bookmark & Share
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: gameState.isBookmarked
                              ? AppColors.correct
                              : (isDark ? AppColors.borderBright : AppColors.lightBorderBright),
                        ),
                        backgroundColor: gameState.isBookmarked ? AppColors.correct.withValues(alpha: 0.15) : null,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => ref.read(gameProvider.notifier).toggleBookmark(),
                      icon: Icon(
                        gameState.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                        color: gameState.isBookmarked ? AppColors.correct : textPrimary,
                        size: 20,
                      ),
                      label: Text(
                        gameState.isBookmarked ? 'SAVED' : 'SAVE WORD',
                        style: TextStyle(
                          color: gameState.isBookmarked ? AppColors.correct : textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.correct,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        final gridText = ShareUtils.generateEmojiGrid(
                          puzzleNumber: gameState.dayNumber + 1,
                          guessRows: gameState.submittedRows,
                          maxGuesses: gameState.maxGuesses,
                          streak: streak,
                        );
                        ShareUtils.shareResult(gridText);
                      },
                      icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                      label: const Text(
                        'SHARE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}


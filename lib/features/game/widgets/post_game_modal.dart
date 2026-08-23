import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/share_utils.dart';
import '../../../data/datasources/stats_store.dart';
import '../providers/game_provider.dart';

class PostGameModal extends ConsumerWidget {
  final bool isWon;

  const PostGameModal({
    super.key,
    required this.isWon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final word = gameState.targetWord;

    if (word == null) return const SizedBox.shrink();

    final streak = StatsStore.currentStreak;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                    color: AppColors.border,
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
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (word.phonetic != null)
                          Text(
                            word.phonetic!,
                            style: AppTypography.bodySecondary,
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
                  style: AppTypography.headerItalic,
                ),
              const SizedBox(height: 4),
              Text(
                word.definition,
                style: AppTypography.bodyRegular,
              ),

              // Example Sentence
              if (word.example != null && word.example!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  '"${word.example}"',
                  style: AppTypography.bodyItalic,
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
              const Divider(color: AppColors.border),
              const SizedBox(height: 16),

              // Action Buttons: Bookmark & Share
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: gameState.isBookmarked ? AppColors.correct : AppColors.borderBright,
                        ),
                        backgroundColor: gameState.isBookmarked ? AppColors.correct.withOpacity(0.15) : null,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => ref.read(gameProvider.notifier).toggleBookmark(),
                      icon: Icon(
                        gameState.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                        color: gameState.isBookmarked ? AppColors.correct : AppColors.textPrimary,
                        size: 20,
                      ),
                      label: Text(
                        gameState.isBookmarked ? 'SAVED' : 'SAVE WORD',
                        style: TextStyle(
                          color: gameState.isBookmarked ? AppColors.correct : AppColors.textPrimary,
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
                          targetWord: word.word,
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

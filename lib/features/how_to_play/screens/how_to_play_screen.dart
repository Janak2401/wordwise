import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_theme.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final textPrimary = palette.textPrimary;
    final textSecondary = palette.textSecondary;
    final borderColor = palette.border;
    final bgColor = palette.background;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textSecondary),
        title: Text(
          'HOW TO PLAY',
          style: AppTypography.title.copyWith(letterSpacing: 2.0, color: textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'One new word every day.',
              style: AppTypography.bodyRegular.copyWith(fontWeight: FontWeight.bold, color: textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              '• 5-letter word = 6 guesses\n• 6-letter word = 7 guesses\n• Pick the length before your first guess; it locks until tomorrow',
              style: AppTypography.bodySecondary.copyWith(color: textSecondary),
            ),
            const SizedBox(height: 16),
            Text(
              'Each guess must be a valid word. Hit ENTER to submit.',
              style: AppTypography.bodySecondary.copyWith(color: textSecondary),
            ),
            const SizedBox(height: 24),
            Divider(color: borderColor),
            const SizedBox(height: 16),
            Text(
              'EXAMPLES',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildExampleTile('W', AppColors.correct, 'W is in the word and in the correct spot.', textSecondary),
            const SizedBox(height: 16),
            _buildExampleTile('I', AppColors.wrongPosition, 'I is in the word but in the wrong spot.', textSecondary),
            const SizedBox(height: 16),
            _buildExampleTile('S', palette.absent, 'S is not in the word in any spot.', textSecondary),
            const SizedBox(height: 28),
            Divider(color: borderColor),
            const SizedBox(height: 16),
            Text(
              'LEARN AS YOU PLAY',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Look at the definition clue at the top of the screen to guide your thinking. After each game, explore the full pronunciation, parts of speech, and bookmark the word to your review deck.',
              style: AppTypography.bodySecondary.copyWith(color: textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleTile(String letter, Color color, String explanation, Color secondaryColor) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.zero,
          ),
          child: Text(
            letter,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            explanation,
            style: AppTypography.bodySecondary.copyWith(color: secondaryColor),
          ),
        ),
      ],
    );
  }
}

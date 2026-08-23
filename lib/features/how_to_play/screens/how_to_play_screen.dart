import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'HOW TO PLAY',
          style: AppTypography.title.copyWith(letterSpacing: 2.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Guess the word in dynamic attempts.',
              style: AppTypography.bodyRegular.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '• 5-letter word = 6 guesses\n• 6-letter word = 7 guesses\n• 7-letter word = 8 guesses',
              style: AppTypography.bodySecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Each guess must be a valid word. Hit ENTER to submit.',
              style: AppTypography.bodySecondary,
            ),
            const SizedBox(height: 24),
            const Divider(color: AppColors.border),
            const SizedBox(height: 16),
            Text(
              'EXAMPLES',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildExampleTile('W', AppColors.correct, 'W is in the word and in the correct spot.'),
            const SizedBox(height: 16),
            _buildExampleTile('I', AppColors.wrongPosition, 'I is in the word but in the wrong spot.'),
            const SizedBox(height: 16),
            _buildExampleTile('S', AppColors.absent, 'S is not in the word in any spot.'),
            const SizedBox(height: 28),
            const Divider(color: AppColors.border),
            const SizedBox(height: 16),
            Text(
              'LEARN AS YOU PLAY',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Look at the definition clue at the top of the screen to guide your thinking. After each game, explore the full pronunciation, parts of speech, and bookmark the word to your review deck.',
              style: AppTypography.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleTile(String letter, Color color, String explanation) {
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
            style: AppTypography.bodySecondary,
          ),
        ),
      ],
    );
  }
}

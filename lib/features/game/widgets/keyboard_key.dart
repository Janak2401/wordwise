import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/models/guess_result.dart';

class KeyboardKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final LetterEvaluation evaluation;
  final double flex;
  final Widget? customChild;

  const KeyboardKey({
    super.key,
    required this.label,
    required this.onTap,
    this.evaluation = LetterEvaluation.empty,
    this.flex = 1.0,
    this.customChild,
  });

  Color _getBackgroundColor(bool isDark) {
    switch (evaluation) {
      case LetterEvaluation.correct:
        return AppColors.correct;
      case LetterEvaluation.wrongPosition:
        return AppColors.wrongPosition;
      case LetterEvaluation.absent:
        return isDark ? AppColors.keyAbsentDark : AppColors.keyAbsentLight;
      default:
        return isDark ? AppColors.keyDefaultDark : AppColors.keyDefaultLight;
    }
  }

  Color _getTextColor(bool isDark) {
    switch (evaluation) {
      case LetterEvaluation.correct:
      case LetterEvaluation.wrongPosition:
        return Colors.white;
      case LetterEvaluation.absent:
        return isDark ? AppColors.keyTextMutedDark : Colors.white;
      default:
        return isDark ? Colors.white : AppColors.lightTextPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = _getBackgroundColor(isDark);
    final textColor = _getTextColor(isDark);

    return Expanded(
      flex: (flex * 10).toInt(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 3.5),
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(4.0),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(4.0),
            child: Container(
              height: 52,
              alignment: Alignment.center,
              child: customChild != null
                  ? IconTheme(
                      data: IconThemeData(color: textColor),
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        child: customChild!,
                      ),
                    )
                  : Text(
                      label,
                      style: AppTypography.keyLabel.copyWith(
                        color: textColor,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
